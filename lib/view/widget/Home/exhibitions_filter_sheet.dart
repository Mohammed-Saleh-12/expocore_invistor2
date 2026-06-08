import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/exhibitions_controller.dart';
import '../../../core/constant/appcolors.dart';

// ════════════════════════════════════════════════════════════
//  ExhibitionsFilterSheet  —  bottom sheet لفلترة المعارض
//  حسب: الحالة + النوع (القطاع) + البلد
// ════════════════════════════════════════════════════════════
class ExhibitionsFilterSheet extends StatelessWidget {
  const ExhibitionsFilterSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const ExhibitionsFilterSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExhibitionsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(controller),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(
                    icon: Icons.flag_outlined,
                    title: 'الحالة',
                    child: Obx(() => _chips(
                          options: controller.filters,
                          selected: controller.statusFilter.value,
                          onTap: controller.applyFilter,
                          isDark: isDark,
                        )),
                  ),
                  const SizedBox(height: 20),
                  _section(
                    icon: Icons.category_outlined,
                    title: 'النوع / القطاع',
                    child: Obx(() => _chips(
                          options: controller.availableSectors,
                          selected: controller.sectorFilter.value,
                          onTap: controller.setSector,
                          isDark: isDark,
                        )),
                  ),
                  const SizedBox(height: 20),
                  _section(
                    icon: Icons.location_on_outlined,
                    title: 'البلد / المدينة',
                    child: Obx(() => _chips(
                          options: controller.availableCities,
                          selected: controller.cityFilter.value,
                          onTap: controller.setCity,
                          isDark: isDark,
                        )),
                  ),
                ],
              ),
            ),
          ),
          _buildFooter(controller, isDark),
        ],
      ),
    );
  }

  // ── Handle ────────────────────────────────────────────────
  Widget _buildHandle() => Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader(ExhibitionsController controller) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.darkPrimary, size: 22),
            const SizedBox(width: 8),
            const Text(
              'تصفية المعارض',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Obx(() {
              final n = controller.activeFilterCount;
              if (n == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.favoriteGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$n نشط',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              );
            }),
            IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.close_rounded, size: 22),
            ),
          ],
        ),
      );

  // ── Section ───────────────────────────────────────────────
  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  gradient: AppColors.favoriteGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: AppColors.darkPrimary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      );

  // ── Chips ─────────────────────────────────────────────────
  Widget _chips({
    required List<String> options,
    required String selected,
    required void Function(String) onTap,
    required bool isDark,
  }) =>
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((o) {
          final active = o == selected;
          return GestureDetector(
            onTap: () => onTap(o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                gradient: active ? AppColors.favoriteGradient : null,
                color: active
                    ? null
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : AppColors.grey.withOpacity(0.25),
                ),
              ),
              child: Text(
                o,
                style: TextStyle(
                  fontSize: 13,
                  color: active ? Colors.white : AppColors.grey,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      );

  // ── Footer (buttons) ──────────────────────────────────────
  Widget _buildFooter(ExhibitionsController controller, bool isDark) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          border: Border(top: BorderSide(color: AppColors.grey.withOpacity(0.15))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.clearFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.grey.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('مسح الكل', style: TextStyle(color: AppColors.grey)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: Get.back,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: AppColors.favoriteGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkPrimary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Obx(() => Text(
                        'عرض ${controller.filtered.length} نتيجة',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      )),
                ),
              ),
            ),
          ],
        ),
      );
}
