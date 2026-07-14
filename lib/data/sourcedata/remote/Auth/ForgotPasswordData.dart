import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class ForgotPasswordData {
  Crud crud;

  ForgotPasswordData(this.crud);

  Future<Map<String, dynamic>> sendResetLink(String email) async {
    return await crud.postData(AppLink.forgotPassword, {
      'email': email,
    });
  }
}
