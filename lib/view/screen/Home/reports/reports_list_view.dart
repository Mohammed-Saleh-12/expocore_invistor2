import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/reports_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/report_card.dart';
import '../../../widget/Home/empty_widget.dart';

class ReportsListView extends GetView<ReportsController> {
  const ReportsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'reports_analytics_title'.tr,
        actions: [
          // Clear date filter badge / button
          Obx(() => controller.hasDateFilter
              ? IconButton(
                  icon: const Icon(Icons.filter_alt_off_rounded,
                      color: AppColors.darkSecondary),
                  tooltip: 'reports_clear_date_tooltip'.tr,
                  onPressed: controller.clearDateFilter,
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // ── Type chips ──────────────────────────────────────
          Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: controller.typeFilters.map((f) {
                    final active = controller.selectedType.value == f;
                    return GestureDetector(
                      onTap: () => controller.filterByType(f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient:
                              active ? AppColors.favoriteGradient : null,
                          color: active
                              ? null
                              : (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.darkCard
                                  : AppColors.lightSurface),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          f.tr,
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
              )),

          // ── Date range picker bar ───────────────────────────
          _DateRangeBar(controller: controller),

          // ── Reports list ────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.filtered.isEmpty) {
                return EmptyWidget(message: 'reports_no_reports'.tr);
              }
              return ListView.builder(
                itemCount: controller.filtered.length,
                itemBuilder: (_, i) {
                  final r = controller.filtered[i];
                  return Obx(() => ReportCard(
                        report: r,
                        isDownloading: controller.isDownloading.value,
                        onView: () => Get.toNamed(
                            AppRoutes.REPORT_DETAIL,
                            arguments: r),
                        onDownload: () =>
                            controller.downloadReport(r.id),
                      ));
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  _DateRangeBar  —  View فقط (MVC)
//  يعرض التواريخ المختارة من الكنترولر ويفتح DatePicker عند الضغط
// ════════════════════════════════════════════════════════════
class _DateRangeBar extends StatelessWidget {
  final ReportsController controller;
  const _DateRangeBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final from = controller.dateFrom.value;
      final to   = controller.dateTo.value;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: controller.hasDateFilter
                ? AppColors.darkPrimary.withOpacity(0.5)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Row(
                children: [
                  Icon(Icons.date_range_outlined,
                      size: 16,
                      color: controller.hasDateFilter
                          ? AppColors.darkPrimary
                          : AppColors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'reports_date_filter'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: controller.hasDateFilter
                          ? AppColors.darkPrimary
                          : AppColors.grey,
                    ),
                  ),
                  const Spacer(),
                  if (controller.hasDateFilter)
                    GestureDetector(
                      onTap: controller.clearDateFilter,
                      child: Text(
                        'reports_clear'.tr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.darkSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 0.5),

            // ── From / To pickers ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _DatePickerTile(
                      label: 'reports_date_from'.tr,
                      value: from,
                      controller: controller,
                      onPick: (picked) => controller.filterByDate(
                          picked, controller.dateTo.value),
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: isDark
                        ? Colors.white12
                        : Colors.black.withOpacity(0.08),
                  ),
                  Expanded(
                    child: _DatePickerTile(
                      label: 'reports_date_to'.tr,
                      value: to,
                      controller: controller,
                      onPick: (picked) => controller.filterByDate(
                          controller.dateFrom.value, picked),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Single date picker tile ───────────────────────────────────
class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ReportsController controller;
  final ValueChanged<DateTime> onPick;
  final bool isDark;

  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.controller,
    required this.onPick,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2024, 1, 1),
          lastDate: DateTime(2028, 12, 31),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.darkPrimary,
                surface: isDark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPick(picked);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.darkPrimary.withOpacity(0.1)
              : (isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              hasValue
                  ? Icons.calendar_today_rounded
                  : Icons.calendar_today_outlined,
              size: 14,
              color: hasValue ? AppColors.darkPrimary : AppColors.grey,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    hasValue
                        ? controller.formatDate(value)
                        : 'reports_pick_date'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasValue
                          ? AppColors.darkPrimary
                          : AppColors.grey.withOpacity(0.6),
                      fontWeight: hasValue
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
