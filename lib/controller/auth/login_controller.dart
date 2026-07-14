import 'package:expocore_invistor2/data/sourcedata/remote/Auth/LoginData.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';

// ════════════════════════════════════════════════════════════
//  LoginController  —  MVC / GetX
// ════════════════════════════════════════════════════════════
class LoginController extends GetxController {
  // ── Dependencies ─────────────────────────────────────────
  late final LoginData _loginData;
  // ── Form ─────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────
  final status = StatusRequest.none.obs;
  final obscure = true.obs;
  final rememberMe = false.obs;

  // ── Demo credentials (حساب تجريبي مؤقت) ─────────────────
  static const String _demoEmail = 'demo@expocore.app';
  static const String _demoPassword = 'Demo@1234';
  static const String _demoToken = 'demo-token-local';
  static const String _demoCompany = 'زائر تجريبي';

  // ── Toggles ───────────────────────────────────────────────
  void toggleObscure() => obscure.value = !obscure.value;
  void toggleRemember() => rememberMe.value = !rememberMe.value;

  /// Fill demo credentials automatically
  void fillDemo() {
    emailCtrl.text = _demoEmail;
    passwordCtrl.text = _demoPassword;
  }

  // ── Login ─────────────────────────────────────────────────
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    status.value = StatusRequest.loading;

    // ── Demo mode ────────────────────────────────────────────
    if (_isDemoCredentials()) {
      await Future.delayed(const Duration(milliseconds: 600));
      await _saveSession(
        _demoToken,
        _demoCompany,
        email: _demoEmail,
        role:  'visitor',
      );
      status.value = StatusRequest.success;
      if (!GetPlatform.isWeb) Get.offAllNamed(AppRoutes.DASHBOARD);
      return;
    }

    // ── Real API call ─────────────────────────────────────────
    final result = await _loginData.login( emailCtrl.text.trim(),
        passwordCtrl.text,
    );

    if (result['status'] == true) {
      final data      = result['data'];
      final token     = _extract(data, ['token', 'access_token', 'data.token']) ?? '';
      final company   = _extract(data, ['company_name', 'user.company_name', 'data.company_name']) ?? 'شركتي';
      final email     = _extract(data, ['email', 'user.email']) ?? '';
      final userId    = (_extract(data, ['id', 'user.id', 'user_id']) as num?)?.toInt() ?? 0;
      final role      = _extract(data, ['role', 'user.role']) ?? 'visitor';
      final expiresIn = (_extract(data, ['expires_in']) as num?)?.toInt() ?? 0;
      await _saveSession(token, company, email: email, userId: userId, role: role, expiresIn: expiresIn);
      status.value = StatusRequest.success;
      if (!GetPlatform.isWeb) Get.offAllNamed(AppRoutes.DASHBOARD);
    } else {
      status.value = StatusRequest.failure;
      _showError(result['message'] ?? 'تحقق من البريد الإلكتروني وكلمة المرور');
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  bool _isDemoCredentials() =>
      emailCtrl.text.trim().toLowerCase() == _demoEmail &&
      passwordCtrl.text == _demoPassword;

  Future<void> _saveSession(
    String token,
    String company, {
    String email = '',
    int userId = 0,
    String role = 'visitor',
    int expiresIn = 0,
  }) async {
    await Get.find<Services>().saveUserData(
      token: token,
      company: company,
      email: email,
      userId: userId,
      role: role,
      tokenExpiresInSeconds: expiresIn,
    );
  }

  void _showError(String message) => Get.snackbar(
    'خطأ في تسجيل الدخول',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFFE53935).withOpacity(0.9),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    duration: const Duration(seconds: 3),
  );

  dynamic _extract(dynamic data, List<String> keys) {
    for (final key in keys) {
      if (key.contains('.')) {
        final parts = key.split('.');
        dynamic val = data;
        for (final p in parts) {
          if (val is Map)
            val = val[p];
          else {
            val = null;
            break;
          }
        }
        if (val != null) return val;
      } else if (data is Map && data[key] != null) {
        return data[key];
      }
    }
    return null;
  }

  // ── Dispose ───────────────────────────────────────────────
  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
