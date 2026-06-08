import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../linkapi.dart';

class RegisterController extends GetxController {
  final _crud = Crud();
  final companyCtrl = TextEditingController();
  final tradeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final status = StatusRequest.none.obs;
  final obscurePass = true.obs;
  final obscureConf = true.obs;
  final termsAccepted = false.obs;
  final activityType = ''.obs;

  final activityTypes = [
    'تقنية',
    'غذاء وضيافة',
    'موضة',
    'صحة',
    'تعليم',
    'أخرى',
  ];

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    if (!termsAccepted.value) {
      Get.snackbar(
        'خطأ',
        'يجب الموافقة على الشروط والأحكام',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    status.value = StatusRequest.loading;

    final result = await _crud.postData(AppLink.register, {
      'company_name': companyCtrl.text.trim(),
      'trade_name': tradeCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'location': locationCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'website': websiteCtrl.text.trim(),
      'password': passCtrl.text,
      'password_confirmation': confirmCtrl.text,
      'activity_type': activityType.value,
    });

    if (result['status'] == true) {
      status.value = StatusRequest.success;
      Get.offAllNamed(AppRoutes.LOGIN);
      Get.snackbar(
        'تم التسجيل',
        'تم إنشاء حسابك بنجاح. يرجى تسجيل الدخول.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      status.value = StatusRequest.failure;
      Get.snackbar(
        'خطأ في التسجيل',
        result['message'] ?? 'حدث خطأ',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    companyCtrl.dispose();
    tradeCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    websiteCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
