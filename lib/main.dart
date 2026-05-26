import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initialbindings.dart';
import 'core/constant/routes.dart';
import 'core/localization/translation.dart';
import 'core/routes/app_pages.dart';
import 'core/services/services.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await Get.putAsync(() => Services().init());
  runApp(ExpoCore(isDark: services.isDarkMode));
}

class ExpoCore extends StatelessWidget {
  final bool isDark;
  const ExpoCore({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title:          'ExpoCore — منصة المستثمر',
      debugShowCheckedModeBanner: false,
      theme:          AppTheme.lightTheme,
      darkTheme:      AppTheme.darkTheme,
      themeMode:      isDark ? ThemeMode.dark : ThemeMode.light,
      translations:   MyTranslation(),
      locale:         const Locale('ar', 'SA'),
      fallbackLocale: const Locale('en', 'US'),
      initialBinding: InitialBindings(),
      initialRoute:   AppRoutes.SPLASH,
      getPages:       AppPages.routes,
      defaultTransition: Transition.fadeIn,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox(),
      ),
    );
  }
}
