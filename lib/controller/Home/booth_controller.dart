import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/model/report/report_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../linkapi.dart';

class BoothController extends GetxController {
  final _crud        = Crud();
  final booths       = <BoothModel>[].obs;
  final filtered     = <BoothModel>[].obs;
  final statusFilter = 'الكل'.obs;
  final isLoading    = false.obs;
  final filters      = ['الكل', 'نشطة', 'قيد المراجعة', 'مرفوضة', 'منتهية'];

  static const _statusMap = {
    'نشطة': 'active',
    'قيد المراجعة': 'pending',
    'مرفوضة': 'rejected',
    'منتهية': 'ended',
  };

  @override
  void onInit() {
    _loadBooths();
    super.onInit();
  }

  Future<void> _loadBooths() async {
    isLoading.value = true;
    final result = await _crud.getData(AppLink.investorBookings);
    if (result['status'] == true) {
      final list = _asList(result['data']);
      booths.value = list.map((e) => BoothModel.fromJson(e)).toList();
    } else {
      booths.value = DummyData.myBooths;
    }
    filtered.value = booths;
    isLoading.value = false;
  }

  void applyFilter(String f) {
    statusFilter.value = f;
    if (f == 'الكل') {
      filtered.value = booths;
    } else {
      filtered.value = booths
          .where((b) => b.status == (_statusMap[f] ?? f))
          .toList();
    }
  }

  void toggleFavorite(BoothModel b) {
    final wasFav = b.isFavorite;
    b.isFavorite = !wasFav;
    booths.refresh();
    filtered.refresh();
    if (wasFav) {
      _crud.deleteData(AppLink.favoriteBooth(b.id));
    } else {
      _crud.postData(AppLink.favoriteBooth(b.id), {});
    }
  }

  // ── بناء تقرير خاص بجناح (مشترك بين الجوال والويب) ─────────
  ReportModel buildBoothReport(BoothModel b) {
    final existing = DummyData.reports.firstWhereOrNull(
      (r) => r.boothName.contains(b.number) ||
             (r.exhibitionName == b.exhibitionName && r.boothName.isNotEmpty),
    );
    return existing ??
        ReportModel(
          id:             'RPT-${b.id}',
          title:          'تقرير الجناح ${b.number}',
          type:           'performance',
          description:    'تقرير أداء الجناح ${b.number} في ${b.exhibitionName}',
          period:         'هذا الشهر',
          boothName:      'جناح ${b.number}',
          exhibitionName: b.exhibitionName,
          createdAt:      '2026-06-07',
          mainValue:      1840,
          mainLabel:      'إجمالي الزوار',
          trend:          12.5,
          sparklineData:  const [120, 180, 150, 220, 280, 240, 310, 350],
        );
  }

  // ── فتح تقرير الجناح (الجوال) ──────────────────────────────
  void openBoothReport(BoothModel b) =>
      Get.toNamed(AppRoutes.REPORT_DETAIL, arguments: buildBoothReport(b));

  Future<void> refresh() => _loadBooths();

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'];
      if (data['bookings'] is List) return data['bookings'];
    }
    return [];
  }
}
