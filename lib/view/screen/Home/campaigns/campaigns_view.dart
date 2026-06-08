import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/campaigns_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/empty_widget.dart';

class CampaignsView extends GetView<CampaignsController> {
  const CampaignsView({super.key});

  Color _statusColor(String s) => s == 'active' ? AppColors.success : s == 'pending' ? AppColors.info : AppColors.grey;
  String _statusLabel(String s) => s == 'active' ? 'نشطة' : s == 'pending' ? 'معلقة' : 'منتهية';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(title: 'الحملات الإعلانية', showBack: false, actions: [
        TextButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.CREATE_CAMPAIGN),
          icon: const Icon(Icons.add, size: 18, color: AppColors.darkPrimary),
          label: const Text('حملة جديدة', style: TextStyle(color: AppColors.darkPrimary, fontSize: 13)),
        ),
      ]),
      body: Obx(() {
        if (controller.campaigns.isEmpty) return EmptyWidget(message: 'لا توجد حملات', buttonLabel: 'إنشاء حملة', onAction: () => Get.toNamed(AppRoutes.CREATE_CAMPAIGN));
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.campaigns.length,
          itemBuilder: (_, i) {
            final c = controller.campaigns[i];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.darkCardGradient : null,
                color: isDark ? null : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(gradient: AppColors.darkCTAGradient, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(c.type, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _statusColor(c.status).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text(_statusLabel(c.status), style: TextStyle(color: _statusColor(c.status), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _statChip(Icons.people_outline, '${(c.reach / 1000).toStringAsFixed(1)}K وصول', AppColors.darkPrimary),
                  const SizedBox(width: 8),
                  _statChip(Icons.monetization_on_outlined, '${c.budget.toInt()} ريال', AppColors.orange),
                  const SizedBox(width: 8),
                  _statChip(Icons.calendar_today_outlined, c.endDate, AppColors.grey),
                ]),
                const SizedBox(height: 10),
                _miniChart(c.weeklyTrend),
              ]),
            );
          },
        );
      }),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) => Row(children: [
    Icon(icon, size: 13, color: color),
    const SizedBox(width: 3),
    Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
  ]);

  Widget _miniChart(List<double> data) {
    final max = data.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((v) {
          final h = max > 0 ? (v / max * 28).clamp(2.0, 28.0) : 2.0;
          return Expanded(child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            height: h,
            decoration: BoxDecoration(
              gradient: AppColors.darkCTAGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ));
        }).toList(),
      ),
    );
  }
}
