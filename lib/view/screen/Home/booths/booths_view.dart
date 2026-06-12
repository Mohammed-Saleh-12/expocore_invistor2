import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/booth_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/bottom_nav_custom.dart';
import '../../../widget/Home/booth_card.dart';
import '../../../widget/Home/empty_widget.dart';

class BoothsView extends GetView<BoothController> {
  const BoothsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavCustom(),
      body: Column(
        children: [
          const SizedBox(height: 36),
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: controller.filters.map((f) {
                  final active = controller.statusFilter.value == f;
                  return GestureDetector(
                    onTap: () => controller.applyFilter(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: active ? AppColors.favoriteGradient : null,
                        color: active
                            ? null
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkCard
                                  : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          color: active ? Colors.white : AppColors.grey,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.filtered.isEmpty) {
                return EmptyWidget(
                  message: 'لا توجد أجنحة',
                  buttonLabel: 'حجز جناح',
                  onAction: () => Get.toNamed(AppRoutes.EXHIBITIONS),
                );
              }
              return ListView.builder(
                itemCount: controller.filtered.length,
                itemBuilder: (_, i) {
                  final b = controller.filtered[i];
                  final isApproved = b.status == 'active';
                  final isEnded    = b.status == 'ended';
                  return BoothCard(
                    booth: b,
                    onManage: () => isApproved
                        ? Get.toNamed(AppRoutes.BOOTH_MANAGEMENT, arguments: b)
                        : Get.toNamed(AppRoutes.BOOTH_DETAIL, arguments: b),
                    onFavorite: () => controller.toggleFavorite(b),
                    onReport: (isApproved || isEnded)
                        ? () => controller.openBoothReport(b)
                        : null,
                    onViewMap: (!isApproved && !isEnded)
                        ? () => Get.toNamed(AppRoutes.BOOTH_MAP_3D)
                        : null,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
