import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

// أنواع المفضلة المدعومة
// يُرسَل في queryParam: ?type=exhibition | booth | event
class FavoriteType {
  static const exhibition = 'exhibition';
  static const booth      = 'booth';
  static const event      = 'event';
}

class FavoritesData {
  final Crud crud;
  FavoritesData(this.crud);

  /// جلب كل المفضلة مجمّعة (معارض + أجنحة + فعاليات)
  Future<Map<String, dynamic>> getFavorites() async {
    return await crud.getData(AppLink.investorFavorites);
  }

  /// إضافة عنصر للمفضلة
  /// [id]   : معرّف المعرض / الجناح / الفعالية في المسار (route)
  /// [type] : نوع العنصر في queryParam  (exhibition | booth | event)
  Future<Map<String, dynamic>> addFavorite(int id, String type) async {
    return await crud.postData(
      AppLink.favoriteItem(id),
      {},
      params: {'type': type},
    );
  }

  /// حذف عنصر من المفضلة
  /// [id]   : معرّف العنصر في المسار (route)
  /// [type] : نوع العنصر في queryParam  (exhibition | booth | event)
  Future<Map<String, dynamic>> removeFavorite(int id, String type) async {
    return await crud.deleteData(
      AppLink.favoriteItem(id),
      params: {'type': type},
    );
  }
}