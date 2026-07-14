import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class DashboardData {
  Crud crud;

  DashboardData(this.crud);

  Future<Map<String, dynamic>> getDashboard(String period) async {
    return await crud.getData(
      AppLink.investorDashboard,
      params: {'period': period},
    );
  }
}
