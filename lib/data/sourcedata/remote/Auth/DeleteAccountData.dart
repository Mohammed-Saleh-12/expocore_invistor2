import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class DeleteAccountData {
  Crud crud;
  DeleteAccountData(this.crud);

  Future<Map<String, dynamic>> deleteAccount() async {
    return await crud.postData(AppLink.deleteAccount, {});
  }
}
