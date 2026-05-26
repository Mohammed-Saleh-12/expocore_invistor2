import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/booth/booth_model.dart';

class BookingController extends GetxController {
  final booth         = Rx<BoothModel?>(null);
  final notesCtrl     = TextEditingController();
  final duration      = 1.obs;
  final isSubmitting  = false.obs;
  final screenService = false.obs;
  final setupService  = false.obs;
  final securitySvc   = false.obs;
  final cleaningService = false.obs;

  double get total {
    final base   = (booth.value?.price ?? 0) * duration.value;
    final extras = (screenService.value  ? 500.0 : 0) +
                   (setupService.value   ? 800.0 : 0) +
                   (securitySvc.value    ? 300.0 : 0) +
                   (cleaningService.value? 200.0 : 0);
    return base + extras;
  }

  void setBooth(BoothModel b) => booth.value = b;

  Future<void> submitBooking() async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSubmitting.value = false;
    Get.back();
    Get.snackbar('تم الإرسال', 'طلبك قيد المراجعة ⏳', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    notesCtrl.dispose();
    super.onClose();
  }
}
