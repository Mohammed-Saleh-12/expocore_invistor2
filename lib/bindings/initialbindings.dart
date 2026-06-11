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
import '../controller/Home/visitor_messages_controller.dart';
import '../controller/Home/notifications_controller.dart';
import '../controller/Home/settings_controller.dart';
import '../controller/Home/profile_company_controller.dart';
import '../controller/Home/booking_controller.dart';
import '../controller/Home/booth_map_controller.dart';
import '../controller/Home/booth_management_controller.dart';
import '../web/controllers/web_auth_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // ── Auth controllers (shared: mobile + web) ──────────────
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => RegisterController(), fenix: true);

    // ── Web auth orchestration (web only) ────────────────────
    // يجب تسجيله بعد LoginController و RegisterController
    // حتى يتمكن onInit من الاستماع إليهما عبر ever()
    if (GetPlatform.isWeb) {
      Get.put(WebAuthController(), permanent: true);
    }

    // ── Home controllers ─────────────────────────────────────
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => ExhibitionsController(), fenix: true);
    Get.lazyPut(() => BoothController(), fenix: true);
    Get.lazyPut(() => FavoritesController(), fenix: true);
    Get.lazyPut(() => ReportsController(), fenix: true);
    Get.lazyPut(() => EventsController(), fenix: true);
    Get.lazyPut(() => CampaignsController(), fenix: true);
    Get.lazyPut(() => AnalyticsController(), fenix: true);
    Get.lazyPut(() => MessagesController(), fenix: true);
    Get.lazyPut(() => VisitorMessagesController(), fenix: true);
    Get.lazyPut(() => NotificationsController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => ProfileCompanyController(), fenix: true);
    Get.lazyPut(() => BookingController(), fenix: true);
    Get.lazyPut(() => BoothMapController(), fenix: true);
    Get.lazyPut(() => BoothManagementController(), fenix: true);
  }
}
