class AppLink {
  static const String server = "https://api.expocore.app/api/v1";

  // ── Auth ───────────────────────────────────────────────────────────
  static const String login                    = "$server/auth/login";
  static const String register                 = "$server/auth/register";
  static const String logout                   = "$server/auth/logout";
  static const String forgotPassword           = "$server/auth/forgot-password";
  static const String refreshToken             = "$server/auth/refresh";

  // ── Exhibitions ────────────────────────────────────────────────────
  static const String exhibitions              = "$server/exhibitions";
  static String exhibitionDetail(int id)       => "$server/exhibitions/$id";

  // ── Booths ─────────────────────────────────────────────────────────
  static const String booths                   = "$server/booths";
  static String boothDetail(int id)            => "$server/booths/$id";
  static const String bookBooth                = "$server/booths/book";

  // ── Investor — Dashboard ───────────────────────────────────────────
  static const String investorDashboard        = "$server/investor/dashboard";

  // ── Investor — Profile ─────────────────────────────────────────────
  static const String investorProfile          = "$server/investor/profile";

  // ── Investor — Bookings ────────────────────────────────────────────
  static const String investorBookings         = "$server/investor/bookings";
  static String bookingDetail(int id)          => "$server/investor/bookings/$id";
  static String cancelBooking(int id)          => "$server/investor/bookings/$id/cancel";

  // ── Investor — Campaigns ───────────────────────────────────────────
  static const String investorCampaigns        = "$server/investor/campaigns";
  static String campaignDetail(int id)         => "$server/investor/campaigns/$id";

  // ── Investor — Events (investor's own) ────────────────────────────
  static const String investorEvents           = "$server/investor/events";
  static String eventDetail(int id)            => "$server/investor/events/$id";
  static String eventTicketRequests(int id)    => "$server/investor/events/$id/ticket-requests";
  static String ticketRequestAction(int eventId, int reqId) =>
      "$server/investor/events/$eventId/ticket-requests/$reqId";

  // ── Investor — Sponsor Events (exhibition-announced) ──────────────
  static const String exhibitionSponsorEvents  = "$server/investor/sponsor-events";
  static const String investorSponsorships     = "$server/investor/sponsorships";
  static String cancelSponsorship(int id)      => "$server/investor/sponsorships/$id/cancel";

  // ── Investor — Analytics ───────────────────────────────────────────
  static const String investorAnalytics        = "$server/investor/analytics";

  // ── Investor — Messages (exhibition departments) ───────────────────
  static const String investorMessages         = "$server/investor/messages";
  static String conversationDetail(int id)     => "$server/investor/messages/$id";
  static String sendMessage(int convId)        => "$server/investor/messages/$convId/send";

  // ── Investor — Visitor Messages ────────────────────────────────────
  static const String investorVisitorMessages        = "$server/investor/visitor-messages";
  static String visitorConversationDetail(int id)    => "$server/investor/visitor-messages/$id";
  static String sendVisitorMessage(int convId)       => "$server/investor/visitor-messages/$convId/send";

  // ── Investor — Favorites ───────────────────────────────────────────
  static const String investorFavorites              = "$server/investor/favorites";
  static String favoriteExhibition(int id)           => "$server/investor/favorites/exhibitions/$id";
  static String favoriteBooth(int id)                => "$server/investor/favorites/booths/$id";
  static String favoriteEvent(int id)                => "$server/investor/favorites/events/$id";

  // ── Investor — Reports ─────────────────────────────────────────────
  static const String investorReports                = "$server/investor/reports";
  static String reportDetail(String id)              => "$server/investor/reports/$id";
  static String reportDownload(String id, String fmt)=> "$server/investor/reports/$id/download?format=$fmt";

  // ── Investor — Notifications ───────────────────────────────────────
  static const String investorNotifications          = "$server/investor/notifications";
  static String markNotificationRead(int id)         => "$server/investor/notifications/$id/read";
  static const String markAllNotificationsRead       = "$server/investor/notifications/read-all";

  // ── Investor — Booth Profile ───────────────────────────────────────
  static String boothProfile(int boothId)            => "$server/investor/booths/$boothId/profile";
}
