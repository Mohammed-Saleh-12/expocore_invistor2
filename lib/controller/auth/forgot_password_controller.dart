import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../data/sourcedata/remote/Auth/ForgotPasswordData.dart';

// ════════════════════════════════════════════════════════════
//  ForgotPasswordController  —  3 خطوات: OTP → تحقق → إعادة تعيين
// ════════════════════════════════════════════════════════════
class ForgotPasswordController extends GetxController {
  final _box = GetStorage();
  late final ForgotPasswordData _data;

  // ── مفاتيح التخزين المحلي ────────────────────────────────
  static const _kEmail = 'fp_email';
  static const _kOtp   = 'fp_otp';
  static const _kStep  = 'fp_step'; // 1=OTP, 2=Reset

  // ── Form controllers (الخطوة 1) ──────────────────────────
  final emailFormCtrl = TextEditingController();
  final formKey       = GlobalKey<FormState>();

  // ── State ─────────────────────────────────────────────────
  final isLoading    = false.obs;
  final status       = StatusRequest.none.obs;
  final errorMessage = ''.obs;
  final savedEmail   = ''.obs;
  final savedOtp     = ''.obs;

  // ── Getters للجلسة المعلّقة ───────────────────────────────
  bool get hasPendingSession  => (_box.read<int>(_kStep) ?? 0) > 0;
  int  get pendingStep        => _box.read<int>(_kStep) ?? 0;

  void resumePendingSession() {
    if (pendingStep == 1) Get.toNamed(AppRoutes.FORGOT_PW_OTP);
    if (pendingStep == 2) Get.toNamed(AppRoutes.RESET_PW);
  }

  void discardSession() => _clearSession();

  @override
  void onInit() {
    super.onInit();
    _data = ForgotPasswordData(Crud());
    savedEmail.value = _box.read<String>(_kEmail) ?? '';
    savedOtp.value   = _box.read<String>(_kOtp)   ?? '';
    emailFormCtrl.text = savedEmail.value;
  }

  // ── الخطوة 1: إرسال OTP إلى الإيميل ─────────────────────
  Future<void> sendOtp(String email) async {
    isLoading.value    = true;
    status.value       = StatusRequest.loading;
    errorMessage.value = '';

    final result = await _data.sendOtp(email);
    if (result['status'] == true) {
      savedEmail.value = email;
      _box.write(_kEmail, email);
      _box.write(_kStep, 1);
      _box.remove(_kOtp);

      status.value = StatusRequest.success;
      Get.toNamed(AppRoutes.FORGOT_PW_OTP);
    } else {
      _handleError(result['message']);
    }
    isLoading.value = false;
  }

  // ── الخطوة 2: التحقق من OTP ───────────────────────────────
  Future<void> verifyOtp(String otp) async {
    isLoading.value    = true;
    status.value       = StatusRequest.loading;
    errorMessage.value = '';

    final result = await _data.verifyOtp(savedEmail.value, otp);
    if (result['status'] == true) {
      savedOtp.value = otp;
      _box.write(_kOtp, otp);
      _box.write(_kStep, 2);

      status.value = StatusRequest.success;
      Get.toNamed(AppRoutes.RESET_PW);
    } else {
      _handleError(result['message']);
    }
    isLoading.value = false;
  }

  // ── الخطوة 3: تعيين كلمة المرور الجديدة ─────────────────
  Future<void> resetPassword(String password, String confirmPassword) async {
    isLoading.value    = true;
    status.value       = StatusRequest.loading;
    errorMessage.value = '';

    final result = await _data.resetPassword(
      email:                savedEmail.value,
      otp:                  savedOtp.value,
      password:             password,
      passwordConfirmation: confirmPassword,
    );

    if (result['status'] == true) {
      _clearSession();
      status.value = StatusRequest.success;
      _showSuccess('تم تغيير كلمة المرور، يمكنك تسجيل الدخول الآن');
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      _handleError(result['message']);
    }
    isLoading.value = false;
  }

  // ── إعادة إرسال OTP (نسيان كلمة المرور) ─────────────────
  Future<void> resendOtp() async {
    if (savedEmail.value.isEmpty) return;
    isLoading.value    = true;
    errorMessage.value = '';

    final result = await _data.resendOtp(savedEmail.value);
    if (result['status'] == true) {
      savedOtp.value = '';
      _box.remove(_kOtp);
      _showSuccess('تم إرسال الرمز مجدداً إلى بريدك الإلكتروني');
    } else {
      _handleError(result['message']);
    }
    isLoading.value = false;
  }

  // ── Helpers ───────────────────────────────────────────────
  void _clearSession() {
    savedEmail.value = '';
    savedOtp.value   = '';
    _box.remove(_kEmail);
    _box.remove(_kOtp);
    _box.remove(_kStep);
    emailFormCtrl.clear();
  }

  void _handleError(dynamic message) {
    status.value       = StatusRequest.failure;
    errorMessage.value = message?.toString() ?? 'حدث خطأ، يرجى المحاولة مجدداً';
    _showError(errorMessage.value);
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
        'تم بنجاح',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

  @override
  void onClose() {
    emailFormCtrl.dispose();
    super.onClose();
  }
}
