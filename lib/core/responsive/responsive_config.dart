import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
//  ResponsiveConfig  —  breakpoints & helpers
//  ⚠️  يُستخدم فقط لطبقة الويب/التابلت — لا يمسّ شاشات الجوال
// ════════════════════════════════════════════════════════════
class ResponsiveConfig {
  ResponsiveConfig._();

  // ── Breakpoints ──────────────────────────────────────────
  static const double mobileMax  = 700;   // أقل من هذا = جوال (يُعرض كما هو)
  static const double tabletMax  = 1150;   // بين = تابلت (إطار فقط)
  // أكبر من tabletMax = ديسكتوب (إطار + لوحة جانبية)

  // ── إطار الجهاز داخل الويب ────────────────────────────────
  static const double frameWidth     = 430;
  static const double frameMaxHeight = 900;
  static const double frameRadius    = 44;

  // ── Device type ──────────────────────────────────────────
  static bool isMobile(double w)  => w < mobileMax;
  static bool isTablet(double w)  => w >= mobileMax && w < tabletMax;
  static bool isDesktop(double w) => w >= tabletMax;

  /// هل نعرض طبقة الويب الفخمة؟ (تابلت أو ديسكتوب)
  static bool useWebShell(double w) => w >= mobileMax;
}

// ── Context extension للوصول السريع ─────────────────────────
extension ResponsiveContext on BuildContext {
  double get screenWidth  => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile  => ResponsiveConfig.isMobile(screenWidth);
  bool get isTablet  => ResponsiveConfig.isTablet(screenWidth);
  bool get isDesktop => ResponsiveConfig.isDesktop(screenWidth);
}
