import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/reports_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/utils/report_type_helper.dart';
import '../../../../data/model/report/report_model.dart';
import '../../../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../../widget/Home/custom_button.dart';

class ReportDetailView extends GetView<ReportsController> {
  const ReportDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final report  = Get.arguments as ReportModel? ?? DummyData.reports.first;
    final content = ReportTypeHelper.of(report);
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(report.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.darkPrimary),
            onPressed: () {},
          ),
          Obx(() => controller.isDownloading.value
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.darkPrimary)),
                )
              : IconButton(
                  icon: const Icon(Icons.download_outlined,
                      color: AppColors.darkPrimary),
                  onPressed: () => controller.downloadReport(report.id))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(isDark, report, content),
            const SizedBox(height: 16),
            _kpiRow(isDark, content),
            const SizedBox(height: 16),
            _chartSection(isDark, report, content),
            const SizedBox(height: 16),
            _dataTable(isDark, content),
            const SizedBox(height: 16),
            _insights(isDark, content),
            const SizedBox(height: 24),
            CustomButton(
              label: 'report_export_pdf'.tr,
              onTap: () => controller.exportToPdf(report),
            ),
            const SizedBox(height: 10),
            Obx(() => CustomButton(
                  label: 'report_download_excel'.tr,
                  isOutlined: true,
                  isLoading: controller.isDownloading.value,
                  onTap: () => controller.downloadReport(report.id, format: 'excel'),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _header(bool isDark, ReportModel r, ReportTypeContent c) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkCardGradient : null,
          color: isDark ? null : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(c.icon, size: 13, color: c.accentColor),
                  const SizedBox(width: 5),
                  Text(c.typeLabel,
                      style: TextStyle(
                          color: c.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
              const Spacer(),
              Text('${'report_created_prefix'.tr} ${r.createdAt}',
                  style: const TextStyle(fontSize: 11, color: AppColors.grey)),
            ]),
            const SizedBox(height: 10),
            Text(r.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('${r.boothName} • ${r.exhibitionName}',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.grey)),
            Text('${'report_period_prefix'.tr} ${r.period}',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.grey)),
          ],
        ),
      );

  // ── KPI Row ─────────────────────────────────────────────────
  Widget _kpiRow(bool isDark, ReportTypeContent c) => Row(
        children: c.kpis
            .map((kpi) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        left: c.kpis.indexOf(kpi) < c.kpis.length - 1 ? 8 : 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isDark ? AppColors.darkCardGradient : null,
                      color: isDark ? null : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(children: [
                      Text(kpi.value,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: kpi.color)),
                      const SizedBox(height: 3),
                      Text(kpi.label,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.grey),
                          textAlign: TextAlign.center),
                      if (kpi.trend.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(kpi.trend,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600)),
                      ],
                    ]),
                  ),
                ))
            .toList(),
      );

  // ── Chart ───────────────────────────────────────────────────
  Widget _chartSection(bool isDark, ReportModel r, ReportTypeContent c) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkCardGradient : null,
          color: isDark ? null : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(c.icon, size: 16, color: c.accentColor),
              const SizedBox(width: 6),
              Text(c.chartTitle,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _SparklinePainter(
                    data: r.sparklineData, color: c.accentColor),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      );

  // ── Data Table ───────────────────────────────────────────────
  Widget _dataTable(bool isDark, ReportTypeContent c) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkCardGradient : null,
          color: isDark ? null : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('report_detailed_data'.tr,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(
                  color: AppColors.darkSurface,
                  width: 0.5,
                  borderRadius: BorderRadius.circular(8)),
              children: [
                _tableRow(c.tableHeaders, isHeader: true),
                ...c.tableRows.map((row) => _tableRow(row)),
              ],
            ),
          ],
        ),
      );

  TableRow _tableRow(List<String> cells, {bool isHeader = false}) => TableRow(
        decoration: isHeader
            ? BoxDecoration(
                color: AppColors.darkPrimary.withOpacity(0.15))
            : null,
        children: cells
            .map((cell) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 8),
                  child: Text(cell,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: isHeader
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isHeader
                              ? AppColors.darkPrimary
                              : null),
                      textAlign: TextAlign.center),
                ))
            .toList(),
      );

  // ── Insights ─────────────────────────────────────────────────
  Widget _insights(bool isDark, ReportTypeContent c) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkCardGradient : null,
          color: isDark ? null : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.lightbulb_outline, color: AppColors.darkSecondary),
              const SizedBox(width: 6),
              Text('report_insights_title'.tr,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            ...c.insights.map((text) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_left,
                          color: AppColors.darkPrimary, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(text,
                              style: const TextStyle(
                                  fontSize: 13, height: 1.5))),
                    ],
                  ),
                )),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════════
//  Sparkline Painter
// ════════════════════════════════════════════════════════════
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range  = (maxVal - minVal) == 0 ? 1.0 : maxVal - minVal;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.25), color.withOpacity(0.02)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = AppColors.grey.withOpacity(0.15)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height * (1 - (data[i] - minVal) / range);
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 =
          Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      path.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color;
}
