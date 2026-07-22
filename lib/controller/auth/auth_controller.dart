import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';
import '../../data/sourcedata/remote/Auth/AuthData.dart';
import '../../data/sourcedata/remote/Auth/RegisterData.dart';

// ════════════════════════════════════════════════════════════
//  AuthController  —  التسجيل + OTP التحقق من الحساب
// ════════════════════════════════════════════════════════════
class AuthController extends GetxController {
  final _box = GetStorage();
  late final AuthData _authData;
  late final RegisterData _registerData;

  // ── مفاتيح التخزين المحلي ────────────────────────────────
  static const _kPending = 'pendingVerification';
  static const _kEmail   = 'pendingEmail';
  static const _kOtp     = 'pendingOtp';

  // ── State ─────────────────────────────────────────────────
  final isLoading    = false.obs;
  final status       = StatusRequest.none.obs;
  final errorMessage = ''.obs;

  // ── Form controllers (التسجيل) ───────────────────────────
  final companyCtrl  = TextEditingController();
  final tradeCtrl    = TextEditingController();
  final emailCtrl    = TextEditingController();
  final locationCtrl = TextEditingController();
  final phoneCtrl    = TextEditingController();
  final websiteCtrl  = TextEditingController();
  final passCtrl     = TextEditingController();
  final confirmCtrl  = TextEditingController();
  final formKey      = GlobalKey<FormState>();

  final obscurePass    = true.obs;
  final obscureConf    = true.obs;
  final termsAccepted  = false.obs;
  final activityType   = ''.obs;

  final activityTypes = [
    'تقنية',
    'غذاء وضيافة',
    'موضة',
    'صحة',
    'تعليم',
    'أخرى',
  ];

  // ── Getters: جلسة التحقق المعلّقة ───────────────────────
  bool   get hasPendingVerification => _box.read<bool>(_kPending) ?? false;
  String get pendingEmail           => _box.read<String>(_kEmail) ?? '';

  @override
  void onInit() {
    super.onInit();
    final crud = Crud();
    _authData     = AuthData(crud);
    _registerData = RegisterData(crud);
  }

  // ── تسجيل حساب جديد → OTP ───────────────────────────────
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    if (!termsAccepted.value) {
      _showError('يجب الموافقة على الشروط والأحكام');
      return;
    }
    isLoading.value = true;
    status.value    = StatusRequest.loading;
    errorMessage.value = '';

    final result = await _registerData.register(
      companyName:          companyCtrl.text.trim(),
      tradeName:            tradeCtrl.text.trim(),
      email:                emailCtrl.text.trim(),
      location:             locationCtrl.text.trim(),
      phone:                phoneCtrl.text.trim(),
      website:              websiteCtrl.text.trim(),
      password:             passCtrl.text,
      passwordConfirmation: confirmCtrl.text,
      activityType:         activityType.value,
    );

    if (result['status'] == true) {
      // حفظ جلسة التحقق المعلّقة
      final otp = _extractOtp(result);
      _box.write(_kPending, true);
      _box.write(_kEmail,   emailCtrl.text.trim());
      if (otp != null) _box.write(_kOtp, otp);

      status.value = StatusRequest.success;
      Get.toNamed(AppRoutes.OTP);
    } else {
      status.value = StatusRequest.failure;
      _showError(result['message'] ?? 'حدث خطأ في التسجيل');
    }
    isLoading.value = false;
  }

  // ── التحقق من OTP ─────────────────────────────────────────
  Future<void> verifyOtp(String otp) async {
    isLoading.value = true;
    status.value    = StatusRequest.loading;

    // مقارنة محلية أولاً
    final stored = _box.read<String>(_kOtp);
    if (stored != null && stored.isNotEmpty && otp != stored) {
      isLoading.value = false;
      status.value    = StatusRequest.failure;
      _showError('الرمز الذي أدخلته غير صحيح');
      return;
    }

    final result = await _authData.verifyOtp(otp);
    if (result['status'] == true) {
      // حفظ بيانات الجلسة
      final token   = _extractToken(result);
      final company = _extractCompany(result);
      final email   = _extractEmail(result);
      final userId  = _extractUserId(result);
      if (token != null) {
        await Get.find<Services>().saveUserData(
          token:   token,
          company: company ?? companyCtrl.text.trim(),
          email:   email   ?? pendingEmail,
          userId:  userId  ?? 0,
        );
      }

      _clearPending();
      status.value = StatusRequest.success;
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } else {
      status.value = StatusRequest.failure;
      _showError(result['message'] ?? 'رمز خاطئ، حاول مجدداً');
    }
    isLoading.value = false;
  }

  // ── إعادة إرسال OTP ───────────────────────────────────────
  Future<void> resendOtp() async {
    isLoading.value = true;
    try {
      final result = await _authData.resendOtp();
      _box.remove(_kOtp); // OTP قديم لم يعد صالحاً
      if (result['status'] == true) {
        _showSuccess('تم إرسال رمز جديد إلى بريدك الإلكتروني');
      } else {
        _showError(result['message'] ?? 'تعذّر إعادة الإرسال');
      }
    } catch (_) {
      _showError('تعذّر إعادة الإرسال');
    }
    isLoading.value = false;
  }

  // ── Helpers ───────────────────────────────────────────────
  void _clearPending() {
    _box.remove(_kPending);
    _box.remove(_kEmail);
    _box.remove(_kOtp);
  }

  String? _extractOtp(Map<String, dynamic> r) {
    final direct = r['otp'] ?? r['code'] ?? r['verification_code'];
    if (direct != null) return direct.toString();
    final data = r['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['otp'] ?? data['code'] ?? data['verification_code'];
      if (nested != null) return nested.toString();
    }
    return null;
  }

  String? _extractToken(Map<String, dynamic> r) {
    final direct = r['token'] ?? r['access_token'];
    if (direct != null) return direct.toString();
    final data = r['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['token'] ?? data['access_token'];
      if (nested != null) return nested.toString();
    }
    return null;
  }

  String? _extractCompany(Map<String, dynamic> r) {
    return (r['user']?['company_name'] ?? r['data']?['company_name'])
        ?.toString();
  }

  String? _extractEmail(Map<String, dynamic> r) {
    return (r['user']?['email'] ?? r['data']?['email'])?.toString();
  }

  int? _extractUserId(Map<String, dynamic> r) {
    final id = r['user']?['id'] ?? r['data']?['id'];
    if (id is int) return id;
    if (id != null) return int.tryParse(id.toString());
    return null;
  }

  void _showError(String msg) => Get.snackbar(
        'خطأ',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935).withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );

  void _showSuccess(String msg) => Get.snackbar(
        'تم',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

  @override
  void onClose() {
    companyCtrl.dispose();
    tradeCtrl.dispose();
    emailCtrl.dispose();
    locationCtrl.dispose();
    phoneCtrl.dispose();
    websiteCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
