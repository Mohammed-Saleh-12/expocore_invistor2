import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';
import '../../linkapi.dart';

class LoginController extends GetxController {
  final _crud        = Crud();
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

    final result = await _crud.postData(AppLink.login, {
      'email':       emailCtrl.text.trim(),
      'password':    passwordCtrl.text,
      'remember_me': rememberMe.value,
    });

    if (result['status'] == true) {
      final data = result['data'];
      final token   = _extract(data, ['token', 'access_token']) ?? '';
      final company = _extract(data, ['company_name', 'user.company_name']) ?? 'شركتي';
      final svc = Get.find<Services>();
      await svc.saveToken(token);
      await svc.saveCompany(company);
      status.value = StatusRequest.success;
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } else {
      status.value = StatusRequest.failure;
      Get.snackbar(
        'خطأ في تسجيل الدخول',
        result['message'] ?? 'تحقق من البيانات',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  dynamic _extract(dynamic data, List<String> keys) {
    for (final key in keys) {
      if (key.contains('.')) {
        final parts = key.split('.');
        dynamic val = data;
        for (final p in parts) {
          if (val is Map) val = val[p];
          else { val = null; break; }
        }
        if (val != null) return val;
      } else if (data is Map && data[key] != null) {
        return data[key];
      }
    }
    return null;
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
