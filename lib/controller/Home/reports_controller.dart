import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../data/model/report/report_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../linkapi.dart';

class ReportsController extends GetxController {
  final _crud            = Crud();
  final statusRequest    = StatusRequest.none.obs;
  final reports          = <ReportModel>[].obs;
  final filtered         = <ReportModel>[].obs;
  final selectedReport   = Rx<ReportModel?>(null);
  final selectedType     = 'الكل'.obs;
  final dateFrom         = Rx<DateTime?>(null);
  final dateTo           = Rx<DateTime?>(null);
  final isDownloading    = false.obs;
  final downloadProgress = 0.0.obs;

  final typeFilters = ['الكل', 'الزوار', 'الأداء', 'الفعاليات', 'الحملات', 'المقارنة'];
  final typeMap     = {
    'الكل': 'all', 'الزوار': 'visitors', 'الأداء': 'performance',
    'الفعاليات': 'events', 'الحملات': 'campaigns', 'المقارنة': 'compare',
  };

  @override
  void onInit() {
    _loadReports();
    super.onInit();
  }

  Future<void> _loadReports() async {
    statusRequest.value = StatusRequest.loading;
    final result = await _crud.getData(AppLink.investorReports);
    if (result['status'] == true) {
      final list = _asList(result['data']);
      reports.value = list.map((e) => ReportModel.fromJson(e)).toList();
      statusRequest.value = StatusRequest.success;
    } else {
      reports.value = DummyData.reports;
      statusRequest.value = StatusRequest.failure;
    }
    filtered.value = reports;
  }

  void filterByType(String type) {
    selectedType.value = type;
    if (type == 'الكل') {
      filtered.value = reports;
    } else {
      final mapped = typeMap[type] ?? 'all';
      filtered.value = reports.where((r) => r.type == mapped).toList();
    }
  }

  Future<void> downloadReport(String reportId, {String format = 'pdf'}) async {
    isDownloading.value    = true;
    downloadProgress.value = 0;

    final url    = AppLink.reportDownload(reportId, format);
    final result = await _crud.getData(url);

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      downloadProgress.value = i / 10;
    }
    isDownloading.value = false;

    if (result['status'] == true) {
      Get.snackbar('نجاح', 'تم تنزيل التقرير بصيغة ${format.toUpperCase()}',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('تنزيل', 'تم تنزيل التقرير بصيغة ${format.toUpperCase()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> refresh() => _loadReports();

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }
}
