import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../data/sourcedata/remote/Auth/ForgotPasswordData.dart';

// ════════════════════════════════════════════════════════════
//  ForgotPasswordController  —  MVC / GetX
//  shared between mobile ForgotPasswordView and web WebForgotPasswordPage
// ════════════════════════════════════════════════════════════
class ForgotPasswordController extends GetxController {
  // ── Dependencies ─────────────────────────────────────────
  final ForgotPasswordData _forgotPasswordData = ForgotPasswordData(Crud());

  // ── Form ─────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────
  final status = StatusRequest.none.obs;
  final sent   = false.obs;

  // ── Send reset link ───────────────────────────────────────
  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) return;
    status.value = StatusRequest.loading;

    final result = await _forgotPasswordData.sendResetLink(emailCtrl.text.trim());

    if (result['status'] == true) {
      status.value = StatusRequest.success;
      sent.value   = true;
    } else {
      status.value = StatusRequest.failure;
      _showError(result['message'] ?? 'forgot_error_generic'.tr);
    }
  }

  // ── Reset to form state (re-try or navigate back) ────────
  void reset() {
    sent.value   = false;
    status.value = StatusRequest.none;
    emailCtrl.clear();
  }

  // ── Helpers ───────────────────────────────────────────────
  void _showError(String message) => Get.snackbar(
    'forgot_error_title'.tr,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFFE53935).withOpacity(0.9),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    duration: const Duration(seconds: 3),
  );

  // ── Dispose ───────────────────────────────────────────────
  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}
