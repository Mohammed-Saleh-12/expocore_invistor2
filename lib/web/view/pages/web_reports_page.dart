import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/reports_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/report/report_model.dart';
import '../widgets/web_section_header.dart';
import '../../controllers/web_nav_controller.dart';

class WebReportsPage extends StatelessWidget {
  const WebReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReportsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: WebTheme.bg,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WebSectionHeader(
                title: 'reports_title'.tr,
                subtitle: 'reports_subtitle'.tr,
              ),
              const SizedBox(height: 20),

              // ── Type filter chips ────────────────────────
              Obx(() {
                final selectedType = c.selectedType.value;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: c.typeFilters.map((t) {
                    final active = selectedType == t;
                    return GestureDetector(
                      onTap: () => c.filterByType(t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: active ? AppColors.favoriteGradient : null,
                          color: active ? null : WebTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: active
                              ? null
                              : Border.all(color: WebTheme.border),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            color: active ? Colors.white : AppColors.grey,
                            fontSize: 13,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 12),

              // ── Date filters + clear button ───────────────
              Obx(() {
                final from    = c.dateFrom.value;
                final to      = c.dateTo.value;
                final hasAny  = c.hasActiveFilter;

                return Row(
                  children: [
                    // ── From date ───────────────────────────
                    Expanded(
                      child: _DateBox(
                        label: 'reports_date_from'.tr,
                        value: from,
                        onPick: (d) => c.filterByDate(d, c.dateTo.value),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // ── To date ─────────────────────────────
                    Expanded(
                      child: _DateBox(
                        label: 'reports_date_to'.tr,
                        value: to,
                        onPick: (d) => c.filterByDate(c.dateFrom.value, d),
                      ),
                    ),

                    // ── Clear button (visible when any filter active) ──
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: hasAny
                          ? Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Tooltip(
                                message: 'مسح الفلاتر',
                                child: GestureDetector(
                                  onTap: c.clearAllFilters,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.error.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.filter_alt_off_rounded,
                                          color: AppColors.error,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'مسح',
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── Report list ──────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Obx(() {
              // استخدام .value صراحةً لضمان تتبّع GetX للتغييرات
              final list = c.filtered.value;
              if (list.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(60),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 56,
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'reports_no_reports'.tr,
                        style: TextStyle(color: AppColors.grey),
                      ),
                      // زر مسح الفلاتر عند عدم وجود نتائج مع فلتر نشط
                      if (c.hasActiveFilter) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: c.clearAllFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_alt_off_rounded,
                                    color: AppColors.error, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'مسح الفلاتر',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              return Column(
                children: list.map((r) => _ReportRow(report: r, c: c)).toList(),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Date picker box ──────────────────────────────────────────
// widget مستقل لتجنب إشكالية الـ context بعد await
class _DateBox extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPick;

  const _DateBox({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReportsController>();
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(2026, 6, 1),
          firstDate: DateTime(2024, 1, 1),
          lastDate: DateTime(2028, 12, 31),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: WebTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? WebTheme.primary.withOpacity(0.5)
                : WebTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: value != null ? WebTheme.primary : AppColors.grey,
              size: 17,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value == null ? label : c.formatDate(value),
                style: TextStyle(
                  color: value == null ? AppColors.grey : WebTheme.text,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value != null)
              GestureDetector(
                // مسح هذا التاريخ فقط
                onTap: () => onPick == c.filterByDate as dynamic
                    ? null
                    : _clearThis(c, label),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.grey,
                  size: 15,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _clearThis(ReportsController c, String lbl) {
    // نحدد أيهما نمسح من خلال النص
    if (lbl == 'reports_date_from'.tr || lbl.contains('من')) {
      c.filterByDate(null, c.dateTo.value);
    } else {
      c.filterByDate(c.dateFrom.value, null);
    }
  }
}

// ── Report row ───────────────────────────────────────────────
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: WebTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description_outlined,
                color: WebTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: TextStyle(
                      color: WebTheme.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${report.boothName} • ${report.period} • ${report.createdAt}',
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  report.mainValue.toInt().toString(),
                  style: TextStyle(
                    color: WebTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  report.mainLabel,
                  style: TextStyle(color: AppColors.grey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${report.trend}%',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Obx(
              () => c.isDownloading.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: WebTheme.primary,
                      ),
                    )
                  : PopupMenuButton<String>(
                      icon: Icon(
                        Icons.download_rounded,
                        color: WebTheme.primary,
                      ),
                      tooltip: 'reports_download_btn'.tr,
                      color: WebTheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (fmt) =>
                          c.downloadReport(report.id, format: fmt),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'pdf',
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf_rounded,
                                  color: AppColors.error, size: 18),
                              const SizedBox(width: 10),
                              Text('reports_format_pdf'.tr,
                                  style: TextStyle(
                                      color: WebTheme.text, fontSize: 13)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'excel',
                          child: Row(
                            children: [
                              Icon(Icons.table_chart_rounded,
                                  color: AppColors.success, size: 18),
                              const SizedBox(width: 10),
                              Text('reports_format_excel'.tr,
                                  style: TextStyle(
                                      color: WebTheme.text, fontSize: 13)),
                            ],
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
