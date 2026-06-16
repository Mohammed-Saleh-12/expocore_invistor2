import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/exhibitions_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/bottom_nav_custom.dart';
import '../../../widget/Home/exhibition_card.dart';
import '../../../widget/Home/loading_widget.dart';
import '../../../widget/Home/empty_widget.dart';
import '../../../widget/Home/exhibitions_filter_sheet.dart';

class ExhibitionsListView extends GetView<ExhibitionsController> {
  const ExhibitionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavCustom(),
      body: Column(
        children: [
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                // ── Search bar + filter button ──────────────
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.searchCtrl,
                        textDirection: TextDirection.rtl,
                        onChanged: controller.onSearch,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن معرض...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.grey,
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _FilterButton(controller: controller),
                  ],
                ),
                const SizedBox(height: 10),
                // ── Active filters strip ────────────────────
                _ActiveFilters(controller: controller),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingWidget();
              if (controller.filtered.isEmpty) {
                return EmptyWidget(
                  message: 'لا توجد معارض',
                  buttonLabel: 'تحديث',
                  onAction: controller.refresh,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  itemCount: controller.filtered.length,
                  itemBuilder: (_, i) {
                    final e = controller.filtered[i];
                    return ExhibitionCard(
                      exhibition: e,
                      onTap: () => Get.toNamed(
                        AppRoutes.EXHIBITION_DETAIL,
                        arguments: e,
                      ),
                      onFavorite: () => controller.toggleFavorite(e),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Filter button with active-count badge
// ════════════════════════════════════════════════════════════
class _FilterButton extends StatelessWidget {
  final ExhibitionsController controller;
  const _FilterButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ExhibitionsFilterSheet.show,
      child: Obx(() {
        final count = controller.activeFilterCount;
        final hasActive = count > 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: hasActive ? AppColors.favoriteGradient : null,
                color: hasActive
                    ? null
                    : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkCard
                          : AppColors.lightCard),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: hasActive ? Colors.white : AppColors.grey,
                size: 22,
              ),
            ),
            if (hasActive)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.darkSecondary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  final ExhibitionsController controller;
  const _ActiveFilters({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chips = <Widget>[];

      if (controller.statusFilter.value != 'الكل') {
        chips.add(
          _chip(
            controller.statusFilter.value,
            () => controller.applyFilter('الكل'),
          ),
        );
      }
      if (controller.sectorFilter.value != 'الكل') {
        chips.add(
          _chip(
            controller.sectorFilter.value,
            () => controller.setSector('الكل'),
          ),
        );
      }
      if (controller.cityFilter.value != 'الكل') {
        chips.add(
          _chip(controller.cityFilter.value, () => controller.setCity('الكل')),
        );
      }

      if (chips.isEmpty) return const SizedBox.shrink();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      );
    });
  }

  Widget _chip(String label, VoidCallback onRemove) => Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.only(right: 12, left: 6, top: 6, bottom: 6),
    decoration: BoxDecoration(
      color: AppColors.darkPrimary.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.darkPrimary.withOpacity(0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkPink,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(
            Icons.close_rounded,
            size: 14,
            color: AppColors.darkPrimary,
          ),
        ),
      ],
    ),
  );
}
