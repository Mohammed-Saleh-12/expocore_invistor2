import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class BoothsData {
  Crud crud;

  BoothsData(this.crud);

  Future<Map<String, dynamic>> getMyBookings() async {
    return await crud.getData(AppLink.investorBookings);
  }

  Future<Map<String, dynamic>> addFavorite(int boothId) async {
    return await crud.postData(AppLink.favoriteBooth(boothId), {});
  }

  Future<Map<String, dynamic>> removeFavorite(int boothId) async {
    return await crud.deleteData(AppLink.favoriteBooth(boothId));
  }
}
