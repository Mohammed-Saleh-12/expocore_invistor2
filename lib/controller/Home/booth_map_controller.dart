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
  final Color  color;
  const BoothCompanyInfo({
    required this.name,
    required this.email,
    required this.initials,
    required this.color,
  });
}

class BoothMapController extends GetxController {
  final ExhibitionMapData _mapData = ExhibitionMapData(Crud());

  final mapData               = Rxn<ExhibitionMapModel>();
  final selectedBooth         = Rxn<MapBoothModel>();
  final selectedBoothPosition = Rxn<Offset>();
  final isLoading             = true.obs;
  final allBooths             = <MapBoothModel>[].obs;

  final transformationController = TransformationController();
  final hitAreas = <BoothHitArea>[];

  int exhibitionId = 0;

  // ── ربط id الجناح في الخريطة بـ BoothModel الحقيقي ──────────
  final _boothById = <int, BoothModel>{};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['exhibition_id'] != null) {
      exhibitionId = args['exhibition_id'] as int;
    } else if (args is int) {
      exhibitionId = args;
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
    // بناء جدول البحث السريع id → BoothModel
    _boothById.clear();
    for (final b in booths) {
      _boothById[b.id] = b;
    }

    if (mapJson != null && mapJson.isNotEmpty) {
      final model = ExhibitionMapModel.fromJson(mapJson);
      mapData.value   = model;
      final flat      = model.halls.expand((h) => h.booths).toList();
      // مزامنة حالة كل جناح من الخريطة مع الـ API
      for (final mb in flat) {
        final real = _boothById[mb.id];
        if (real != null) mb.status = real.status;
      }
      allBooths.value = flat;
      isLoading.value = false;
    } else if (mapData.value == null) {
      // fallback إذا لم تأت بيانات خريطة من التفاصيل
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
        final model     = ExhibitionMapModel.fromJson(body);
        mapData.value   = model;
        final flat      = model.halls.expand((h) => h.booths).toList();
        // مزامنة الحالات إذا توفرت بيانات الأجنحة
        for (final mb in flat) {
          final real = _boothById[mb.id];
          if (real != null) mb.status = real.status;
        }
        allBooths.value = flat;
        isLoading.value = false;
        return;
      }
    }
    // fallback بيانات ثابتة
    final model     = ExhibitionMapModel.fromJson(DummyData.exhibitionMap);
    mapData.value   = model;
    allBooths.value = model.halls.expand((h) => h.booths).toList();
    isLoading.value = false;
  }

  // ── الجناح الحقيقي المرتبط بـ MapBoothModel ──────────────────
  BoothModel? linkedBooth(MapBoothModel mapBooth) =>
      _boothById[mapBooth.id];

  // ── معلومات الشركة الحاجزة (من الـ API) ─────────────────────
  BoothCompanyInfo? companyForBooth(MapBoothModel booth) {
    final real = _boothById[booth.id];
    if (real != null && (real.companyName?.isNotEmpty ?? false)) {
      return BoothCompanyInfo(
        name:     real.companyName!,
        email:    real.companyEmail    ?? '',
        initials: real.companyInitials ?? real.companyName![0],
        color:    const Color(0xFF7A1FFF),
      );
    }
    // fallback: اسم افتراضي إذا كان الجناح محجوزاً
    if (booth.isBooked) {
      return const BoothCompanyInfo(
        name:     'شركة محجوزة',
        email:    '—',
        initials: 'ش',
        color:    Color(0xFF7A1FFF),
      );
    }
    return null;
  }

  void onBoothTapped(MapBoothModel booth, {Offset? screenPosition}) {
    if (selectedBooth.value?.id == booth.id) {
      clearSelection();
    } else {
      selectedBooth.value         = booth;
      selectedBoothPosition.value = screenPosition;
    }
  }

  void clearSelection() {
    selectedBooth.value         = null;
    selectedBoothPosition.value = null;
  }

  void resetView() {
    transformationController.value = Matrix4.identity();
  }

  void proceedToBooking() {
    final mapBooth = selectedBooth.value;
    if (mapBooth == null || mapBooth.isBooked) return;

    // استخدم BoothModel الحقيقي إن وُجد (يحمل خدماته الديناميكية)
    final boothModel = _boothById[mapBooth.id] ?? BoothModel(
      id:             mapBooth.id,
      number:         mapBooth.number,
      exhibitionName: mapBooth.hallName,
      imageUrl:       '',
      area:           mapBooth.area,
      status:         'available',
      price:          mapBooth.price,
      endDate:        '',
      location:       '${mapBooth.hallName} - صف ${mapBooth.row + 1}',
      amenities:      mapBooth.amenities,
      isFavorite:     false,
    );
    Get.toNamed(AppRoutes.BOOKING_REQUEST, arguments: boothModel);
  }

  MapHallModel? hallForBooth(MapBoothModel booth) =>
      mapData.value?.halls.firstWhereOrNull((h) => h.id == booth.hallId);
}
