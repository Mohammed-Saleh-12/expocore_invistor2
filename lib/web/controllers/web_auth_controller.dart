import 'package:get/get.dart';
import '../../controller/auth/forgot_password_controller.dart';
import '../../controller/auth/login_controller.dart';
import '../../controller/auth/register_controller.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/services/services.dart';

// ════════════════════════════════════════════════════════════
//  CONTROLLER  —  WebAuthController
//  يدير حالة الدخول لطبقة الويب (مفصول عن الـ View)
//  يراقب LoginController و RegisterController و ForgotPasswordController
//  وفق نمط MVC — التنسيق بين الكنترولرات يتم هنا، لا في الـ View
// ════════════════════════════════════════════════════════════
class WebAuthController extends GetxController {
  /// accessor آمن — يُنشئ الكنترولر عند أول استخدام
  static WebAuthController get to => Get.isRegistered<WebAuthController>()
      ? Get.find<WebAuthController>()
      : Get.put(WebAuthController(), permanent: true);

  final loggedIn          = false.obs;
  final showRegister      = false.obs;
  final showForgotPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    syncFromSession();

    // ── مراقبة نجاح تسجيل الدخول من LoginController ─────────
    ever(Get.find<LoginController>().status, (StatusRequest s) {
      if (s == StatusRequest.success) markLoggedIn();
    });

    // ── مراقبة نجاح إنشاء الحساب من RegisterController ──────
    ever(Get.find<RegisterController>().status, (StatusRequest s) {
      if (s == StatusRequest.success) goToLogin();
    });

    // ── مراقبة نجاح إرسال رابط الاستعادة ────────────────────
    // لا حاجة للتنقل هنا — الـ View يعرض حالة النجاح مباشرةً
  }

  // ── Navigation ────────────────────────────────────────────
  void goToRegister() {
    showForgotPassword.value = false;
    showRegister.value       = true;
  }

  void goToLogin() {
    showRegister.value       = false;
    showForgotPassword.value = false;
    _resetForgotState();
  }

  void goToForgotPassword() {
    showRegister.value       = false;
    showForgotPassword.value = true;
    _resetForgotState();
  }

  // ── Session ───────────────────────────────────────────────
  void syncFromSession() => loggedIn.value = _sessionValid();

  void markLoggedIn() => loggedIn.value = true;

  void logout() {
    try { Get.find<Services>().clearSession(); } catch (_) {}
    loggedIn.value = false;
  }

  // ── Helpers ───────────────────────────────────────────────
  bool _sessionValid() {
    try { return Get.find<Services>().isLoggedIn; } catch (_) { return false; }
  }

  void _resetForgotState() {
    try {
      final fc = Get.find<ForgotPasswordController>();
      fc.reset();
    } catch (_) {}
  }
}
