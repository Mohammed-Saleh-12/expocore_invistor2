import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class AuthData {
  final Crud crud;
  AuthData(this.crud);

  /// التحقق من OTP بعد التسجيل
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    return await crud.postData(AppLink.verifyOtp, {'email': email, 'otp': otp});
  }

  /// إعادة إرسال OTP (التسجيل)
  Future<Map<String, dynamic>> resendOtp(String email) async {
    return await crud.postData(AppLink.resendOtp, {'email': email});
  }
}
