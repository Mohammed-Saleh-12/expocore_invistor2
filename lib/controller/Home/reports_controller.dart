import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../data/model/report/report_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class ReportsController extends GetxController {
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
  final typeMap     = {'الكل': 'all', 'الزوار': 'visitors', 'الأداء': 'performance', 'الفعاليات': 'events', 'الحملات': 'campaigns', 'المقارنة': 'compare'};

  @override
  void onInit() {
    reports.value  = DummyData.reports;
    filtered.value = reports;
    super.onInit();
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
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      downloadProgress.value = i / 10;
    }
    isDownloading.value = false;
    Get.snackbar('نجاح', 'تم تنزيل التقرير بصيغة ${format.toUpperCase()}', snackPosition: SnackPosition.BOTTOM);
  }
}
