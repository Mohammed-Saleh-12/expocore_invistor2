import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class AnalyticsData {
  Crud crud;

  AnalyticsData(this.crud);

  Future<Map<String, dynamic>> getAnalytics(String period) async {
    return await crud.getData(
      AppLink.investorAnalytics,
      params: {'period': period},
    );
  }
}
