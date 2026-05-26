import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';
import '../../core/theme/app_theme.dart';

class SettingsController extends GetxController {
  final isDark                  = true.obs;
  final notificationsEnabled    = true.obs;
  final favoritesNotify         = true.obs;
  final reportsNotify           = true.obs;
  final currentLang             = 'ar'.obs;

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
    Get.updateLocale(Locale(lang, lang == 'ar' ? 'SA' : 'US'));
    Get.find<Services>().saveLang(lang);
  }

  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      title: const Text('تسجيل الخروج'),
      content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('إلغاء')),
        TextButton(onPressed: () => Get.back(result: true),  child: const Text('تأكيد', style: TextStyle(color: Colors.red))),
      ],
    ));
    if (confirm == true) {
      await Get.find<Services>().clearSession();
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
