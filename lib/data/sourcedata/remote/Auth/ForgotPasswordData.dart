import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class ForgotPasswordData {
  final Crud crud;
  ForgotPasswordData(this.crud);

  /// الخطوة 1: إرسال OTP إلى الإيميل
  Future<Map<String, dynamic>> sendOtp(String email) async {
    return await crud.postData(AppLink.forgotPassword, {'email': email});
  }

  /// الخطوة 2: التحقق من OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    return await crud.postData(
        AppLink.verifyForgotOtp, {'email': email, 'otp': otp});
  }

  /// الخطوة 3: تعيين كلمة المرور الجديدة
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await crud.postData(AppLink.resetPassword, {
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  /// إعادة إرسال OTP (نسيان كلمة المرور)
  Future<Map<String, dynamic>> resendOtp(String email) async {
    return await crud.postData(AppLink.resendForgotOtp, {'email': email});
  }
}
