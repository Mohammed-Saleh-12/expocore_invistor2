import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class BookingData {
  Crud crud;

  BookingData(this.crud);

  Future<Map<String, dynamic>> bookBooth(Map<String, dynamic> body) async {
    return await crud.postData(AppLink.bookBooth, body);
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    return await crud.patchData(AppLink.cancelBooking(bookingId), {});
  }
}
