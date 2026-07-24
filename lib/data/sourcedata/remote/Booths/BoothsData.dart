import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class BoothsData {
  final Crud crud;
  BoothsData(this.crud);

  /// جلب أجنحتي (حجوزاتي) — GET /investor/bookings
  Future<Map<String, dynamic>> getMyBookings() async {
    return await crud.getData(AppLink.investorBookings);
  }

  /// جلب تفاصيل جناح محجوز — GET /investor/bookings/{id}
  Future<Map<String, dynamic>> getBookingDetail(int bookingId) async {
    return await crud.getData(AppLink.bookingDetail(bookingId));
  }

  /// جلب الأجنحة الخاصة بمعرض معين — GET /booths?exhibition_id={id}
  /// يُستدعى عند الدخول إلى صفحة تفاصيل المعرض
  Future<Map<String, dynamic>> getExhibitionBooths(int exhibitionId) async {
    return await crud.getData(AppLink.booths, params: {
      'exhibition_id': exhibitionId,
      'per_page':      100,
    });
  }

  /// جلب الأجنحة المتاحة للحجز — GET /booths
  /// [exhibitionId] : فلتر اختياري للمعرض
  /// [status]       : فلتر الحالة (available, booked, ...)
  Future<Map<String, dynamic>> getAvailableBooths({
    int?    exhibitionId,
    String? status,
    int     page    = 1,
    int     perPage = 20,
  }) async {
    final params = <String, dynamic>{
      'page':     page,
      'per_page': perPage,
    };
    if (exhibitionId != null) params['exhibition_id'] = exhibitionId;
    if (status != null && status.isNotEmpty) params['status'] = status;
    return await crud.getData(AppLink.booths, params: params);
  }

  /// جلب تفاصيل جناح واحد — GET /booths/{id}
  Future<Map<String, dynamic>> getBoothDetail(int id) async {
    return await crud.getData(AppLink.boothDetail(id));
  }
}
