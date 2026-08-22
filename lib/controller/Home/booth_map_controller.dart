import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/model/map/exhibition_map_model.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/sourcedata/remote/Exhibitions/ExhibitionMapData.dart';
import '../../data/sourcedata/remote/Booths/BoothsData.dart';
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
  final BoothsData _boothsData = BoothsData(Crud());

  final mapData = Rxn<ExhibitionMapModel>();
  final selectedBooth = Rxn<MapBoothModel>();
  final selectedBoothPosition = Rxn<Offset>();
  final isLoading = true.obs;
  final allBooths = <MapBoothModel>[].obs;

  final transformationController = TransformationController();
  final hitAreas = <BoothHitArea>[];

  int exhibitionId = 0;
  int _mapRequestVersion = 0;
  Timer? _companyDialogTimer;

  // ── ربط id الجناح في الخريطة بـ BoothModel الحقيقي ──────────
  final _boothById = <int, BoothModel>{};
  final _sceneInstanceById = <String, MapSceneInstance>{};

  Map<int, BoothModel> get boothLookup => Map.unmodifiable(_boothById);

  @override
  void onInit() {
    super.onInit();
    exhibitionId = _readExhibitionId(Get.arguments);
    isLoading.value = false;
  }

  int _readExhibitionId(dynamic args) {
    if (args is Map &&
        (args['exhibition_id'] != null || args['exhibitionId'] != null)) {
      return int.tryParse(
            (args['exhibition_id'] ?? args['exhibitionId']).toString(),
          ) ??
          0;
    }
    if (args is int) return args;
    if (args is String) return int.tryParse(args) ?? 0;
    return 0;
  }

  /// Reconfigure the reused controller when navigation opens another exhibition.
  void ensureExhibition(int requestedId) {
    if (requestedId <= 0) {
      if (mapData.value != null) {
        debugPrint('[Map] Missing exhibition_id; refusing to reuse old map');
        mapData.value = null;
        isLoading.value = false;
      }
      return;
    }
    if (requestedId == exhibitionId &&
        (mapData.value != null || isLoading.value)) {
      return;
    }
    exhibitionId = requestedId;
    _mapRequestVersion++;
    mapData.value = null;
    selectedBooth.value = null;
    selectedBoothPosition.value = null;
    allBooths.clear();
    _boothById.clear();
    isLoading.value = true;
    loadMapData();
  }

  @override
  void onClose() {
    _companyDialogTimer?.cancel();
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
    final requestVersion = ++_mapRequestVersion;
    final requestedExhibitionId = exhibitionId;
    isLoading.value = true;
    if (requestedExhibitionId > 0) {
      try {
        final boothsResult = await _boothsData.getExhibitionBooths(
          requestedExhibitionId,
        );
        if (requestVersion != _mapRequestVersion ||
            requestedExhibitionId != exhibitionId) {
          return;
        }
        final rawBooths = boothsResult['data'];
        if (rawBooths is List) {
          setExhibitionBooths(
            rawBooths
                .whereType<Map>()
                .map(
                  (booth) =>
                      BoothModel.fromJson(Map<String, dynamic>.from(booth)),
                )
                .toList(),
          );
        }
      } catch (error) {
        debugPrint('[Map] Could not load exhibition booths: $error');
      }
      final result = await _mapData.getExhibitionMap(requestedExhibitionId);
      if (requestVersion != _mapRequestVersion ||
          requestedExhibitionId != exhibitionId) {
        return;
      }
      if (result['status'] == true) {
        final body = _mapBody(result['data']);
        if (body.isEmpty) {
          isLoading.value = false;
          debugPrint(
            '[Map] Empty map payload for exhibition $requestedExhibitionId',
          );
          return;
        }
        final responseExhibitionId = int.tryParse(
          (body['exhibition_id'] ?? body['exhibitionId'] ?? '').toString(),
        );
        if (responseExhibitionId != null &&
            responseExhibitionId != requestedExhibitionId) {
          debugPrint(
            '[Map] Ignoring map for exhibition $responseExhibitionId; '
            'requested $requestedExhibitionId',
          );
          isLoading.value = false;
          return;
        }
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
    if (requestVersion != _mapRequestVersion ||
        requestedExhibitionId != exhibitionId) {
      return;
    }
    if (requestedExhibitionId > 0) {
      mapData.value = null;
      allBooths.clear();
      isLoading.value = false;
      debugPrint(
        '[Map] No published map for exhibition $requestedExhibitionId',
      );
      return;
    }
    mapData.value = null;
    allBooths.clear();
    isLoading.value = false;
    debugPrint('[Map] Cannot load map without a valid exhibition id');
  }

  Map<String, dynamic> _mapBody(dynamic raw) {
    if (raw is! Map) return <String, dynamic>{};
    final map = Map<String, dynamic>.from(raw);
    final nested = map['data'];
    if (nested is Map &&
        (map['scene'] == null &&
            map['instances'] == null &&
            map['halls'] == null)) {
      return Map<String, dynamic>.from(nested);
    }
    return map;
  }

  // ── الجناح الحقيقي المرتبط بـ MapBoothModel ──────────────────
  BoothModel? linkedBooth(MapBoothModel mapBooth) {
    final byId = _boothById[mapBooth.id];
    if (byId != null) return byId;
    final requestedNumber = mapBooth.number.trim().toLowerCase();
    for (final booth in _boothById.values) {
      if (booth.number.trim().toLowerCase() == requestedNumber) return booth;
    }
    return null;
  }

  // ── معلومات الشركة الحاجزة (من الـ API) ─────────────────────
  BoothCompanyInfo? companyForBooth(MapBoothModel booth) {
    final real = linkedBooth(booth);
    if (real != null && real.companyName?.isNotEmpty == true) {
      return BoothCompanyInfo(
        name: real.companyName!,
        email: real.companyEmail ?? '',
        initials: real.companyInitials ?? real.companyName![0],
        color: const Color(0xFF7A1FFF),
      );
    }
    if (booth.isBooked) {
      return const BoothCompanyInfo(
        name: 'بيانات الشركة غير متاحة',
        email: '—',
        initials: 'ش',
        color: Color(0xFF7A1FFF),
      );
    }
    return null;
  }

  void onBoothTapped(MapBoothModel booth, {Offset? screenPosition}) {
    _companyDialogTimer?.cancel();
    if (selectedBooth.value?.id == booth.id) {
      clearSelection();
      return;
    }

    selectedBooth.value = booth;
    selectedBoothPosition.value = screenPosition;

    final realBooth = linkedBooth(booth);
    if (realBooth != null) {
      booth.status = realBooth.status;
    }
    if (booth.isBooked) {
      _companyDialogTimer = Timer(const Duration(seconds: 3), clearSelection);
    }
  }

  void clearSelection() {
    _companyDialogTimer?.cancel();
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
        linkedBooth(mapBooth) ??
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
