import 'package:flutter/material.dart';
import '../web_theme.dart';
import 'package:get/get.dart';
import '../../controller/Home/reports_controller.dart';
import '../../core/constant/appcolors.dart';
import '../../data/model/report/report_model.dart';
import '../widgets/web_section_header.dart';
import '../controllers/web_nav_controller.dart';

// ════════════════════════════════════════════════════════════
//  WebReportsPage  —  التقارير
// ════════════════════════════════════════════════════════════
class WebReportsPage extends StatelessWidget {
  const WebReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReportsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WebSectionHeader(title: 'التقارير', subtitle: 'تقارير الأداء والتحليلات'),
          const SizedBox(height: 20),

          // ── Type filters ─────────────────────────────────
          Obx(() => Wrap(
                spacing: 8, runSpacing: 8,
                children: c.typeFilters.map((t) {
                  final active = c.selectedType.value == t;
                  return GestureDetector(
                    onTap: () => c.filterByType(t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: active ? AppColors.favoriteGradient : null,
                        color: active ? null : WebTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t,
                          style: TextStyle(
                            color: active ? WebTheme.text : AppColors.grey,
                            fontSize: 13,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          )),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 16),

          // ── Date range bar ───────────────────────────────
          Obx(() => Row(
                children: [
                  Expanded(child: _dateBox(context, 'من', c.dateFrom.value, (d) => c.dateFrom.value = d)),
                  const SizedBox(width: 12),
                  Expanded(child: _dateBox(context, 'إلى', c.dateTo.value, (d) => c.dateTo.value = d)),
                ],
              )),
          const SizedBox(height: 24),

          // ── Reports list ─────────────────────────────────
          Obx(() {
            final list = c.filtered.toList();
            if (list.isEmpty) {
              return Container(
                width: double.infinity, padding: const EdgeInsets.all(60), alignment: Alignment.center,
                child: Column(children: [
                  Icon(Icons.bar_chart_rounded, size: 56, color: AppColors.grey.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text('لا توجد تقارير', style: TextStyle(color: AppColors.grey)),
                ]),
              );
            }
            return Column(children: list.map((r) => _ReportRow(report: r, c: c)).toList());
          }),
        ],
      ),
    );
  }

  Widget _dateBox(BuildContext context, String label, DateTime? value, ValueChanged<DateTime> onPick) =>
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime(2026, 6, 1),
            firstDate: DateTime(2025, 1, 1),
            lastDate: DateTime(2027, 12, 31),
          );
          if (picked != null) onPick(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: WebTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: WebTheme.border)),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined, color: AppColors.darkPrimary, size: 18),
            const SizedBox(width: 10),
            Text(value == null ? label : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
                style: TextStyle(color: value == null ? AppColors.grey : WebTheme.text, fontSize: 13)),
          ]),
        ),
      );
}

class _ReportRow extends StatelessWidget {
  final ReportModel report;
  final ReportsController c;
  const _ReportRow({required this.report, required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => WebNavController.to.openReport(report),
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: AppColors.darkPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.description_outlined, color: AppColors.darkPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title,
                    style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${report.boothName} • ${report.period} • ${report.createdAt}',
                    style: TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
          // KPI
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(report.mainValue.toInt().toString(),
                  style: TextStyle(color: WebTheme.text, fontSize: 18, fontWeight: FontWeight.w900)),
              Text(report.mainLabel, style: TextStyle(color: AppColors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('+${report.trend}%',
                style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 16),
          // Download
          Obx(() => IconButton(
                onPressed: c.isDownloading.value ? null : () => c.downloadReport(report.id),
                icon: c.isDownloading.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkPrimary))
                    : Icon(Icons.download_rounded, color: AppColors.darkPrimary),
              )),
        ],
      ),
      ),
    );
  }
}
