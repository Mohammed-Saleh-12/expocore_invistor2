import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../core/services/services.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/event/event_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../linkapi.dart';

class DashboardController extends GetxController {
  final _crud = Crud();

  final currentIndex   = 0.obs;
  final selectedPeriod = 'هذا الشهر'.obs;
  final companyName    = ''.obs;
  final isLoading      = false.obs;
  final periods        = ['هذا الشهر', 'آخر 3 أشهر', 'هذا العام'];

  final totalBookings   = 0.obs;
  final activeBooths    = 0.obs;
  final publishedEvents = 0.obs;
  final totalEngagement = 0.obs;

  final featuredExhibitions = <ExhibitionModel>[].obs;
  final upcomingEvents      = <EventModel>[].obs;

  @override
  void onInit() {
    companyName.value = Get.find<Services>().companyName;
    _loadDashboard();
    super.onInit();
  }

  Future<void> _loadDashboard() async {
    isLoading.value = true;
    final result = await _crud.getData(
      AppLink.investorDashboard,
      params: {'period': selectedPeriod.value},
    );

    if (result['status'] == true) {
      final d = _body(result['data']);
      totalBookings.value   = d['total_bookings']   ?? 0;
      activeBooths.value    = d['active_booths']     ?? 0;
      publishedEvents.value = d['published_events']  ?? 0;
      totalEngagement.value = d['total_engagement']  ?? 0;

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
    totalBookings.value   = 12;
    activeBooths.value    = 3;
    publishedEvents.value = 8;
    totalEngagement.value = 24850;
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

  List<ExhibitionModel> get latestExhibitions => featuredExhibitions.take(3).toList();

  Future<void> refresh() => _loadDashboard();

  dynamic _body(dynamic data) =>
      (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});
}
