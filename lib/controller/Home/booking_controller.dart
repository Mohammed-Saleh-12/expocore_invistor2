import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../data/model/booth/booth_model.dart';
import '../../linkapi.dart';

class BookingController extends GetxController {
  final _crud           = Crud();
  final booth           = Rx<BoothModel?>(null);
  final notesCtrl       = TextEditingController();
  final duration        = 1.obs;
  final status          = StatusRequest.none.obs;
  final isSubmitting    = false.obs;
  final screenService   = false.obs;
  final setupService    = false.obs;
  final securitySvc     = false.obs;
  final cleaningService = false.obs;

  VoidCallback? _onWebSuccess;

  double get total {
    final base   = (booth.value?.price ?? 0) * duration.value;
    final extras = (screenService.value   ? 500.0 : 0) +
                   (setupService.value    ? 800.0 : 0) +
                   (securitySvc.value     ? 300.0 : 0) +
                   (cleaningService.value ? 200.0 : 0);
    return base + extras;
  }

  void setBooth(BoothModel b) => booth.value = b;

  void resetForWeb(BoothModel b, VoidCallback onSuccess) {
    booth.value           = b;
    duration.value        = 1;
    screenService.value   = false;
    setupService.value    = false;
    securitySvc.value     = false;
    cleaningService.value = false;
    status.value          = StatusRequest.none;
    notesCtrl.clear();
    _onWebSuccess         = onSuccess;
  }

  Future<void> submitBooking() async {
    final b = booth.value;
    if (b == null) return;
    status.value = StatusRequest.loading;
    isSubmitting.value = true;

    final result = await _crud.postData(AppLink.bookBooth, {
      'booth_id':         b.id,
      'duration_days':    duration.value,
      'notes':            notesCtrl.text.trim(),
      'screen_service':   screenService.value,
      'setup_service':    setupService.value,
      'security_service': securitySvc.value,
      'cleaning_service': cleaningService.value,
      'total_price':      total,
    });

    if (result['status'] == true) {
      status.value = StatusRequest.success;
      if (Get.key?.currentState?.canPop() ?? false) Get.back();
      Future.delayed(const Duration(milliseconds: 400), () {
        _onWebSuccess?.call();
        _onWebSuccess = null;
      });
      Get.snackbar('booking_submitted_title'.tr, 'booking_submitted_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      status.value = StatusRequest.failure;
      Get.snackbar('error'.tr, result['message'] ?? 'booking_failed_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
    isSubmitting.value = false;
  }

  Future<void> cancelBooking(int bookingId) async {
    final result = await _crud.patchData(AppLink.cancelBooking(bookingId), {});
    if (result['status'] == true) {
      Get.snackbar('booking_cancelled_title'.tr, 'booking_cancelled_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('error'.tr, result['message'] ?? 'booking_cancel_fail_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    notesCtrl.dispose();
    super.onClose();
  }
}
