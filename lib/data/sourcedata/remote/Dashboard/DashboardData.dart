import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class DashboardData {
  Crud crud;

  DashboardData(this.crud);

  Future<Map<String, dynamic>> getDashboard(String period) async {
    return await crud.getData(
      AppLink.investorDashboard,
      params: {'period': _apiPeriod(period)},
    );
  }

  String _apiPeriod(String period) {
    switch (period) {
      case 'آخر 3 أشهر':
        return 'quarter';
      case 'هذا العام':
        return 'year';
      default:
        return 'month';
    }
  }
}
