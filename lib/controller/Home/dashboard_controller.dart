import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../core/services/services.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/event/event_model.dart';
import '../../data/sourcedata/remote/Dashboard/DashboardData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class DashboardController extends GetxController {
  final DashboardData _dashboardData = DashboardData(Crud());

  final currentIndex = 0.obs;
  final selectedPeriod = 'هذا الشهر'.obs;
  final companyName = ''.obs;
  final isLoading = false.obs;
  final periods = ['هذا الشهر', 'آخر 3 أشهر', 'هذا العام'];

  final totalBookings = 0.obs;
  final activeBooths = 0.obs;
  final publishedEvents = 0.obs;
  final totalEngagement = 0.obs;
  final bookingsGrowth = 0.0.obs;
  final boothsGrowth = 0.0.obs;
  final eventsGrowth = 0.0.obs;
  final engagementGrowth = 0.0.obs;

  final featuredExhibitions = <ExhibitionModel>[].obs;
  final upcomingEvents = <EventModel>[].obs;

  @override
  void onInit() {
    companyName.value = Get.find<Services>().companyName;
    _loadDashboard();
    super.onInit();
  }

  Future<void> _loadDashboard() async {
    isLoading.value = true;
    final result = await _dashboardData.getDashboard(selectedPeriod.value);

    if (result['status'] == true) {
      final d = _body(result['data']);
      totalBookings.value = d['total_bookings'] ?? 0;
      activeBooths.value = d['active_booths'] ?? 0;
      publishedEvents.value = d['published_events'] ?? 0;
      totalEngagement.value = d['total_engagement'] ?? 0;
      final growth = d['growth'] is Map ? d['growth'] as Map : const {};
      bookingsGrowth.value = _number(growth['total_bookings']);
      boothsGrowth.value = _number(growth['active_booths']);
      eventsGrowth.value = _number(growth['published_events']);
      engagementGrowth.value = _number(growth['total_engagement']);

      featuredExhibitions.value = (d['featured_exhibitions'] as List? ?? [])
          .map((e) => ExhibitionModel.fromJson(e))
          .toList();
      upcomingEvents.value = (d['upcoming_events'] as List? ?? [])
          .map((e) => EventModel.fromJson(e))
          .toList();
    } else {
      _loadFallback();
    }
    isLoading.value = false;
  }

  void _loadFallback() {
    totalBookings.value = 0;
    activeBooths.value = 0;
    publishedEvents.value = 0;
    totalEngagement.value = 0;
    bookingsGrowth.value = 0;
    boothsGrowth.value = 0;
    eventsGrowth.value = 0;
    engagementGrowth.value = 0;
    featuredExhibitions.value = DummyData.exhibitions.toList();
    upcomingEvents.value = DummyData.events
        .where((e) => e.status == 'upcoming')
        .take(3)
        .toList();
  }

  void changePeriod(String p) {
    selectedPeriod.value = p;
    _loadDashboard();
  }

  List<ExhibitionModel> get latestExhibitions =>
      featuredExhibitions.take(3).toList();

  /// تنسيق الأرقام الكبيرة (مسؤولية الكنترولر لا الواجهة)
  String formatEngagement(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  Future<void> refresh() => _loadDashboard();

  dynamic _body(dynamic data) =>
      (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});

  double _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;
}
