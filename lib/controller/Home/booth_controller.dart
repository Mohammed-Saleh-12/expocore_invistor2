import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../core/utils/safe_snackbar.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/sourcedata/remote/Booths/BoothsData.dart';
import '../../data/sourcedata/remote/Favorites/FavoritesData.dart';
import '../../web/controllers/web_nav_controller.dart';
import 'reports_controller.dart';

class BoothController extends GetxController {
  final BoothsData _boothsData = BoothsData(Crud());
  final booths = <BoothModel>[].obs;
  final filtered = <BoothModel>[].obs;
  final statusFilter = 'الكل'.obs;
  final isLoading = false.obs;
  final filters = ['الكل', 'نشطة', 'قيد المراجعة', 'مرفوضة', 'منتهية'];

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
    final result = await _boothsData.getMyBookings();
    if (result['status'] == true) {
      final list = _asList(result['data']);
      booths.value = list.map((e) => BoothModel.fromJson(e)).toList();
    } else {
      booths.clear();
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
    final _fav = FavoritesData(Crud());
    if (wasFav) {
      _fav.removeFavorite(b.id, FavoriteType.booth);
    } else {
      _fav.addFavorite(b.id, FavoriteType.booth);
    }
  }

  // ── فتح تقرير الجناح الحقيقي ───────────────────────────────
  Future<void> openBoothReport(BoothModel b) async {
    if (!Get.isRegistered<ReportsController>()) {
      Get.put(ReportsController());
    }
    final report = await Get.find<ReportsController>().findBoothReport(b);
    if (report == null) {
      safeSnackbar('snack_warning'.tr, 'reports_no_booth_report'.tr);
      return;
    }
    if (GetPlatform.isWeb) {
      WebNavController.to.openReport(report);
    } else {
      Get.toNamed(AppRoutes.REPORT_DETAIL, arguments: report);
    }
  }

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
