import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class ExhibitionsData {
  final Crud crud;
  ExhibitionsData(this.crud);

  /// جلب قائمة المعارض مع Pagination
  /// [page]    : رقم الصفحة (يبدأ من 1)
  /// [perPage] : عدد العناصر في الصفحة (افتراضي 15)
  /// [status]  : فلتر الحالة اختياري (upcoming | active | ended)
  Future<Map<String, dynamic>> getExhibitions({
    int page = 1,
    int perPage = 15,
    String? status,
    String? city,
    String? sector,
  }) async {
    final params = <String, dynamic>{
      'page':     page,
      'per_page': perPage,
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (city   != null && city.isNotEmpty)   params['city']   = city;
    if (sector  != null && sector.isNotEmpty) params['sector'] = sector;
    return await crud.getData(AppLink.exhibitions, params: params);
  }

  /// جلب تفاصيل معرض واحد
  Future<Map<String, dynamic>> getExhibitionDetail(int id) async {
    return await crud.getData(AppLink.exhibitionDetail(id));
  }
}
