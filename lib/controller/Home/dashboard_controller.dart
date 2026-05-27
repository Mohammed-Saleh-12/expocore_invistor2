import 'package:get/get.dart';
import '../../core/services/services.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/event/event_model.dart';

class DashboardController extends GetxController {
  final currentIndex  = 0.obs;
  final selectedPeriod = 'هذا الشهر'.obs;
  final companyName   = ''.obs;
  final periods = ['هذا الشهر', 'آخر 3 أشهر', 'هذا العام'];
  
  final totalBookings    = 12.obs;
  final activeBooths     = 3.obs;
  final publishedEvents  = 8.obs;
  final totalEngagement  = 24850.obs;
  
  List<ExhibitionModel> get featuredExhibitions => DummyData.exhibitions.toList();
  List<ExhibitionModel> get latestExhibitions => DummyData.exhibitions.take(3).toList();
  List<EventModel>      get upcomingEvents    => DummyData.events.where((e) => e.status == 'upcoming').take(3).toList();

  @override
  void onInit() {
    companyName.value = Get.find<Services>().companyName;
    super.onInit();
  }

  void changePeriod(String p) {
    selectedPeriod.value = p;
    if (p == 'آخر 3 أشهر') {
      totalBookings.value    = 34;
      activeBooths.value     = 5;
      publishedEvents.value  = 22;
      totalEngagement.value  = 68400;
    } else if (p == 'هذا العام') {
      totalBookings.value    = 87;
      activeBooths.value     = 8;
      publishedEvents.value  = 45;
      totalEngagement.value  = 152000;
    } else {
      totalBookings.value    = 12;
      activeBooths.value     = 3;
      publishedEvents.value  = 8;
      totalEngagement.value  = 24850;
    }
  }
}
