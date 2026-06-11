import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';

class BottomNavCustom extends StatelessWidget {
  const BottomNavCustom({super.key});

  static const _icons = [
    Icons.home_outlined,
    Icons.store_outlined,
    Icons.grid_view_outlined,
    Icons.favorite_outline,
    Icons.more_horiz_outlined,
  ];
  static const _activeIcons = [
    Icons.home,
    Icons.store,
    Icons.grid_view,
    Icons.favorite,
    Icons.more_horiz,
  ];
  static const _labelKeys = [
    'nav_home',
    'nav_exhibitions',
    'nav_my_booths',
    'nav_favorites',
    'nav_more',
  ];
  static const _routes = [
    AppRoutes.DASHBOARD,
    AppRoutes.EXHIBITIONS,
    AppRoutes.BOOTHS,
    AppRoutes.FAVORITES,
    AppRoutes.SETTINGS,
  ];

  int _activeIndex() {
    final route = Get.currentRoute;
    for (int i = 0; i < _routes.length; i++) {
      if (route == _routes[i]) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeIdx = _activeIndex();
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_icons.length, (i) {
              final isActive = activeIdx == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.offAllNamed(_routes[i]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isActive
                          ? ShaderMask(
                              shaderCallback: (b) =>
                                  AppColors.darkCTAGradient.createShader(b),
                              child: Icon(
                                _activeIcons[i],
                                color: Colors.white,
                                size: 24,
                              ),
                            )
                          : Icon(_icons[i], color: AppColors.grey, size: 24),
                      const SizedBox(height: 2),
                      Text(
                        _labelKeys[i].tr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? AppColors.darkPrimary
                              : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
