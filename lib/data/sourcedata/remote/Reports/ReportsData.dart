import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class ReportsData {
  Crud crud;

  ReportsData(this.crud);

  /// جلب قائمة التقارير — GET /investor/reports
  Future<Map<String, dynamic>> getReports() async {
    return await crud.getData(AppLink.investorReports);
  }

  /// جلب تفاصيل تقرير واحد — GET /investor/reports/{id}
  Future<Map<String, dynamic>> getReportDetail(String reportId) async {
    return await crud.getData(AppLink.reportDetail(reportId));
  }

  /// رابط تنزيل تقرير — GET /investor/reports/{id}/download?format={fmt}
  /// يُعيد Map تحتوي على ['url'] لتمريرها لـ DownloadService
  String getDownloadUrl(String reportId, String format) {
    return AppLink.reportDownload(reportId, format);
  }
}
