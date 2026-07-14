import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class ReportsData {
  Crud crud;

  ReportsData(this.crud);

  Future<Map<String, dynamic>> getReports() async {
    return await crud.getData(AppLink.investorReports);
  }
}
