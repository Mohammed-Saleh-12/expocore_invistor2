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

  // معرّف المعرض — يُضبط من الشاشة قبل الانتقال
  int exhibitionId = 0;

  static const bookedCompanies = <int, BoothCompanyInfo>{
    2:  BoothCompanyInfo(name: 'تقنية الغد',    email: 'info@techfuture.sa',    initials: 'تغ', color: Color(0xFF7A1FFF)),
    6:  BoothCompanyInfo(name: 'حلول البيانات', email: 'hello@datasol.com',     initials: 'حب', color: Color(0xFF1565C0)),
    7:  BoothCompanyInfo(name: 'ابتكار ذكي',   email: 'contact@smartinno.sa',  initials: 'اذ', color: Color(0xFF00897B)),
    10: BoothCompanyInfo(name: 'ميديا برو',    email: 'team@mediapro.com',     initials: 'مب', color: Color(0xFFE65100)),
    13: BoothCompanyInfo(name: 'تصميم عصري',   email: 'info@moderndesign.sa',  initials: 'تع', color: Color(0xFF6A1B9A)),
  };

  BoothCompanyInfo? companyForBooth(MapBoothModel booth) =>
      bookedCompanies[booth.id];

  @override
  void onInit() {
    super.onInit();
    // exhibitionId قد يُمرَّر عبر Get.arguments قبل onInit
    final args = Get.arguments;
    if (args is Map && args['exhibition_id'] != null) {
      exhibitionId = args['exhibition_id'] as int;
    } else if (args is int) {
      exhibitionId = args;
    }
    loadMapData();
  }

  @override
  void onClose() {
    transformationController.dispose();
    super.onClose();
  }

  Future<void> loadMapData() async {
    isLoading.value = true;
    if (exhibitionId > 0) {
      final result = await _mapData.getExhibitionMap(exhibitionId);
      if (result['status'] == true) {
        final body = result['data'] is Map
            ? (result['data'] as Map<String, dynamic>)
            : <String, dynamic>{};
        mapData.value   = ExhibitionMapModel.fromJson(body);
        allBooths.value = mapData.value!.halls.expand((h) => h.booths).toList();
        isLoading.value = false;
        return;
      }
    }
    // fallback إلى البيانات الثابتة إذا لم يكن لدينا معرّف أو فشل الطلب
    mapData.value   = ExhibitionMapModel.fromJson(DummyData.exhibitionMap);
    allBooths.value = mapData.value!.halls.expand((h) => h.booths).toList();
    isLoading.value = false;
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
    final booth = selectedBooth.value;
    if (booth == null || booth.isBooked) return;
    final boothModel = BoothModel(
      id:             booth.id,
      number:         booth.number,
      exhibitionName: booth.hallName,
      imageUrl:       '',
      area:           booth.area,
      status:         'pending',
      price:          booth.price,
      endDate:        '',
      location:       '${booth.hallName} - صف ${booth.row + 1}',
      amenities:      booth.amenities,
      isFavorite:     false,
    );
    Get.toNamed(AppRoutes.BOOKING_REQUEST, arguments: boothModel);
  }

  MapHallModel? hallForBooth(MapBoothModel booth) {
    return mapData.value?.halls.firstWhereOrNull((h) => h.id == booth.hallId);
  }
}