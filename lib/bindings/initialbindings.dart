import 'package:get/get.dart';
import '../controller/auth/login_controller.dart';
import '../controller/auth/register_controller.dart';
import '../controller/Home/dashboard_controller.dart';
import '../controller/Home/exhibitions_controller.dart';
import '../controller/Home/booth_controller.dart';
import '../controller/Home/favorites_controller.dart';
import '../controller/Home/reports_controller.dart';
import '../controller/Home/events_controller.dart';
import '../controller/Home/campaigns_controller.dart';
import '../controller/Home/analytics_controller.dart';
import '../controller/Home/messages_controller.dart';
import '../controller/Home/notifications_controller.dart';
import '../controller/Home/settings_controller.dart';
import '../controller/Home/profile_company_controller.dart';
import '../controller/Home/booking_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => RegisterController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => ExhibitionsController());
    Get.lazyPut(() => BoothController());
    Get.lazyPut(() => FavoritesController());
    Get.lazyPut(() => ReportsController());
    Get.lazyPut(() => EventsController());
    Get.lazyPut(() => CampaignsController());
    Get.lazyPut(() => AnalyticsController());
    Get.lazyPut(() => MessagesController());
    Get.lazyPut(() => NotificationsController());
    Get.lazyPut(() => SettingsController());
    Get.lazyPut(() => ProfileCompanyController());
    Get.lazyPut(() => BookingController());
  }
}
