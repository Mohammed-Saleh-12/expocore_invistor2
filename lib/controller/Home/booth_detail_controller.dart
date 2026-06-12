import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class BoothDetailController extends GetxController {
  late BoothModel booth;
  late final RxBool isFavorite;

  @override
  void onInit() {
    super.onInit();
    booth = Get.arguments as BoothModel? ?? DummyData.myBooths.first;
    isFavorite = booth.isFavorite.obs;
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    booth.isFavorite = isFavorite.value;
  }

  Color statusColor(String s, dynamic successColor, dynamic infoColor, dynamic greyColor) {
    if (s == 'active') return successColor;
    if (s == 'available') return infoColor;
    return greyColor;
  }
}
