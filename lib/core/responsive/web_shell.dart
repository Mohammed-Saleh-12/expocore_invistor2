import 'package:flutter/material.dart';
import '../../web/view/pages/web_app.dart';
import 'responsive_config.dart';

// ════════════════════════════════════════════════════════════
//  WebShell  —  المبدّل الذكي بين نسخة الويب ونسخة الجوال
//  • جوال (< 700): يمرّر تطبيق الجوال كما هو (صفر تغيير)
//  • تابلت/ويب (>= 700): يعرض نسخة الويب الكاملة WebApp
//    (موقع حقيقي بشريط جانبي وصفحات عريضة)
// ════════════════════════════════════════════════════════════
class WebShell extends StatelessWidget {
  final Widget child;
  const WebShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!ResponsiveConfig.useWebShell(constraints.maxWidth)) {
          return child; // ← نسخة الجوال كما هي
        }
        return const WebApp(); // ← نسخة الويب الكاملة
      },
    );
  }
}
