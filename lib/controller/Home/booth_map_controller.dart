import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/model/map/exhibition_map_model.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/sourcedata/remote/Exhibitions/ExhibitionMapData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../core/constant/routes.dart';
import '../../view/widget/Home/isometric_map_painter.dart';

class BoothCompanyInfo {
  final String name;
  final String email;
  final String initials;
  final Color color;
  const BoothCompanyInfo({
    required this.name,
    required this.email,
    required this.initials,
    required this.color,
  });
}

class BoothMapController extends GetxController {
  final ExhibitionMapData _mapData = ExhibitionMapData(Crud());

  final mapData = Rxn<ExhibitionMapModel>();
  final selectedBooth = Rxn<MapBoothModel>();
  final selectedBoothPosition = Rxn<Offset>();
  final isLoading = true.obs;
  final allBooths = <MapBoothModel>[].obs;

  final transformationController = TransformationController();
  final hitAreas = <BoothHitArea>[];

  int exhibitionId = 0;

  // ── ربط id الجناح في الخريطة بـ BoothModel الحقيقي ──────────
  final _boothById = <int, BoothModel>{};
  final _sceneInstanceById = <String, MapSceneInstance>{};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['exhibition_id'] != null) {
      exhibitionId = int.tryParse(args['exhibition_id'].toString()) ?? 0;
    } else if (args is int) {
      exhibitionId = args;
    } else if (args is String) {
      exhibitionId = int.tryParse(args) ?? 0;
    }
    // إذا لم تصل بيانات من ExhibitionDetailController، جلبها مستقلاً
    if (mapData.value == null) {
      loadMapData();
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    transformationController.dispose();
    super.onClose();
  }

  // ── تحميل من ExhibitionDetailController (الطريقة الأساسية) ───
  /// يُستدعى من ExhibitionDetailController بعد اكتمال التحميل
  void loadFromDetailData(
    Map<String, dynamic>? mapJson,
    List<BoothModel> booths,
  ) {
    _boothById.clear();
    for (final b in booths) {
      _boothById[b.id] = b;
    }

    if (mapJson != null && mapJson.isNotEmpty) {
      final model = ExhibitionMapModel.fromJson(mapJson);
      mapData.value = model;
      _sceneInstanceById.clear();
      for (final instance in model.sceneInstances) {
        _sceneInstanceById[instance.id] = instance;
      }

      if (model.halls.isNotEmpty) {
        final flat = model.halls.expand((h) => h.booths).toList();
        for (final mb in flat) {
          final real = _boothById[mb.id];
          if (real != null) mb.status = real.status;
        }
        allBooths.value = flat;
      } else if (model.sceneInstances.isNotEmpty) {
        final flat = model.sceneInstances
            .where(
              (i) =>
                  i.type.toLowerCase() == 'booth' ||
                  i.type.toLowerCase() == 'wing',
            )
            .map((i) {
              final boothId =
                  int.tryParse(i.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              final boothStatus = _boothById[boothId]?.status ?? 'available';
              return MapBoothModel(
                id: boothId,
                number: i.label ?? i.id,
                col: 0,
                row: 0,
                gridWidth: 1,
                gridDepth: 1,
                height: i.height ?? 1.0,
                status: boothStatus,
                price: _boothById[boothId]?.price ?? 0,
                area: _boothById[boothId]?.area ?? 0,
                hallId: i.floorId ?? 'floor',
                hallName: i.label ?? 'Map Section',
                amenities: _boothById[boothId]?.amenities ?? const [],
              );
            })
            .where((booth) => booth.id != 0)
            .toList();
        allBooths.value = flat;
      } else {
        allBooths.value = const [];
      }
      isLoading.value = false;
    } else if (mapData.value == null) {
      loadMapData();
    }
  }

  /// تحديث قائمة الأجنحة فقط (إذا وصلت بعد الخريطة)
  void setExhibitionBooths(List<BoothModel> booths) {
    _boothById.clear();
    for (final b in booths) {
      _boothById[b.id] = b;
    }
    // تحديث حالات الأجنحة في الخريطة الحالية
    for (final mb in allBooths) {
      final real = _boothById[mb.id];
      if (real != null) mb.status = real.status;
    }
    allBooths.refresh();
  }

  // ── تحميل مستقل من API (fallback) ────────────────────────────
  Future<void> loadMapData() async {
    isLoading.value = true;
    if (exhibitionId > 0) {
      final result = await _mapData.getExhibitionMap(exhibitionId);
      if (result['status'] == true) {
        final body = result['data'] is Map
            ? (result['data'] as Map<String, dynamic>)
            : <String, dynamic>{};
        final model = ExhibitionMapModel.fromJson(body);
        mapData.value = model;
        _sceneInstanceById.clear();
        for (final instance in model.sceneInstances) {
          _sceneInstanceById[instance.id] = instance;
        }
        final flat = model.halls.isNotEmpty
            ? model.halls.expand((h) => h.booths).toList()
            : model.sceneInstances
                  .where(
                    (i) =>
                        i.type.toLowerCase() == 'booth' ||
                        i.type.toLowerCase() == 'wing',
                  )
                  .map((i) {
                    final boothId =
                        int.tryParse(i.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
                        0;
                    final real = _boothById[boothId];
                    return MapBoothModel(
                      id: boothId,
                      number: i.label ?? i.id,
                      col: 0,
                      row: 0,
                      gridWidth: 1,
                      gridDepth: 1,
                      height: i.height ?? 1.0,
                      status: real?.status ?? 'available',
                      price: real?.price ?? 0,
                      area: real?.area ?? 0,
                      hallId: i.floorId ?? 'floor',
                      hallName: i.label ?? 'Map Section',
                      amenities: real?.amenities ?? const [],
                    );
                  })
                  .where((booth) => booth.id != 0)
                  .toList();
        for (final mb in flat) {
          final real = _boothById[mb.id];
          if (real != null) mb.status = real.status;
        }
        allBooths.value = flat;
        isLoading.value = false;
        return;
      }
    }
    final model = ExhibitionMapModel.fromJson(DummyData.exhibitionMap);
    mapData.value = model;
    _sceneInstanceById.clear();
    for (final instance in model.sceneInstances) {
      _sceneInstanceById[instance.id] = instance;
    }
    allBooths.value = model.halls.expand((h) => h.booths).toList();
    isLoading.value = false;
  }

  // ── الجناح الحقيقي المرتبط بـ MapBoothModel ──────────────────
  BoothModel? linkedBooth(MapBoothModel mapBooth) => _boothById[mapBooth.id];

  // ── معلومات الشركة الحاجزة (من الـ API) ─────────────────────
  BoothCompanyInfo? companyForBooth(MapBoothModel booth) {
    final real = _boothById[booth.id];
    if (real != null && (real.companyName?.isNotEmpty ?? false)) {
      return BoothCompanyInfo(
        name: real.companyName!,
        email: real.companyEmail ?? '',
        initials: real.companyInitials ?? real.companyName![0],
        color: const Color(0xFF7A1FFF),
      );
    }
    // fallback: اسم افتراضي إذا كان الجناح محجوزاً
    if (booth.isBooked) {
      return const BoothCompanyInfo(
        name: 'شركة محجوزة',
        email: '—',
        initials: 'ش',
        color: Color(0xFF7A1FFF),
      );
    }
    return null;
  }

  void onBoothTapped(MapBoothModel booth, {Offset? screenPosition}) {
    if (selectedBooth.value?.id == booth.id) {
      clearSelection();
      return;
    }

    selectedBooth.value = booth;
    selectedBoothPosition.value = screenPosition;

    final realBooth = linkedBooth(booth);
    if (realBooth != null && realBooth.status == 'available') {
      Future.microtask(() {
        Get.bottomSheet(
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.event_available_rounded,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الجناح ${booth.number} - ${booth.hallName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'الحالة: متاح للحجز',
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        proceedToBooking();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A1FFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('الحجز الآن'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isScrollControlled: true,
        );
      });
    } else if (realBooth != null && realBooth.status == 'booked') {
      Future.microtask(() {
        Get.bottomSheet(
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.event_busy_rounded,
                        color: Color(0xFF3A3650),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الجناح ${booth.number} - ${booth.hallName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'الحالة: محجوز',
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  if ((realBooth.companyName ?? '').isNotEmpty)
                    Text(
                      'مُشغَّل: ${realBooth.companyName}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),
          isScrollControlled: true,
        );
      });
    }
  }

  void clearSelection() {
    selectedBooth.value = null;
    selectedBoothPosition.value = null;
  }

  void resetView() {
    transformationController.value = Matrix4.identity();
  }

  void proceedToBooking() {
    final mapBooth = selectedBooth.value;
    if (mapBooth == null || mapBooth.isBooked) return;

    // استخدم BoothModel الحقيقي إن وُجد (يحمل خدماته الديناميكية)
    final boothModel =
        _boothById[mapBooth.id] ??
        BoothModel(
          id: mapBooth.id,
          number: mapBooth.number,
          exhibitionName: mapBooth.hallName,
          imageUrl: '',
          area: mapBooth.area,
          status: 'available',
          price: mapBooth.price,
          endDate: '',
          location: '${mapBooth.hallName} - صف ${mapBooth.row + 1}',
          amenities: mapBooth.amenities,
          isFavorite: false,
        );
    Get.toNamed(AppRoutes.BOOKING_REQUEST, arguments: boothModel);
  }

  MapHallModel? hallForBooth(MapBoothModel booth) =>
      mapData.value?.halls.firstWhereOrNull((h) => h.id == booth.hallId);
}
