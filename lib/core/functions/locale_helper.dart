import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/app_globals.dart';
import '../services/services.dart';

void changeAppLanguage(String lang) {
  appLang.value = lang;
  Get.updateLocale(Locale(lang, lang == 'ar' ? 'SA' : 'US'));
  try { Get.find<Services>().saveLang(lang); } catch (_) {}
}

/// تبديل بين العربية والإنجليزية
void toggleAppLanguage() =>
    changeAppLanguage(appLang.value == 'ar' ? 'en' : 'ar');
