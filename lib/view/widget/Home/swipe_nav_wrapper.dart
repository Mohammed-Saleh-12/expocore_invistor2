import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/routes.dart';

/// يُلفّ محتوى الصفحة ويضيف إيماءة السحب للتنقّل بين صفحات الـ BottomNav
class SwipeNavWrapper extends StatelessWidget {
  final Widget child;
  const SwipeNavWrapper({super.key, required this.child});

  static const _routes = [
    AppRoutes.DASHBOARD,
    AppRoutes.EXHIBITIONS,
    AppRoutes.BOOTHS,
    AppRoutes.FAVORITES,
    AppRoutes.SETTINGS,
  ];

  int _currentIndex() {
    final route = Get.currentRoute;
    for (int i = 0; i < _routes.length; i++) {
      if (route == _routes[i]) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // HitTestBehavior.translucent: يسمح للـ scrollable داخله بالعمل أيضاً
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final vx = details.primaryVelocity ?? 0;
        // عتبة السرعة: 350 px/s لتفادي النقرات العرضية
        if (vx.abs() < 350) return;

        final idx = _currentIndex();
        // السحب يميناً (vx > 0) → صفحة سابقة (فهرس أقل)
        // السحب يساراً (vx < 0) → صفحة تالية (فهرس أكبر)
        final next = vx > 0 ? idx - 1 : idx + 1;
        if (next < 0 || next >= _routes.length) return;

        Get.offAllNamed(_routes[next]);
      },
      child: child,
    );
  }
}
