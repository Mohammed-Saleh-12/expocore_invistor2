import 'core/constant/app_env.dart';

// ════════════════════════════════════════════════════════════
//  AppLink  —  all API endpoints
//  Base URL comes from AppEnv so dev/staging/prod auto-switch
// ════════════════════════════════════════════════════════════
class AppLink {
  static String get server => AppEnv.baseUrl;

  // ── Auth ─────────────────────────────────────────────────
  static String get login          => '$server/auth/login';
  static String get register       => '$server/auth/register';
  static String get logout         => '$server/auth/logout';
  static String get forgotPassword => '$server/auth/forgot-password';
  static String get resetPassword  => '$server/auth/reset-password';
  static String get refreshToken   => '$server/auth/refresh';
  static String get changePassword => '$server/auth/change-password';
  static String get deleteAccount  => '$server/auth/delete-account';

  // ── Auth — OTP (تسجيل) ───────────────────────────────────
  static String get verifyOtp => '$server/auth/verify-otp';
  static String get resendOtp => '$server/auth/resend-otp';

  // ── Auth — Forgot Password OTP ───────────────────────────
  static String get verifyForgotOtp => '$server/auth/forgot-password/verify-otp';
  static String get resendForgotOtp => '$server/auth/forgot-password/resend-otp';

  // ── Auth — FCM Token ─────────────────────────────────────
  static String get fcmToken => '$server/auth/fcm-token';

  // ── Exhibitions ──────────────────────────────────────────
  static String get exhibitions                    => '$server/exhibitions';
  static String exhibitionDetail(int id)           => '$server/exhibitions/$id';
  // الخريطة ثلاثية الأبعاد: GET /exhibitions/{id}/map
  static String exhibitionMap(int id)              => '$server/exhibitions/$id/map';

  // ── Booths ───────────────────────────────────────────────
  static String get booths             => '$server/booths';
  static String boothDetail(int id)    => '$server/booths/$id';
  static String get bookBooth          => '$server/booths/book';

  // ── Investor — Dashboard ─────────────────────────────────
  static String get investorDashboard => '$server/investor/dashboard';

  // ── Investor — Profile ───────────────────────────────────
  static String get investorProfile => '$server/investor/profile';

  // ── Investor — Bookings ──────────────────────────────────
  static String get investorBookings             => '$server/investor/bookings';
  static String bookingDetail(int id)            => '$server/investor/bookings/$id';
  static String cancelBooking(int id)            => '$server/investor/bookings/$id/cancel';

  // ── Investor — Booth Profile ─────────────────────────────
  static String boothProfile(int boothId)        => '$server/investor/booths/$boothId/profile';

  // ── Investor — Campaigns ─────────────────────────────────
  static String get investorCampaigns            => '$server/investor/campaigns';
  static String campaignDetail(int id)           => '$server/investor/campaigns/$id';

  // ── Investor — Events ────────────────────────────────────
  static String get investorEvents               => '$server/investor/events';
  static String eventDetail(int id)              => '$server/investor/events/$id';
  static String eventTicketRequests(int id)      => '$server/investor/events/$id/ticket-requests';
  static String ticketRequestAction(int eId, int rId) =>
      '$server/investor/events/$eId/ticket-requests/$rId';

  // ── Investor — Sponsor Events (فعاليات إعلانية) ──────────
  // GET params: page, per_page
  static String get exhibitionSponsorEvents      => '$server/investor/sponsor-events';
  static String get investorSponsorships         => '$server/investor/sponsorships';
  static String cancelSponsorship(int id)        => '$server/investor/sponsorships/$id/cancel';

  // ── Investor — Analytics ─────────────────────────────────
  static String get investorAnalytics => '$server/investor/analytics';

  // ── Investor — Favorites ─────────────────────────────────
  static String get investorFavorites           => '$server/investor/favorites';
  static String favoriteItem(int id)            => '$server/investor/favorites/$id';

  // ── Investor — Reports ───────────────────────────────────
  static String get investorReports             => '$server/investor/reports';
  static String reportDetail(String id)         => '$server/investor/reports/$id';
  static String reportDownload(String id, String fmt) =>
      '$server/investor/reports/$id/download?format=$fmt';
}
