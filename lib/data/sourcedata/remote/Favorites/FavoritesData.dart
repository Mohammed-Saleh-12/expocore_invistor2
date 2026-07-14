import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class FavoritesData {
  Crud crud;

  FavoritesData(this.crud);

  Future<Map<String, dynamic>> getFavorites() async {
    return await crud.getData(AppLink.investorFavorites);
  }
}
