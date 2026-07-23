import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class BoothsData {
  final Crud crud;
  BoothsData(this.crud);

  /// جلب أجنحتي (حجوزاتي)
  Future<Map<String, dynamic>> getMyBookings() async {
    return await crud.getData(AppLink.investorBookings);
  }

  /// جلب تفاصيل جناح
  Future<Map<String, dynamic>> getBoothDetail(int id) async {
    return await crud.getData(AppLink.boothDetail(id));
  }
}
