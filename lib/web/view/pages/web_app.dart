import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../controllers/web_auth_controller.dart';
import '../../controllers/web_nav_controller.dart';
import 'web_login_page.dart';
import 'web_register_page.dart';
import 'web_forgot_password_page.dart';
import 'web_reset_password_page.dart';
import '../widgets/web_sidebar.dart';
import '../widgets/web_topbar.dart';
import 'web_dashboard_page.dart';
import 'web_exhibitions_page.dart';
import 'web_booths_page.dart';
import 'web_events_page.dart';
import 'web_reports_page.dart';
import 'web_messages_page.dart';
import 'web_favorites_page.dart';
import 'web_settings_page.dart';
import 'web_sponsorships_page.dart';
import 'web_detail_view.dart';
import 'web_create_event_page.dart';


class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    WebTheme.init();
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const _WebRoot()),
    );
  }
}

// ── Auth gate ────────────────────────────────────────────────
class _WebRoot extends StatelessWidget {
  const _WebRoot();

  @override
  Widget build(BuildContext context) {
    final auth = WebAuthController.to;
    return Obx(() {
      if (auth.loggedIn.value)           return _WebHome();
      if (auth.showResetPassword.value)  return WebResetPasswordPage();
      if (auth.showForgotPassword.value) return WebForgotPasswordPage();
      if (auth.showRegister.value)       return WebRegisterPage();
      return WebLoginPage();
    });
  }
}


// _WebHome
class _WebHome extends StatelessWidget {
  const _WebHome();

  Widget _page(int i) {
    switch (i) {
      case 0: return WebDashboardPage();
      case 1: return WebExhibitionsPage();
      case 2: return WebBoothsPage();
      case 3: return WebEventsPage();
      case 4: return WebCreateEventPage();
      case 5: return WebSponsorshipsPage();
      case 6: return WebReportsPage();
      case 7: return WebMessagesPage();
      case 8: return WebFavoritesPage();
      case 9: return WebSettingsPage();
      
      default: return WebDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav  = WebNavController.to;
    final auth = WebAuthController.to;

    return Obx(() {
      WebTheme.isDark.value;
      return Scaffold(
        backgroundColor: WebTheme.bg,
        body: Row(
          children: [
            Obx(() => WebSidebar(
                  sections: WebNavController.sections,
                  selected: nav.selected.value,
                  onSelect: nav.select,
                  onLogout: auth.logout,
                )),
            Expanded(
              child: Column(
                children: [
                  const WebTopbar(),
                  Expanded(
                    child: Obx(() {
                      final detail  = nav.detail.value;
                      final content = detail != null
                          ? WebDetailView(request: detail)
                          : _page(nav.selected.value);
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(detail != null
                              ? 'detail-${detail.type}'
                              : 'section-${nav.selected.value}'),
                          child: content,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
