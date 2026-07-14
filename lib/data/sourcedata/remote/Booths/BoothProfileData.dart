import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class BoothProfileData {
  Crud crud;

  BoothProfileData(this.crud);

  Future<Map<String, dynamic>> getBoothProfile(int boothId) async {
    return await crud.getData(AppLink.boothProfile(boothId));
  }

  Future<Map<String, dynamic>> updateBoothProfile(
    int boothId,
    Map<String, dynamic> body,
  ) async {
    return await crud.putData(AppLink.boothProfile(boothId), body);
  }

  Future<Map<String, dynamic>> getBoothEvents(int boothId) async {
    return await crud.getData(
      AppLink.investorEvents,
      params: {'booth_id': boothId},
    );
  }
}
