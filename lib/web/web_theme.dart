import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/services.dart';

// ════════════════════════════════════════════════════════════
//  WebTheme  —  ألوان تفاعلية لنسخة الويب (دارك/لايت)
//  تُقرأ داخل شجرة ملفوفة بـ Obx فتتبدّل كاملة عند التغيير
// ════════════════════════════════════════════════════════════
class WebTheme {
  static final isDark = true.obs;

  static void init() {
    try { isDark.value = Get.find<Services>().isDarkMode; } catch (_) {}
  }

  static void setDark(bool v) {
    isDark.value = v;
    try { Get.find<Services>().saveTheme(v); } catch (_) {}
  }

  // ── ألوان البنية ─────────────────────────────────────────
  static Color get bg         => isDark.value ? const Color(0xFF13112A) : const Color(0xFFF3F3F8);
  static Color get surface    => isDark.value ? const Color(0xFF1C1936) : Colors.white;
  static Color get surfaceAlt => isDark.value ? const Color(0xFF221E40) : const Color(0xFFEDEDF4);
  static Color get topbar     => isDark.value ? const Color(0xFF181530) : Colors.white;

  // ── النصوص والحدود ───────────────────────────────────────
  static Color get text       => isDark.value ? Colors.white : const Color(0xFF1D1A39);
  static Color get text70     => text.withOpacity(0.7);
  static Color get border     => isDark.value ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.08);

  /// لون ثابت للنص فوق التدرجات (أبيض دائماً)
  static const Color onGradient = Colors.white;
}
