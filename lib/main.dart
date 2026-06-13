import 'dart:async';
import 'package:expocore_invistor2/core/constant/app_globals.dart';
import 'package:expocore_invistor2/core/constant/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initialbindings.dart';
import 'core/constant/routes.dart';
import 'core/localization/translation.dart';
import 'routes.dart';
import 'core/services/services.dart';
import 'core/responsive/web_shell.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ── Flutter framework error handler ──────────────────────
      // Catches errors thrown during widget build/layout/painting.
      FlutterError.onError = (FlutterErrorDetails details) {
        if (_isOverlayNullError(details.exception)) {
          // Snackbar called before overlay was ready — harmless, skip.
          debugPrint('[ExpoCore] Snackbar overlay not ready — skipped');
          return;
        }
        // Everything else: show the nice error widget instead of red screen.
        FlutterError.presentError(details);
      };

      // ── Platform dispatcher error handler (web async errors) ─
      PlatformDispatcher.instance.onError = (error, stack) {
        if (_isOverlayNullError(error)) {
          debugPrint('[ExpoCore] Snackbar overlay not ready — skipped');
          return true; // handled
        }
        debugPrint('[ExpoCore] Uncaught error: $error');
        return false; // let the default handler deal with it
      };

      // ── Custom error widget (no red screen) ──────────────────
      ErrorWidget.builder = (FlutterErrorDetails details) => Material(
        color: const Color(0xFF1D1A39),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFFF1592),
                  size: 48,
                ),
                const SizedBox(height: 14),
                const Text(
                  'حدث خطأ في عرض هذا الجزء',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'يرجى إعادة المحاولة أو تحديث الصفحة',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

      final services = await Get.putAsync(() => Services().init());
      appLang.value = services.lang;
      runApp(ExpoCore(isDark: services.isDarkMode));
    },
    (error, stack) {
      // ── Zone-level error catch (unhandled async exceptions) ───
      if (_isOverlayNullError(error)) {
        debugPrint('[ExpoCore] Snackbar overlay not ready — skipped');
        return;
      }
      debugPrint('[ExpoCore] Zone error: $error\n$stack');
    },
  );
}

/// Returns true when the error is a GetX snackbar overlay-not-ready crash.
/// The snackbar calls `overlayState!.insertAll(...)` — if the overlay hasn't
/// mounted yet, Dart throws a Null-check error.  We silence it because the
/// UI is still functional; the snackbar simply wasn't shown.
bool _isOverlayNullError(Object error) {
  if (error is! TypeError && error.runtimeType.toString() != '_TypeError') {
    return false;
  }
  final msg = error.toString().toLowerCase();
  return msg.contains('null') &&
      (msg.contains('insert') ||
          msg.contains('overlay') ||
          msg.contains('snackbar'));
}

// ════════════════════════════════════════════════════════════
//  ExpoCore  —  Root widget
// ════════════════════════════════════════════════════════════
class ExpoCore extends StatelessWidget {
  final bool isDark;
  const ExpoCore({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ExpoCore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      translations: MyTranslation(),
      locale: Locale(appLang.value, appLang.value == 'ar' ? 'SA' : 'US'),
      fallbackLocale: const Locale('ar', 'SA'),
      initialBinding: InitialBindings(),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      navigatorKey: Get.key,
      defaultTransition: Transition.fadeIn,
      builder: (context, child) => Obx(
        () => Directionality(
          textDirection: appLang.value == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: WebShell(child: child ?? const SizedBox()),
        ),
      ),
    );
  }
}
