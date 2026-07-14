import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class ProfileData {
  Crud crud;

  ProfileData(this.crud);

  Future<Map<String, dynamic>> getProfile() async {
    return await crud.getData(AppLink.investorProfile);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    return await crud.putData(AppLink.investorProfile, body);
  }
}
