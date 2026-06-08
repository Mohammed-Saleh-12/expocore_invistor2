import 'package:get/get.dart';
import '../../core/services/services.dart';

// ════════════════════════════════════════════════════════════
//  CONTROLLER  —  WebAuthController
//  يدير حالة الدخول لطبقة الويب (مفصول عن الـ View)
// ════════════════════════════════════════════════════════════
class WebAuthController extends GetxController {
  /// accessor آمن — يُنشئ الكنترولر عند أول استخدام
  static WebAuthController get to => Get.isRegistered<WebAuthController>()
      ? Get.find<WebAuthController>()
      : Get.put(WebAuthController(), permanent: true);

  final loggedIn    = false.obs;
  final showRegister = false.obs; // التبديل بين الدخول والتسجيل

  @override
  void onInit() {
    syncFromSession();
    super.onInit();
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
