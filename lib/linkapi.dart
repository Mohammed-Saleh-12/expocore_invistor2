import 'core/constant/app_env.dart';

// ════════════════════════════════════════════════════════════
//  AppLink  —  all API endpoints
//  Base URL comes from AppEnv so dev/staging/prod auto-switch
// ════════════════════════════════════════════════════════════
class AppLink {
  static String get server => AppEnv.baseUrl;

  // ── Auth ─────────────────────────────────────────────────
  static String get login => '$server/investor/auth/login';
  static String get register => '$server/investor/auth/register';
  static String get logout => '$server/investor/auth/logout';
  static String get forgotPassword => '$server/investor/auth/forgot-password';
  static String get resetPassword => '$server/investor/auth/reset-password';
  static String get refreshToken => '$server/auth/refresh';
  static String get changePassword => '$server/investor/auth/change-password';
  static String get deleteAccount => '$server/investor/auth/delete-account';

  // ── Auth — OTP (تسجيل) ───────────────────────────────────
  static String get verifyOtp => '$server/investor/auth/verify-otp';
  static String get resendOtp => '$server/investor/auth/resend-otp';

  // ── Auth — Forgot Password OTP ───────────────────────────
  static String get verifyForgotOtp =>
      '$server/investor/auth/forgot-password/verify-otp';
  static String get resendForgotOtp =>
      '$server/investor/auth/forgot-password/resend-otp';

  // ── Auth — Firebase sync / FCM token ────────────────────
  static String get firebaseSync => '$server/auth/firebase-sync';
  static String get fcmToken => '$server/notifications/fcm-token';

  // ── Notifications ─────────────────────────────────────────
  static String get investorNotifications => '$server/investor/notifications';
  static String get notificationsReadAll =>
      '$server/investor/notifications/read-all';
  static String notificationDetail(String id) =>
      '$server/investor/notifications/$id';
  static String notificationRead(String id) =>
      '$server/investor/notifications/$id/read';

  // ── Exhibitions ──────────────────────────────────────────
  static String get exhibitions => '$server/investor/exhibitions';
  static String exhibitionDetail(int id) => '$server/investor/exhibitions/$id';
  static String exhibitionSponsorshipRequest(int id) =>
      '$server/investor/exhibitions/$id/sponsorship-request';
  static String get submitExhibitionSponsorshipRequest =>
      '$server/investor/exhibitions/sponsorship-request';
  // الخريطة ثلاثية الأبعاد: GET /exhibitions/{id}/map
  static String exhibitionMap(int id) => '$server/investor/exhibitions/$id/map';

  // ملفات نماذج الخريطة تُخدم من جذر التطبيق، وليس من مسار /api.
  static String mapModel(String fileName) {
    final apiUri = Uri.parse(server);
    final rootUri = apiUri.replace(path: '/models/$fileName');
    return rootUri.toString();
  }

  static String mediaUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.startsWith('data:')) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final imageUri = Uri.tryParse(trimmed);
      final apiUri = Uri.parse(server);
      if (imageUri != null &&
          (imageUri.host == 'localhost' ||
              imageUri.host == '127.0.0.1' ||
              imageUri.host == '::1')) {
        return imageUri
            .replace(
              scheme: apiUri.scheme,
              host: apiUri.host,
              port: apiUri.port,
            )
            .toString();
      }
      return trimmed;
    }
    final apiUri = Uri.parse(server);
    final path = trimmed.startsWith('/') ? trimmed : '/storage/$trimmed';
    return apiUri.replace(path: path).toString();
  }

  static String get mapViewer {
    final apiUri = Uri.parse(server);
    return apiUri
        .replace(
          path: '/map-viewer/index.html',
          queryParameters: {'v': '20260821-6'},
        )
        .toString();
  }

  // ── Booths ───────────────────────────────────────────────
  static String get booths => '$server/investor/booths';
  static String get exhibitionBooths => '$server/investor/exhibition/booths';
  static String boothDetail(int id) => '$server/investor/booths/$id';
  static String get bookBooth => '$server/booths/book';

  // ── Home Billboard (Paginated, 5 per call) ───────────────
  /// GET /exhibitions/featured?page=&per_page=
  static String get featuredExhibitionsBillboard =>
      '$server/investor/exhibitions/featured';

  // ── Latest Exhibitions (ويب — بدون Pagination) ───────────
  /// GET /exhibitions/latest
  static String get latestExhibitions => '$server/investor/exhibitions/latest';

  /// GET /investor/sponsor-events/featured?page=&per_page=
  static String get featuredSponsorEventsBillboard =>
      '$server/investor/sponsor-events/featured';

  // ── Investor — Dashboard ─────────────────────────────────
  static String get investorDashboard => '$server/investor/dashboard';

  // ── Investor — Profile ───────────────────────────────────
  static String get investorProfile => '$server/investor/profile';
  static String get investorProfileAvatar => '$server/investor/profile/avatar';

  // ── Investor — Bookings ──────────────────────────────────
  static String get investorBookings => '$server/investor/bookings';
  static String bookingDetail(int id) => '$server/investor/bookings/$id';
  static String cancelBooking(int id) => '$server/investor/bookings/$id/cancel';

  // ── Investor — Booth Profile ─────────────────────────────
  static String boothProfile(int boothId) =>
      '$server/investor/booths/$boothId/profile';
  static String boothProfileUpdate(int boothId) =>
      '$server/investor/booths/$boothId/profile/update';
  static String boothCoverImage(int boothId) =>
      '$server/investor/booths/$boothId/cover';

  // ── Investor — Campaigns ─────────────────────────────────
  static String get investorCampaigns => '$server/investor/campaigns';
  static String campaignDetail(int id) => '$server/investor/campaigns/$id';

  // ── Investor — Events ────────────────────────────────────
  static String get investorEvents => '$server/investor/events';
  static String eventDetail(int id) => '$server/investor/events/$id';
  static String eventTicketRequests(int id) =>
      '$server/investor/events/$id/ticket-requests';
  static String ticketRequestAction(int eId, int rId) =>
      '$server/investor/events/$eId/ticket-requests/$rId';

  // ── Investor — Sponsor Events (فعاليات إعلانية) ──────────
  // GET params: page, per_page
  static String get exhibitionSponsorEvents =>
      '$server/investor/sponsor-events';
  static String get investorSponsorships => '$server/investor/sponsorships';
  static String cancelSponsorship(int id) =>
      '$server/investor/sponsorships/$id/cancel';

  // ── Investor — Analytics ─────────────────────────────────
  static String get investorAnalytics => '$server/investor/analytics';

  // ── Investor — Favorites ─────────────────────────────────
  static String get investorFavorites => '$server/investor/favorites';
  static String favoriteItem(int id) => '$server/investor/favorites/$id';

  // ── Investor — Reports ───────────────────────────────────
  static String get investorReports => '$server/investor/reports';
  static String reportDetail(String id, String type) =>
      '$server/investor/reports/$id?type=$type';
  static String reportDownload(String id, String type, String fmt) =>
      '$server/investor/reports/$id/download?type=$type&format=$fmt';
}
