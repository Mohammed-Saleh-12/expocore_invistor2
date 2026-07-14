import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class BookingData {
  Crud crud;

  BookingData(this.crud);

  Future<Map<String, dynamic>> bookBooth({
    required int boothId,
    required int durationDays,
    required String notes,
    required bool screenService,
    required bool setupService,
    required bool securityService,
    required bool cleaningService,
    required double totalPrice,
  }) async {
    return await crud.postData(AppLink.bookBooth, {
      'booth_id': boothId,
      'duration_days': durationDays,
      'notes': notes,
      'screen_service': screenService,
      'setup_service': setupService,
      'security_service': securityService,
      'cleaning_service': cleaningService,
      'total_price': totalPrice,
    });
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    return await crud.patchData(AppLink.cancelBooking(bookingId), {});
  }
}
