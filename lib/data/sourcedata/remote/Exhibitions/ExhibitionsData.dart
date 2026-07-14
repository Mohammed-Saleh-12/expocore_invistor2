import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class ExhibitionsData {
  Crud crud;

  ExhibitionsData(this.crud);

  Future<Map<String, dynamic>> getExhibitions() async {
    return await crud.getData(AppLink.exhibitions);
  }

  Future<Map<String, dynamic>> addFavorite(int exhibitionId) async {
    return await crud.postData(AppLink.favoriteExhibition(exhibitionId), {});
  }

  Future<Map<String, dynamic>> removeFavorite(int exhibitionId) async {
    return await crud.deleteData(AppLink.favoriteExhibition(exhibitionId));
  }
}
