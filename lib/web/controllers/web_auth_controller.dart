import 'package:get/get.dart';
import '../../controller/auth/login_controller.dart';
import '../../controller/auth/register_controller.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/services/services.dart';

// ════════════════════════════════════════════════════════════
//  CONTROLLER  —  WebAuthController
//  يدير حالة الدخول لطبقة الويب (مفصول عن الـ View)
//  يراقب LoginController و RegisterController ويتفاعل معهما
//  وفق نمط MVC — التنسيق بين الكنترولرات يتم هنا، لا في الـ View
// ════════════════════════════════════════════════════════════
class WebAuthController extends GetxController {
  /// accessor آمن — يُنشئ الكنترولر عند أول استخدام
  static WebAuthController get to => Get.isRegistered<WebAuthController>()
      ? Get.find<WebAuthController>()
      : Get.put(WebAuthController(), permanent: true);

  final loggedIn     = false.obs;
  final showRegister = false.obs;

  @override
  void onInit() {
    super.onInit();
    syncFromSession();

    // ── مراقبة نجاح تسجيل الدخول من LoginController ─────────
    // التنسيق بين الكنترولرات مسؤولية الكنترولر، لا الـ View
    ever(Get.find<LoginController>().status, (StatusRequest s) {
      if (s == StatusRequest.success) markLoggedIn();
    });

    // ── مراقبة نجاح إنشاء الحساب من RegisterController ──────
    // عند نجاح التسجيل → العودة لشاشة الدخول تلقائياً
    ever(Get.find<RegisterController>().status, (StatusRequest s) {
      if (s == StatusRequest.success) goToLogin();
    });
  }

  void goToRegister() => showRegister.value = true;
  void goToLogin()    => showRegister.value = false;

  /// مزامنة الحالة من الجلسة المحفوظة
  void syncFromSession() => loggedIn.value = _sessionValid();

  /// تفعيل الدخول (بعد نجاح تسجيل الدخول)
  void markLoggedIn() => loggedIn.value = true;

  /// تسجيل الخروج
  void logout() {
    try { Get.find<Services>().clearSession(); } catch (_) {}
    loggedIn.value = false;
  }

  bool _sessionValid() {
    try { return Get.find<Services>().isLoggedIn; } catch (_) { return false; }
  }
}
