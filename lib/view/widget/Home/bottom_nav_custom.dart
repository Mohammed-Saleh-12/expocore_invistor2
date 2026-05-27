import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';

class BottomNavCustom extends StatelessWidget {
  const BottomNavCustom({super.key});

  static const _items = [
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      'label': 'الرئيسية',
    },
    {
      'icon': Icons.store_outlined,
      'activeIcon': Icons.store,
      'label': 'المعارض',
    },
    {
      'icon': Icons.grid_view_outlined,
      'activeIcon': Icons.grid_view,
      'label': 'أجنحتي',
    },
    {
      'icon': Icons.favorite_outline,
      'activeIcon': Icons.favorite,
      'label': 'المفضلة',
    },
    {
      'icon': Icons.more_horiz_outlined,
      'activeIcon': Icons.more_horiz,
      'label': 'المزيد',
    },
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
            children: List.generate(_items.length, (i) {
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
                                _items[i]['activeIcon'] as IconData,
                                color: Colors.white,
                                size: 24,
                              ),
                            )
                          : Icon(
                              _items[i]['icon'] as IconData,
                              color: AppColors.grey,
                              size: 24,
                            ),
                      const SizedBox(height: 2),
                      Text(
                        _items[i]['label'] as String,
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
