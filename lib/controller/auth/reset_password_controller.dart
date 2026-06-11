import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../linkapi.dart';

// ════════════════════════════════════════════════════════════
//  ResetPasswordController  —  MVC / GetX
//  shared between mobile ResetPasswordView and web WebResetPasswordPage
//
//  Token source:
//   • Web  → extracted from Uri.base query params by WebAuthController
//             and injected via initToken()
//   • Mobile → passed as Get.arguments when navigating to RESET_PW route
// ════════════════════════════════════════════════════════════
class ResetPasswordController extends GetxController {
  // ── Dependencies ─────────────────────────────────────────
  final _crud = Crud();

  // ── Form ─────────────────────────────────────────────────
  final formKey     = GlobalKey<FormState>();
  final passwordCtrl = TextEditingController();
  final confirmCtrl  = TextEditingController();

  // ── State ─────────────────────────────────────────────────
  final status      = StatusRequest.none.obs;
  final done        = false.obs;
  final token       = ''.obs;
  final obscurePass = true.obs;
  final obscureConf = true.obs;

  // ── Derived ───────────────────────────────────────────────
  bool get hasToken => token.value.isNotEmpty;

  // ── Toggles ───────────────────────────────────────────────
  void togglePass() => obscurePass.value = !obscurePass.value;
  void toggleConf() => obscureConf.value = !obscureConf.value;

  // ── Token injection ───────────────────────────────────────
  /// Called by WebAuthController (web) or the route handler (mobile)
  void initToken(String t) => token.value = t.trim();

  // ── Reset password ────────────────────────────────────────
  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;
    if (!hasToken) {
      _showError('reset_error_no_token'.tr);
      return;
    }
    status.value = StatusRequest.loading;

    final result = await _crud.postData(AppLink.resetPassword, {
      'token':                 token.value,
      'password':              passwordCtrl.text,
      'password_confirmation': confirmCtrl.text,
    });

    if (result['status'] == true) {
      status.value = StatusRequest.success;
      done.value   = true;
    } else {
      status.value = StatusRequest.failure;
      _showError(result['message'] ?? 'reset_error_generic'.tr);
    }
  }

  /// Clear form + state (used when navigating back to login)
  void clear() {
    done.value         = false;
    status.value       = StatusRequest.none;
    token.value        = '';
    passwordCtrl.clear();
    confirmCtrl.clear();
  }

  // ── Helpers ───────────────────────────────────────────────
  void _showError(String message) => Get.snackbar(
    'reset_error_title'.tr,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFFE53935).withOpacity(0.9),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    duration: const Duration(seconds: 4),
  );

  // ── Mobile: initialise token from route argument ──────────
  @override
  void onInit() {
    super.onInit();
    if (!GetPlatform.isWeb) {
      final arg = Get.arguments;
      if (arg is String && arg.isNotEmpty) initToken(arg);
    }
  }

  // ── Mobile: go back to login after success ────────────────
  void goToLoginMobile() {
    clear();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  // ── Dispose ───────────────────────────────────────────────
  @override
  void onClose() {
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
