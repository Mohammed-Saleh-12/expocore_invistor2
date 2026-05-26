import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';

class LoginController extends GetxController {
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey      = GlobalKey<FormState>();
  final status       = StatusRequest.none.obs;
  final obscure      = true.obs;
  final rememberMe   = false.obs;

  void toggleObscure()  => obscure.value = !obscure.value;
  void toggleRemember() => rememberMe.value = !rememberMe.value;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    status.value = StatusRequest.loading;
    await Future.delayed(const Duration(seconds: 1));
    final svc = Get.find<Services>();
    await svc.saveToken('demo_token_12345');
    await svc.saveCompany('شركة المستقبل التقنية');
    status.value = StatusRequest.success;
    Get.offAllNamed(AppRoutes.DASHBOARD);
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
