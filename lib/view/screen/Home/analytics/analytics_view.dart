import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../controller/Home/analytics_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';
import '../../../widget/Home/stats_card.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'analytics_title'.tr, showBack: false, actions: [
        Obx(() => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: DropdownButton<String>(
            value: controller.selectedPeriod.value,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            style: const TextStyle(fontSize: 12, color: AppColors.darkPrimary),
            items: controller.periods.map((p) => DropdownMenuItem(value: p, child: Text(p.tr))).toList(),
            onChanged: (v) => controller.changePeriod(v ?? ''),
          ),
        )),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 120,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              SizedBox(width: 160, child: StatsCard(label: 'analytics_total_visits'.tr, value: _fmt(controller.totalVisits.value), icon: Icons.people_outline, iconColor: AppColors.darkPrimary, trend: controller.visitsTrend.value)),
              const SizedBox(width: 10),
              SizedBox(width: 160, child: StatsCard(label: 'analytics_product_views'.tr, value: _fmt(controller.productViews.value), icon: Icons.visibility_outlined, iconColor: AppColors.darkSecondary, trend: controller.viewsTrend.value)),
              const SizedBox(width: 10),
              SizedBox(width: 160, child: StatsCard(label: 'analytics_participants'.tr, value: '${controller.eventParticipants}', icon: Icons.event_outlined, iconColor: AppColors.success, trend: controller.eventsTrend.value)),
              const SizedBox(width: 10),
              SizedBox(width: 160, child: StatsCard(label: 'analytics_total_engagement'.tr, value: _fmt(controller.totalEngagement.value), icon: Icons.trending_up, iconColor: AppColors.orange, trend: controller.engagementTrend.value)),
            ]),
          ),
          const SizedBox(height: 24),
          _chartCard(context, 'analytics_visitors_chart'.tr, _visitorsChart()),
          const SizedBox(height: 16),
          _chartCard(context, 'analytics_events_chart'.tr, _eventsChart()),
          const SizedBox(height: 16),
          _demographicsCard(context),
          const SizedBox(height: 16),
          _recommendationsCard(context),
          const SizedBox(height: 24),
          CustomButton(label: 'analytics_download_report'.tr, onTap: controller.goToReports),
          const SizedBox(height: 20),
        ])),
      ),
    );
  }

  String _fmt(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : '$v';

  Widget _chartCard(BuildContext context, String title, Widget chart) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        SizedBox(height: 180, child: chart),
      ]),
    );
  }

  Widget _visitorsChart() => Obx(() => LineChart(
    LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final days = ['أح'.tr, 'إث'.tr, 'ث'.tr, 'أر'.tr, 'خ'.tr, 'ج'.tr, 'س'.tr];
          if (v.toInt() < days.length) return Text(days[v.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.grey));
          return const SizedBox();
        }, reservedSize: 20)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: controller.visitorsData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          isCurved: true,
          gradient: AppColors.darkCTAGradient,
          barWidth: 3,
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(
            colors: [AppColors.darkPrimary.withOpacity(0.3), AppColors.darkAccent.withOpacity(0.05)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          )),
          dotData: const FlDotData(show: false),
        ),
      ],
    ),
  ));

  Widget _eventsChart() => BarChart(
    BarChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final labels = ['ورشة'.tr, 'عرض'.tr, 'B2B', 'مسابقة'.tr];
          if (v.toInt() < labels.length) return Text(labels[v.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.grey));
          return const SizedBox();
        }, reservedSize: 20)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: [38, 72, 15, 185].asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(toY: e.value.toDouble(), gradient: AppColors.darkCTAGradient, width: 20, borderRadius: BorderRadius.circular(6)),
      ])).toList(),
    ),
  );

  Widget _demographicsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [('18-24', 0.22), ('25-34', 0.45), ('35-44', 0.23), ('45+', 0.10)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('analytics_age_distribution'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        ...items.map((d) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 40, child: Text(d.$1, style: const TextStyle(fontSize: 12, color: AppColors.grey))),
            const SizedBox(width: 8),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: d.$2, backgroundColor: AppColors.darkSurface, valueColor: const AlwaysStoppedAnimation(AppColors.darkPrimary), minHeight: 8),
            )),
            const SizedBox(width: 8),
            Text('${(d.$2 * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          ]),
        )),
      ]),
    );
  }

  Widget _recommendationsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recs = ['أفضل وقت للفعاليات: بين 2-5 مساءً لأعلى حضور', 'استخدم الإعلانات على شاشات المعرض لزيادة الوصول 40%', 'نسبة تفاعل الزوار من فئة 25-34 الأعلى — استهدفهم'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.lightbulb_outline, color: AppColors.darkSecondary, size: 20), const SizedBox(width: 6), Text('analytics_smart_recs'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 12),
        ...recs.map((r) => Padding(
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
}
