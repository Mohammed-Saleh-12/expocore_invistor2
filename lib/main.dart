import 'package:expocore_invistor2/core/constant/app_globals.dart';
import 'package:expocore_invistor2/core/constant/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initialbindings.dart';
import 'core/constant/routes.dart';
import 'core/localization/translation.dart';
import 'routes.dart';
import 'core/services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      defaultTransition: Transition.fadeIn,
      builder: (context, child) => Obx(
        () => Directionality(
          textDirection: appLang.value == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child ?? const SizedBox(),
        ),
      ),
    );
  }
}
