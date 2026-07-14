import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class ResetPasswordData {
  Crud crud;

  ResetPasswordData(this.crud);

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await crud.postData(AppLink.resetPassword, {
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
}
