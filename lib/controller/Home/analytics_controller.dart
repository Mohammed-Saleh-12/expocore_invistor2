import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../linkapi.dart';

class AnalyticsController extends GetxController {
  final _crud = Crud();

  final selectedPeriod = 'هذا الشهر'.obs;
  final isLoading      = false.obs;
  final periods        = ['هذا الشهر', 'آخر 3 أشهر', 'هذا العام', 'مخصص'];

  final totalVisits       = 0.obs;
  final productViews      = 0.obs;
  final eventParticipants = 0.obs;
  final totalEngagement   = 0.obs;

  final visitsTrend       = 0.0.obs;
  final viewsTrend        = 0.0.obs;
  final eventsTrend       = 0.0.obs;
  final engagementTrend   = 0.0.obs;

  final visitorsData   = <double>[].obs;
  final engagementData = <double>[].obs;

  @override
  void onInit() {
    _loadAnalytics();
    super.onInit();
  }

  Future<void> _loadAnalytics() async {
    isLoading.value = true;
    final result = await _crud.getData(
      AppLink.investorAnalytics,
      params: {'period': selectedPeriod.value},
    );

    if (result['status'] == true) {
      final d = _body(result['data']);
      totalVisits.value       = d['total_visits']        ?? 0;
      productViews.value      = d['product_views']       ?? 0;
      eventParticipants.value = d['event_participants']  ?? 0;
      totalEngagement.value   = d['total_engagement']    ?? 0;
      visitsTrend.value       = (d['visits_trend']      ?? 0).toDouble();
      viewsTrend.value        = (d['views_trend']       ?? 0).toDouble();
      eventsTrend.value       = (d['events_trend']      ?? 0).toDouble();
      engagementTrend.value   = (d['engagement_trend']  ?? 0).toDouble();
      visitorsData.value   = _doubles(d['visitors_chart']);
      engagementData.value = _doubles(d['engagement_chart']);
    } else {
      _loadFallback();
    }
    isLoading.value = false;
  }

  void _loadFallback() {
    totalVisits.value       = 2450;
    productViews.value      = 8920;
    eventParticipants.value = 148;
    totalEngagement.value   = 24850;
    visitsTrend.value       = 12.5;
    viewsTrend.value        = 8.3;
    eventsTrend.value       = 22.1;
    engagementTrend.value   = 15.7;
    visitorsData.value   = [120.0, 180.0, 250.0, 310.0, 400.0, 380.0, 420.0];
    engagementData.value = [80.0, 120.0, 160.0, 200.0, 240.0, 280.0, 320.0];
  }

  void changePeriod(String p) {
    selectedPeriod.value = p;
    _loadAnalytics();
  }

  void goToReports() => Get.toNamed(AppRoutes.REPORTS);

  List<double> _doubles(dynamic list) =>
      (list as List? ?? []).map((v) => (v as num).toDouble()).toList();

  dynamic _body(dynamic data) =>
      (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});
}
