import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../controller/Home/dashboard_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final DashboardController ctrl = Get.put(DashboardController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(
      () => Container(
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
                final isActive = ctrl.currentIndex.value == i;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ctrl.currentIndex.value = i;
                      Get.offAllNamed(_routes[i]);
                    },
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
      ),
    );
  }
}
