import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class BookingData {
  Crud crud;
  BookingData(this.crud);

  /// إنشاء حجز جديد — POST /booths/book
  /// [services] : Map<String,bool> — الخدمات المختارة ديناميكياً
  Future<Map<String, dynamic>> bookBooth({
    required int              boothId,
    required int              durationDays,
    required String           notes,
    required Map<String, bool> services,   // ← ديناميكي (اسم → مختار)
    required double           totalPrice,
  }) async {
    return await crud.postData(AppLink.bookBooth, {
      'booth_id':      boothId,
      'duration_days': durationDays,
      'notes':         notes,
      'services':      services,
      'total_price':   totalPrice,
    });
  }

  /// جلب تفاصيل حجز واحد — GET /investor/bookings/{id}
  Future<Map<String, dynamic>> getBookingDetail(int bookingId) async {
    return await crud.getData(AppLink.bookingDetail(bookingId));
  }

  /// إلغاء حجز — PATCH /investor/bookings/{id}/cancel
  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    return await crud.patchData(AppLink.cancelBooking(bookingId), {});
  }
}
