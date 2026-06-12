import 'package:expocore_invistor2/core/constant/app_globals.dart';
import 'package:expocore_invistor2/core/constant/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initialbindings.dart';
import 'core/constant/routes.dart';
import 'core/localization/translation.dart';
import 'routes.dart';
import 'core/services/services.dart';
import 'core/responsive/web_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // شبكة أمان: رسالة نظيفة بدل الشاشة الحمراء عند أي خطأ عرض
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
}

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
          // طبقة الويب/التابلت — تُغلّف التطبيق فقط على الشاشات الكبيرة
          child: WebShell(child: child ?? const SizedBox()),
        ),
      ),
    );
  }
}
