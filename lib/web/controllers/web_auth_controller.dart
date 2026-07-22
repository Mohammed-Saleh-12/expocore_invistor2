import 'package:get/get.dart';
import '../../controller/auth/auth_controller.dart';
import '../../controller/auth/forgot_password_controller.dart';
import '../../controller/auth/login_controller.dart';
import '../../controller/auth/reset_password_controller.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/services/services.dart';

// ════════════════════════════════════════════════════════════
//  CONTROLLER  —  WebAuthController
//  يدير حالة الدخول لطبقة الويب (مفصول عن الـ View)
//  يراقب Login / Register / ForgotPassword / ResetPassword
//
//  تدفق نسيان كلمة المرور (3 خطوات عبر webStep):
//    webStep = 1  →  showForgotPasswordOtp
//    webStep = 2  →  showForgotPasswordReset
//    webStep = 3  →  goToLogin (اكتمل التغيير)
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

  final loggedIn                = false.obs;
  final showRegister            = false.obs;
  final showRegisterOtp         = false.obs; // OTP بعد التسجيل
  final showForgotPassword      = false.obs;
  final showForgotPasswordOtp   = false.obs;
  final showForgotPasswordReset = false.obs;
  final showResetPassword       = false.obs; // deep-link token flow

  @override
  void onInit() {
    super.onInit();
    syncFromSession();
    _detectResetToken();

    // ── مراقبة نجاح تسجيل الدخول ──────────────────────────
    ever(Get.find<LoginController>().status, (StatusRequest s) {
      if (s == StatusRequest.success) markLoggedIn();
    });

    // ── مراقبة تدفق التسجيل + OTP ──────────────────────────
    // webStep=1 → اعرض OTP التسجيل  |  webStep=2 → تسجيل دخول ناجح
    ever(Get.find<AuthController>().webStep, (int step) {
      if (step == 1) _goToRegisterOtp();
      else if (step == 2) markLoggedIn();
    });

    // ── مراقبة خطوات تدفق نسيان كلمة المرور ────────────────
    ever(Get.find<ForgotPasswordController>().webStep, (int step) {
      if (step == 1) _goToForgotPasswordOtp();
      else if (step == 2) _goToForgotPasswordReset();
      else if (step == 3) goToLogin();
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

  void _goToRegisterOtp() {
    _clearAuthScreens();
    showRegisterOtp.value = true;
  }

  void _goToForgotPasswordOtp() {
    _clearAuthScreens();
    showForgotPasswordOtp.value = true;
  }

  void _goToForgotPasswordReset() {
    _clearAuthScreens();
    showForgotPasswordReset.value = true;
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
    showRegister.value            = false;
    showRegisterOtp.value         = false;
    showForgotPassword.value      = false;
    showForgotPasswordOtp.value   = false;
    showForgotPasswordReset.value = false;
    showResetPassword.value       = false;
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
