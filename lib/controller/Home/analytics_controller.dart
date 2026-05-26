import 'package:get/get.dart';
import '../../core/constant/routes.dart';

class AnalyticsController extends GetxController {
  final selectedPeriod = 'هذا الشهر'.obs;
  final periods = ['هذا الشهر', 'آخر 3 أشهر', 'هذا العام', 'مخصص'];

  final totalVisits       = 2450.obs;
  final productViews      = 8920.obs;
  final eventParticipants = 148.obs;
  final totalEngagement   = 24850.obs;

  final visitsTrend       = 12.5.obs;
  final viewsTrend        = 8.3.obs;
  final eventsTrend       = 22.1.obs;
  final engagementTrend   = 15.7.obs;

  final visitorsData = <double>[120.0, 180.0, 250.0, 310.0, 400.0, 380.0, 420.0].obs;
  final engagementData = <double>[80.0, 120.0, 160.0, 200.0, 240.0, 280.0, 320.0].obs;

  void changePeriod(String p) {
    selectedPeriod.value = p;
    if (p == 'آخر 3 أشهر') {
      totalVisits.value       = 7200;
      productViews.value      = 24500;
      eventParticipants.value = 420;
      totalEngagement.value   = 68400;
    } else if (p == 'هذا العام') {
      totalVisits.value       = 28000;
      productViews.value      = 95000;
      eventParticipants.value = 1850;
      totalEngagement.value   = 252000;
    } else {
      totalVisits.value       = 2450;
      productViews.value      = 8920;
      eventParticipants.value = 148;
      totalEngagement.value   = 24850;
    }
  }

  void goToReports() => Get.toNamed(AppRoutes.REPORTS);
}
