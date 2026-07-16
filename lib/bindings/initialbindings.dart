import 'package:expocore_invistor2/controller/auth/change_password_controller.dart';
import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:get/get.dart';
import '../controller/auth/login_controller.dart';
import '../controller/auth/register_controller.dart';
import '../controller/auth/forgot_password_controller.dart';
import '../controller/auth/reset_password_controller.dart';
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
import '../controller/Home/splash_controller.dart';
import '../controller/Home/onboarding_controller.dart';
import '../controller/Home/qr_scanner_controller.dart';
import '../controller/Home/booth_detail_controller.dart';
import '../controller/Home/exhibition_detail_controller.dart';
import '../controller/Home/exhibition_billboard_controller.dart';
import '../controller/Home/event_billboard_controller.dart';
import '../web/controllers/web_auth_controller.dart';
import '../web/controllers/web_billboard_controller.dart';
import '../web/controllers/web_scanner_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // ── Auth controllers (shared: mobile + web) ──────────────
    Get.lazyPut(() => LoginController(),          fenix: true);
    Get.lazyPut(() => RegisterController(),       fenix: true);
    Get.lazyPut(() => ForgotPasswordController(), fenix: true);
    Get.lazyPut(() => ResetPasswordController(),  fenix: true);

    // ── Web auth orchestration (web only) ────────────────────
    // Must be registered after the four auth controllers above
    // so onInit() can call ever() on their status observables
    if (GetPlatform.isWeb) {
      Get.put(WebAuthController(), permanent: true);
    }

    // ── Home controllers ─────────────────────────────────────
    Get.lazyPut(() => DashboardController(),        fenix: true);
    Get.lazyPut(() => ExhibitionsController(),      fenix: true);
    Get.lazyPut(() => BoothController(),            fenix: true);
    Get.lazyPut(() => FavoritesController(),        fenix: true);
    Get.lazyPut(() => ReportsController(),          fenix: true);
    Get.lazyPut(() => EventsController(),           fenix: true);
    Get.lazyPut(() => CampaignsController(),        fenix: true);
    Get.lazyPut(() => AnalyticsController(),        fenix: true);
    Get.lazyPut(() => MessagesController(),         fenix: true);
    Get.lazyPut(() => VisitorMessagesController(),  fenix: true);
    Get.lazyPut(() => NotificationsController(),    fenix: true);
    Get.lazyPut(() => SettingsController(),         fenix: true);
    Get.lazyPut(() => ProfileCompanyController(),   fenix: true);
    Get.lazyPut(() => BookingController(),          fenix: true);
    Get.lazyPut(() => BoothMapController(),            fenix: true);
    Get.lazyPut(() => BoothManagementController(),     fenix: true);
    Get.lazyPut(() => SplashController(),              fenix: true);
    Get.lazyPut(() => OnboardingController(),           fenix: true);
    Get.lazyPut(() => QrScannerController(),            fenix: true);
    Get.lazyPut(() => BoothDetailController(),          fenix: true);
    Get.lazyPut(() => ExhibitionDetailController(),     fenix: true);
    Get.lazyPut(() => ExhibitionBillboardController(),  fenix: true);
    Get.lazyPut(() => EventBillboardController(),       fenix: true);

    if (GetPlatform.isWeb) {
      Get.lazyPut(() => WebBillboardController(),  fenix: true);
      Get.lazyPut(() => WebScannerController(),    fenix: true);
    }
  }
  
}
class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Crud>(() => Crud(), fenix: true);
    Get.lazyPut<ChangePasswordController>(
      () => ChangePasswordController(),
      fenix: true,
    );
  }
}
