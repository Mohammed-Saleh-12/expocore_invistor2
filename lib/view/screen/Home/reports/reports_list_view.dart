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
        title: 'التقارير والتحليلات',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.darkPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: controller.typeFilters.map((f) {
                  final active = controller.selectedType.value == f;
                  return GestureDetector(
                    onTap: () => controller.filterByType(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: active ? AppColors.darkCTAGradient : null,
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
          _dateRangeBar(context),
          Expanded(
            child: Obx(() {
              if (controller.filtered.isEmpty)
                return const EmptyWidget(message: 'لا توجد تقارير');
              return ListView.builder(
                itemCount: controller.filtered.length,
                itemBuilder: (_, i) {
                  final r = controller.filtered[i];
                  return Obx(
                    () => ReportCard(
                      report: r,
                      isDownloading: controller.isDownloading.value,
                      onView: () =>
                          Get.toNamed(AppRoutes.REPORT_DETAIL, arguments: r),
                      onDownload: () => controller.downloadReport(r.id),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _dateRangeBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.date_range_outlined,
            size: 18,
            color: AppColors.grey,
          ),
          const SizedBox(width: 8),
          const Text(
            'من: 2026-07-01  إلى: 2026-07-31',
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'تغيير',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
