import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/reports_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../data/model/report/report_model.dart';
import '../../../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../../widget/Home/custom_button.dart';

class ReportDetailView extends GetView<ReportsController> {
  const ReportDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final report = Get.arguments as ReportModel? ?? DummyData.reports.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Get.back()),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: AppColors.darkPrimary), onPressed: () {}),
          Obx(() => controller.isDownloading.value
              ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkPrimary)))
              : IconButton(icon: const Icon(Icons.download_outlined, color: AppColors.darkPrimary), onPressed: () => controller.downloadReport(report.id))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header(context, isDark, report),
          const SizedBox(height: 16),
          _kpiRow(context, isDark, report),
          const SizedBox(height: 16),
          _chartSection(context, isDark, report),
          const SizedBox(height: 16),
          _dataTable(context, isDark),
          const SizedBox(height: 16),
          _insights(context, isDark),
          const SizedBox(height: 24),
          CustomButton(label: 'تنزيل PDF', onTap: () => controller.downloadReport(report.id, format: 'pdf'), isLoading: controller.isDownloading.value),
          const SizedBox(height: 10),
          CustomButton(label: 'تنزيل Excel', isOutlined: true, onTap: () => controller.downloadReport(report.id, format: 'excel')),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _header(BuildContext context, bool isDark, ReportModel r) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(gradient: isDark ? AppColors.darkCardGradient : null, color: isDark ? null : AppColors.lightCard, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.darkPrimary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Text(_typeLabel(r.type), style: const TextStyle(color: AppColors.darkPrimary, fontSize: 11, fontWeight: FontWeight.w600))),
        const Spacer(),
        Text('أُنشئ: ${r.createdAt}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
      ]),
      const SizedBox(height: 10),
      Text(r.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text('${r.boothName} • ${r.exhibitionName}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
      Text('الفترة: ${r.period}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
    ]),
  );

  String _typeLabel(String t) {
    switch (t) {
      case 'visitors': return 'الزوار'; case 'performance': return 'الأداء';
      case 'events': return 'الفعاليات'; case 'campaigns': return 'الحملات';
      case 'monthly': return 'شهري'; default: return 'تحليل';
    }
  }

  Widget _kpiRow(BuildContext context, bool isDark, ReportModel r) => Row(children: [
    _kpi(context, isDark, r.mainValue.toInt().toString(), r.mainLabel, AppColors.darkPrimary, '+${r.trend}%'),
    const SizedBox(width: 10),
    _kpi(context, isDark, '78%', 'معدل التفاعل', AppColors.success, '+5.2%'),
    const SizedBox(width: 10),
    _kpi(context, isDark, '4.2', 'متوسط وقت الزيارة (د)', AppColors.orange, '+0.8'),
  ]);

  Widget _kpi(BuildContext context, bool isDark, String val, String label, Color color, String trend) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(gradient: isDark ? AppColors.darkCardGradient : null, color: isDark ? null : AppColors.lightCard, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 9, color: AppColors.grey), textAlign: TextAlign.center),
      const SizedBox(height: 4),
      Text(trend, style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
    ]),
  ));

  Widget _chartSection(BuildContext context, bool isDark, ReportModel r) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(gradient: isDark ? AppColors.darkCardGradient : null, color: isDark ? null : AppColors.lightCard, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('مخطط الأداء', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      SizedBox(
        height: 180,
        child: CustomPaint(
          painter: _SparklinePainter(data: r.sparklineData, color: AppColors.darkPrimary),
          child: const SizedBox.expand(),
        ),
      ),
    ]),
  );

  Widget _dataTable(BuildContext context, bool isDark) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(gradient: isDark ? AppColors.darkCardGradient : null, color: isDark ? null : AppColors.lightCard, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('البيانات التفصيلية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Table(
        border: TableBorder.all(color: AppColors.darkSurface, width: 0.5, borderRadius: BorderRadius.circular(8)),
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1.5)},
        children: [
          _tableRow(['التاريخ', 'الزوار', 'التفاعل'], isHeader: true),
          _tableRow(['2026-07-15', '420', '78%']),
          _tableRow(['2026-07-16', '380', '72%']),
          _tableRow(['2026-07-17', '450', '82%']),
          _tableRow(['2026-07-18', '520', '88%']),
          _tableRow(['2026-07-19', '680', '91%']),
        ],
      ),
    ]),
  );

  TableRow _tableRow(List<String> cells, {bool isHeader = false}) => TableRow(
    decoration: isHeader ? BoxDecoration(color: AppColors.darkPrimary.withOpacity(0.15)) : null,
    children: cells.map((c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: Text(c, style: TextStyle(fontSize: 12, fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400, color: isHeader ? AppColors.darkPrimary : null), textAlign: TextAlign.center))).toList(),
  );

  Widget _insights(BuildContext context, bool isDark) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(gradient: isDark ? AppColors.darkCardGradient : null, color: isDark ? null : AppColors.lightCard, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(Icons.lightbulb_outline, color: AppColors.darkSecondary), const SizedBox(width: 6), const Text('رؤى وتوصيات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 10),
      ...['أداء الجناح تجاوز المتوسط بنسبة 23% مقارنة بالمعارض السابقة', 'ذروة الزوار تتركز بين 2-5 مساءً — خطط فعالياتك في هذا الوقت', 'معدل التحويل من الزيارة للتواصل 18% — أعلى من المتوسط العام 12%'].map((r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.arrow_left, color: AppColors.darkPrimary, size: 18),
          const SizedBox(width: 4),
          Expanded(child: Text(r, style: const TextStyle(fontSize: 13, height: 1.5))),
        ]),
      )),
    ]),
  );
}
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : maxVal - minVal;

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
      final cp1 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.data != data || old.color != color;
}