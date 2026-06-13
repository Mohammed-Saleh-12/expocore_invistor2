import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../core/services/pdf_export_service.dart';
import '../../core/services/download_service.dart';
import '../../core/utils/report_type_helper.dart';
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

    if (selectedType.value != 'الكل') {
      final mapped = typeMap[selectedType.value] ?? 'all';
      list = list.where((r) => r.type == mapped);
    }

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

  // ── Export to PDF via window.print() (web) / share (mobile) ─
  void exportToPdf(ReportModel r) {
    final content = ReportTypeHelper.of(r);
    PdfExportService.printReport(r, content);
  }

  // ── Download report (PDF = client-side, Excel = server-side) ─
  Future<void> downloadReport(
    String reportId, {
    String format = 'pdf',
  }) async {
    if (isDownloading.value) return;
    isDownloading.value    = true;
    downloadProgress.value = 0.0;

    try {
      if (format == 'pdf') {
        // ── Client-side PDF: generate HTML and open print dialog
        final model = _findReport(reportId);
        if (model != null) {
          final content = ReportTypeHelper.of(model);
          PdfExportService.printReport(model, content);
        } else {
          // Model not loaded yet — fall back to server download
          await DownloadService.downloadUrl(
              AppLink.reportDownload(reportId, format));
        }
      } else {
        // ── Server-side Excel: trigger native browser/OS download
        final url = AppLink.reportDownload(reportId, format);
        await DownloadService.downloadUrl(url);
      }

      // Animate progress bar
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        downloadProgress.value = i / 10;
      }

      Get.snackbar(
        'تم',
        format == 'excel'
            ? 'جارٍ تنزيل ملف Excel…'
            : 'جارٍ فتح نافذة الطباعة…',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (_) {
      Get.snackbar(
        'خطأ',
        'تعذّر التنزيل — حاول مرة أخرى',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value    = false;
      downloadProgress.value = 1.0;
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
  ReportModel? _findReport(String id) {
    try {
      return reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return selectedReport.value?.id == id ? selectedReport.value : null;
    }
  }

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  DateTime? _parseDate(String raw) {
    try { return DateTime.parse(raw.trim()); } catch (_) { return null; }
  }
}
