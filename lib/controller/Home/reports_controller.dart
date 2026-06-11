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

  // ── Derived helpers ───────────────────────────────────────
  bool get hasDateFilter => dateFrom.value != null || dateTo.value != null;

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
    applyFilters();
  }

  // ── Filter by type chip ───────────────────────────────────
  void filterByType(String type) {
    selectedType.value = type;
    applyFilters();
  }

  // ── Filter by date range ──────────────────────────────────
  void filterByDate(DateTime? from, DateTime? to) {
    dateFrom.value = from;
    dateTo.value   = to;
    applyFilters();
  }

  // ── Clear date filter only ────────────────────────────────
  void clearDateFilter() {
    dateFrom.value = null;
    dateTo.value   = null;
    applyFilters();
  }

  // ── Combined filter (type + date range) ──────────────────
  void applyFilters() {
    Iterable<ReportModel> list = reports;

    // Type filter
    if (selectedType.value != 'الكل') {
      final mapped = typeMap[selectedType.value] ?? 'all';
      list = list.where((r) => r.type == mapped);
    }

    // Date-from filter — keep reports whose creation date >= dateFrom
    if (dateFrom.value != null) {
      final from = DateTime(
        dateFrom.value!.year,
        dateFrom.value!.month,
        dateFrom.value!.day,
      );
      list = list.where((r) {
        final d = _parseDate(r.createdAt);
        return d == null || !d.isBefore(from);
      });
    }

    // Date-to filter — keep reports whose creation date <= dateTo
    if (dateTo.value != null) {
      final to = DateTime(
        dateTo.value!.year,
        dateTo.value!.month,
        dateTo.value!.day,
        23, 59, 59,
      );
      list = list.where((r) {
        final d = _parseDate(r.createdAt);
        return d == null || !d.isAfter(to);
      });
    }

    filtered.value = list.toList();
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

  /// Format a DateTime for display (controller responsibility, not view)
  String formatDate(DateTime? d) {
    if (d == null) return '';
    final m   = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  Future<void> refresh() => _loadReports();

  // ── Helpers ───────────────────────────────────────────────
  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  /// Try to parse ISO-style date strings like "2026-01-15"
  DateTime? _parseDate(String raw) {
    try { return DateTime.parse(raw.trim()); } catch (_) { return null; }
  }
}
