import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/map/exhibition_map_model.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../core/constant/routes.dart';

class BoothMapController extends GetxController {
  final mapData        = Rxn<ExhibitionMapModel>();
  final selectedBooth  = Rxn<MapBoothModel>();
  final isLoading      = true.obs;
  final allBooths      = <MapBoothModel>[].obs;

  final transformationController = TransformationController();

  @override
  void onInit() {
    super.onInit();
    loadMapData();
  }

  @override
  void onClose() {
    transformationController.dispose();
    super.onClose();
  }

  Future<void> loadMapData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 100));
    mapData.value = ExhibitionMapModel.fromJson(DummyData.exhibitionMap);
    allBooths.value = mapData.value!.halls
        .expand((h) => h.booths)
        .toList();
    isLoading.value = false;
  }

  void onBoothTapped(MapBoothModel booth) {
    if (booth.isBooked) return;
    if (selectedBooth.value?.id == booth.id) {
      selectedBooth.value = null;
    } else {
      selectedBooth.value = booth;
    }
  }

  void clearSelection() => selectedBooth.value = null;

  void resetView() {
    transformationController.value = Matrix4.identity();
  }

  void proceedToBooking() {
    final booth = selectedBooth.value;
    if (booth == null) return;
    final boothModel = BoothModel(
      id: booth.id,
      number: booth.number,
      exhibitionName: booth.hallName,
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
      area: booth.area,
      status: 'pending',
      price: booth.price,
      endDate: '2026-07-20',
      location: '${booth.hallName} - صف ${booth.row + 1}',
      amenities: booth.amenities,
      isFavorite: false,
    );
    Get.toNamed(AppRoutes.BOOKING_REQUEST, arguments: boothModel);
  }

  MapHallModel? hallForBooth(MapBoothModel booth) {
    return mapData.value?.halls
        .firstWhereOrNull((h) => h.id == booth.hallId);
  }
}
