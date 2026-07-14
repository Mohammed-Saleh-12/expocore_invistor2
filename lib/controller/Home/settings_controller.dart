import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../core/constant/app_globals.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';
import '../../data/sourcedata/remote/Auth/LogoutData.dart';

class SettingsController extends GetxController {
  final LogoutData _logoutData = LogoutData(Crud());
  final isDark               = true.obs;
  final notificationsEnabled = true.obs;
  final favoritesNotify      = true.obs;
  final reportsNotify        = true.obs;
  final currentLang          = 'ar'.obs;
  final isLoggingOut         = false.obs;

  @override
  void onInit() {
    isDark.value      = Get.find<Services>().isDarkMode;
    currentLang.value = Get.find<Services>().lang;
    super.onInit();
  }

  void toggleTheme(bool val) {
    isDark.value = val;
    Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
    Get.find<Services>().saveTheme(val);
  }

  void changeLanguage(String lang) {
    currentLang.value = lang;
    appLang.value     = lang;
    Get.updateLocale(Locale(lang, lang == 'ar' ? 'SA' : 'US'));
    Get.find<Services>().saveLang(lang);
  }

  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      title:   Text('settings_logout'.tr),
      content: Text('settings_logout_confirm'.tr),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('btn_cancel'.tr),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text('btn_confirm'.tr,
              style: const TextStyle(color: Colors.red)),
        ),
      ],
    ));

    if (confirm == true) {
      isLoggingOut.value = true;
      await _logoutData.logout();
      await Get.find<Services>().clearSession();
      isLoggingOut.value = false;
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
