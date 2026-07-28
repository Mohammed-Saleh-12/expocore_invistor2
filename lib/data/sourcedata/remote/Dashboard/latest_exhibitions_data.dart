import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

/// مصدر بيانات قسم "أحدث المعارض" في الصفحة الرئيسية (ويب)
/// طلب بسيط بدون Pagination — يجلب القائمة الكاملة دفعةً واحدة
class LatestExhibitionsData {
  final Crud crud;
  LatestExhibitionsData(this.crud);

  /// GET /exhibitions/latest
  Future<Map<String, dynamic>> getLatestExhibitions() async {
    return await crud.getData(AppLink.latestExhibitions);
  }
}
