import 'package:expocore_invistor2/view/screen/Home/messages/conversations_list_view.dart';
import 'package:get/get.dart';
import 'bindings/initialbindings.dart';
import 'core/constant/routes.dart';
import 'view/screen/Home/splash_view.dart';
import 'view/screen/Home/language_picker_view.dart';
import 'view/screen/Home/onboarding_view.dart';
import 'view/screen/auth/login_view.dart';
import 'view/screen/auth/register_view.dart';
import 'view/screen/auth/forgot_password_view.dart';
import 'view/screen/auth/reset_password_view.dart';
import 'view/screen/Home/dashboard_view.dart';
import 'view/screen/Home/exhibitions/exhibitions_list_view.dart';
import 'view/screen/Home/exhibitions/exhibition_detail_view.dart';
import 'view/screen/Home/favorites/favorites_view.dart';
import 'view/screen/Home/profile_company/profile_company_view.dart';
import 'view/screen/Home/booths/booths_view.dart';
import 'view/screen/Home/booths/booth_map3d_view.dart';
import 'view/screen/Home/booths/booth_detail_view.dart';
import 'view/screen/Home/booths/booth_management_view.dart';
import 'view/screen/Home/booths/booking_request_view.dart';
import 'view/screen/Home/booths/booking_detail_view.dart';
import 'view/screen/Home/campaigns/campaigns_view.dart';
import 'view/screen/Home/campaigns/create_campaign_view.dart';
import 'view/screen/Home/events/events_view.dart';
import 'view/screen/Home/events/create_event_view.dart';
import 'view/screen/Home/events/event_participants_view.dart';
import 'view/screen/Home/events/exhibition_events_view.dart';
import 'view/screen/Home/events/my_sponsorships_view.dart';
import 'view/screen/Home/events/my_sponsorship_detail_view.dart';
import 'view/screen/Home/events/my_event_detail_view.dart';
import 'view/screen/Home/events/ticket_requests_view.dart';
import 'view/screen/Home/analytics/analytics_view.dart';
import 'view/screen/Home/reports/reports_list_view.dart';
import 'view/screen/Home/reports/report_detail_view.dart';
import 'view/screen/Home/messages/messages_view.dart';
import 'view/screen/Home/messages/visitor_messages_view.dart';
import 'view/screen/Home/notifications/notifications_view.dart';
import 'view/screen/Home/settings/settings_view.dart';
import 'view/screen/Home/qr_scanner_view.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.SPLASH,             page: () => const SplashView(),              binding: InitialBindings()),
    GetPage(name: AppRoutes.LANGUAGE_PICKER,    page: () => const LanguagePickerView()),
    GetPage(name: AppRoutes.ONBOARDING,         page: () => const OnboardingView()),
    GetPage(name: AppRoutes.LOGIN,              page: () => const LoginView()),
    GetPage(name: AppRoutes.REGISTER,           page: () => const RegisterView()),
    GetPage(name: AppRoutes.FORGOT_PW,          page: () => const ForgotPasswordView()),
    GetPage(name: AppRoutes.RESET_PW,           page: () => const ResetPasswordView()),
    GetPage(name: AppRoutes.DASHBOARD,          page: () => const DashboardView()),
    GetPage(name: AppRoutes.EXHIBITIONS,        page: () => const ExhibitionsListView()),
    GetPage(name: AppRoutes.EXHIBITION_DETAIL,  page: () => const ExhibitionDetailView()),
    GetPage(name: AppRoutes.FAVORITES,          page: () => const FavoritesView()),
    GetPage(name: AppRoutes.PROFILE,            page: () => const ProfileCompanyView()),
    GetPage(name: AppRoutes.BOOTHS,             page: () => const BoothsView()),
    GetPage(name: AppRoutes.BOOTH_MAP_3D,       page: () => const BoothMap3dView()),
    GetPage(name: AppRoutes.BOOTH_DETAIL,       page: () => const BoothDetailView()),
    GetPage(name: AppRoutes.BOOTH_MANAGEMENT,   page: () => const BoothManagementView()),
    GetPage(name: AppRoutes.BOOKING_REQUEST,    page: () => const BookingRequestView()),
    GetPage(name: AppRoutes.BOOKING_DETAIL,     page: () => const BookingDetailView()),
    GetPage(name: AppRoutes.CAMPAIGNS,          page: () => const CampaignsView()),
    GetPage(name: AppRoutes.CREATE_CAMPAIGN,    page: () => const CreateCampaignView()),
    GetPage(name: AppRoutes.EVENTS,             page: () => const EventsView()),
    GetPage(name: AppRoutes.CREATE_EVENT,       page: () => const CreateEventView()),
    GetPage(name: AppRoutes.EVENT_PARTICIPANTS, page: () => const EventParticipantsView()),
    GetPage(name: AppRoutes.EXHIBITION_EVENTS,  page: () => const ExhibitionEventsView()),
    GetPage(name: AppRoutes.MY_SPONSORSHIPS,    page: () => const MySponshorshipsView()),
    GetPage(name: AppRoutes.SPONSORSHIP_DETAIL, page: () => const MySponsorshipDetailView()),
    GetPage(name: AppRoutes.MY_EVENT_DETAIL,    page: () => const MyEventDetailView()),
    GetPage(name: AppRoutes.TICKET_REQUESTS,    page: () => const TicketRequestsView()),
    GetPage(name: AppRoutes.ANALYTICS,          page: () => const AnalyticsView()),
    GetPage(name: AppRoutes.REPORTS,            page: () => const ReportsListView()),
    GetPage(name: AppRoutes.REPORT_DETAIL,      page: () => const ReportDetailView()),
    GetPage(name: AppRoutes.MESSAGES,            page: () => const ConversationsListView()),
    GetPage(name: AppRoutes.CONVERSATION,        page: () => const MessagesView()),
    GetPage(name: AppRoutes.VISITOR_CONVERSATION,page: () => const VisitorMessagesView()),
    GetPage(name: AppRoutes.NOTIFICATIONS,      page: () => const NotificationsView()),
    GetPage(name: AppRoutes.SETTINGS,           page: () => const SettingsView()),
    GetPage(name: AppRoutes.QR_SCANNER,         page: () => const QrScannerView()),
  ];
}
