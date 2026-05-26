import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/constant/routes.dart';

class RegisterController extends GetxController {
  final companyCtrl  = TextEditingController();
  final tradeCtrl    = TextEditingController();
  final emailCtrl    = TextEditingController();
  final phoneCtrl    = TextEditingController();
  final websiteCtrl  = TextEditingController();
  final passCtrl     = TextEditingController();
  final confirmCtrl  = TextEditingController();
  final formKey      = GlobalKey<FormState>();
  final status       = StatusRequest.none.obs;
  final obscurePass  = true.obs;
  final obscureConf  = true.obs;
  final termsAccepted = false.obs;
  final activityType = ''.obs;

  final activityTypes = ['تقنية', 'غذاء وضيافة', 'موضة', 'صحة', 'تعليم', 'أخرى'];

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    if (!termsAccepted.value) {
      Get.snackbar('خطأ', 'يجب الموافقة على الشروط والأحكام', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    status.value = StatusRequest.loading;
    await Future.delayed(const Duration(seconds: 1));
    status.value = StatusRequest.success;
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  @override
  void onClose() {
    companyCtrl.dispose(); tradeCtrl.dispose(); emailCtrl.dispose();
    phoneCtrl.dispose(); websiteCtrl.dispose(); passCtrl.dispose(); confirmCtrl.dispose();
    super.onClose();
  }
}
