class AppLink {
  static const String server = "https://api.expocore.app/api/v1";

  static const String login            = "$server/auth/login";
  static const String register         = "$server/auth/register";
  static const String logout           = "$server/auth/logout";
  static const String forgotPassword   = "$server/auth/forgot-password";
  static const String refreshToken     = "$server/auth/refresh";

  static const String exhibitions      = "$server/exhibitions";
  static const String exhibitionDetail = "$server/exhibitions/";

  static const String booths           = "$server/booths";
  static const String bookBooth        = "$server/booths/book";

  static const String investorProfile   = "$server/investor/profile";
  static const String investorBookings  = "$server/investor/bookings";
  static const String investorCampaigns = "$server/investor/campaigns";
  static const String investorEvents    = "$server/investor/events";
  static const String investorAnalytics = "$server/investor/analytics";
  static const String investorMessages  = "$server/investor/messages";
  static const String investorFavorites = "$server/investor/favorites";
  static const String investorReports   = "$server/investor/reports";
  static const String investorNotifications = "$server/investor/notifications";
}
