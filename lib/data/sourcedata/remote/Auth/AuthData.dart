import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class AuthData {
  final Crud crud;
  AuthData(this.crud);

  /// التحقق من OTP بعد التسجيل
  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    return await crud.postData(AppLink.verifyOtp, {'otp': otp});
  }

  /// إعادة إرسال OTP (التسجيل)
  Future<Map<String, dynamic>> resendOtp() async {
    return await crud.postData(AppLink.resendOtp, {});
  }
}
