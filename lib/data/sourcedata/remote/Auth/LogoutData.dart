import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class LogoutData {
  Crud crud;

  LogoutData(this.crud);

  Future<Map<String, dynamic>> logout() async {
    return await crud.postData(AppLink.logout, {});
  }
}
