import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/appcolors.dart';
import '../../core/services/services.dart';

class WebTheme {
  static final isDark = true.obs;

  static void init() {
    try {
      isDark.value = Get.find<Services>().isDarkMode;
    } catch (_) {}
  }

  static void setDark(bool v) {
    isDark.value = v;
    // Sync Flutter's own ThemeMode so the entire widget tree rebuilds and all
    // WebTheme.* getters (including border colours) are re-evaluated in every
    // build() call — without this, the inner Obx in _WebHome does not rebuild
    // on isDark change and border colours stay frozen until a hard refresh.
    Get.changeThemeMode(v ? ThemeMode.dark : ThemeMode.light);
    try {
      Get.find<Services>().saveTheme(v);
    } catch (_) {}
  }

  // ── ألوان البنية ─────────────────────────────────────────
  static Color get bg =>
      isDark.value ? const Color(0xFF13112A) : const Color(0xFFF3F3F8);
  static Color get surface =>
      isDark.value ? const Color(0xFF1C1936) : Colors.white;
  static Color get surfaceAlt =>
      isDark.value ? const Color(0xFF221E40) : const Color(0xFFEDEDF4);
  static Color get topbar =>
      isDark.value ? const Color(0xFF181530) : Colors.white;

  // ── النصوص والحدود ───────────────────────────────────────
  static Color get text =>
      isDark.value ? Colors.white : const Color(0xFF1D1A39);
  static Color get text70 => text.withOpacity(0.7);
  static Color get border => isDark.value
      ? Colors.white.withOpacity(0.06)
      : Colors.black.withOpacity(0.08);

  // ── ألوان العلامة التجارية ────────────────────────────────
  static Color get primary =>
      isDark.value ? AppColors.darkPrimary : AppColors.darkPrimary;
  static Color get secondary =>
      isDark.value ? AppColors.darkSecondary : AppColors.darkSecondary;
  static Color get accent =>
      isDark.value ? AppColors.darkAccent : AppColors.darkAccent;
  static Color get pink =>
      isDark.value ? AppColors.darkPink : AppColors.lightSecondary;

  /// لون ثابت للنص فوق التدرجات (أبيض دائماً)
  static const Color onGradient = Colors.white;
}
