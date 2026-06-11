import 'package:get/get.dart';
import '../../controller/auth/forgot_password_controller.dart';
import '../../controller/auth/login_controller.dart';
import '../../controller/auth/register_controller.dart';
import '../../controller/auth/reset_password_controller.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/services/services.dart';

// ════════════════════════════════════════════════════════════
//  CONTROLLER  —  WebAuthController
//  يدير حالة الدخول لطبقة الويب (مفصول عن الـ View)
//  يراقب Login / Register / ForgotPassword / ResetPassword
//
//  Deep-link flow (reset password via email link):
//    1. Backend sends email with link: https://your-app.com/?token=TOKEN
//    2. App loads, onInit() reads Uri.base, extracts ?token=
//    3. Sets showResetPassword = true and injects token into controller
//    4. WebResetPasswordPage is shown automatically
// ════════════════════════════════════════════════════════════
class WebAuthController extends GetxController {
  static WebAuthController get to => Get.isRegistered<WebAuthController>()
      ? Get.find<WebAuthController>()
      : Get.put(WebAuthController(), permanent: true);

  final loggedIn            = false.obs;
  final showRegister        = false.obs;
  final showForgotPassword  = false.obs;
  final showResetPassword   = false.obs;

  @override
  void onInit() {
    super.onInit();
    syncFromSession();
    _detectResetToken();

    // ── مراقبة نجاح تسجيل الدخول ──────────────────────────
    ever(Get.find<LoginController>().status, (StatusRequest s) {
      if (s == StatusRequest.success) markLoggedIn();
    });

    // ── مراقبة نجاح إنشاء الحساب ──────────────────────────
    ever(Get.find<RegisterController>().status, (StatusRequest s) {
      if (s == StatusRequest.success) goToLogin();
    });
  }

  // ── Navigation ────────────────────────────────────────────
  void goToRegister() {
    _clearAuthScreens();
    showRegister.value = true;
  }

  void goToLogin() {
    _clearAuthScreens();
    _resetForgotState();
    _resetResetState();
  }

  void goToForgotPassword() {
    _clearAuthScreens();
    _resetForgotState();
    showForgotPassword.value = true;
  }

  void goToResetPassword(String token) {
    _clearAuthScreens();
    _resetResetState();
    try { Get.find<ResetPasswordController>().initToken(token); } catch (_) {}
    showResetPassword.value = true;
  }

  // ── Session ───────────────────────────────────────────────
  void syncFromSession() => loggedIn.value = _sessionValid();
  void markLoggedIn()    => loggedIn.value = true;

  void logout() {
    try { Get.find<Services>().clearSession(); } catch (_) {}
    loggedIn.value = false;
  }

  // ── Deep-link token detection (web only) ─────────────────
  /// Reads the browser URL on startup. If ?token= is present,
  /// switches directly to the reset-password screen.
  /// Expected email link format: https://your-app.com/?token=TOKEN
  void _detectResetToken() {
    if (!GetPlatform.isWeb) return;
    try {
      final token = Uri.base.queryParameters['token'] ?? '';
      if (token.isNotEmpty) {
        goToResetPassword(token);
      }
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────
  void _clearAuthScreens() {
    showRegister.value       = false;
    showForgotPassword.value = false;
    showResetPassword.value  = false;
  }

  bool _sessionValid() {
    try { return Get.find<Services>().isLoggedIn; } catch (_) { return false; }
  }

  void _resetForgotState() {
    try { Get.find<ForgotPasswordController>().reset(); } catch (_) {}
  }

  void _resetResetState() {
    try { Get.find<ResetPasswordController>().clear(); } catch (_) {}
  }
}
