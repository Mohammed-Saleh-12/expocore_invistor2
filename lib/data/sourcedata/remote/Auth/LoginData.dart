import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class LoginData {
  Crud crud;
  
  LoginData(this.crud);

  login(String email, String password) async {
    var response =await crud.postData(AppLink.login, {
      'email':       email,
      'password':    password,
    });
    return response;
  }
}
