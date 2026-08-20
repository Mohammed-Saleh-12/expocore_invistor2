import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

/// مصدر بيانات اللوحات الإعلانية في الصفحة الرئيسية
/// كلا الطلبين يدعمان Pagination (افتراضي: 5 عناصر في كل استدعاء)
class HomeBillboardData {
  final Crud crud;
  HomeBillboardData(this.crud);

  // ── المعارض المميزة ───────────────────────────────────────────────────
  /// GET /exhibitions/featured?page=&per_page=
  Future<Map<String, dynamic>> getFeaturedExhibitions({
    int page = 1,
    int perPage = 5,
  }) async {
    return await crud.getData(
      AppLink.featuredExhibitionsBillboard,
      params: {'page': page, 'per_page': perPage},
    );
  }

  // ── الفعاليات الإعلانية المميزة ───────────────────────────────────────
  /// Use the same normalized sponsor-event contract as the events screen.
  /// This keeps duration_options identical on mobile and web.
  Future<Map<String, dynamic>> getFeaturedSponsorEvents({
    int page = 1,
    int perPage = 5,
  }) async {
    return await crud.getData(
      AppLink.exhibitionSponsorEvents,
      params: {'page': page, 'per_page': perPage},
    );
  }
}
