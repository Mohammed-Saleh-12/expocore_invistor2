import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/dashboard_controller.dart';
import '../../../controller/Home/notifications_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../widget/Home/bottom_nav_custom.dart';
import '../../widget/Home/stats_card.dart';
import '../../widget/Home/exhibition_card.dart';
import '../../widget/Home/event_card.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifCtrl = Get.find<NotificationsController>();
    return Scaffold(
      bottomNavigationBar: const BottomNavCustom(),
      body: SafeArea(
        child: Obx(() => RefreshIndicator(
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 800)),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBg : AppColors.lightBg,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(children: [
                  Obx(() => CircleAvatar(
                    backgroundColor: AppColors.darkPrimary,
                    radius: 20,
                    child: Text(controller.companyName.value.isNotEmpty ? controller.companyName.value[0] : 'ش',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('مرحباً،', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                    Obx(() => Text(controller.companyName.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                  ])),
                  Obx(() => Stack(children: [
                    IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Get.toNamed(AppRoutes.NOTIFICATIONS)),
                    if (notifCtrl.unreadCount > 0)
                      Positioned(right: 8, top: 8, child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: AppColors.darkSecondary, shape: BoxShape.circle),
                        child: Center(child: Text('${notifCtrl.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 9))),
                      )),
                  ])),
                ]),
              ),
              SliverToBoxAdapter(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _performanceCard(context),
                  const SizedBox(height: 20),
                  _quickActions(context),
                  const SizedBox(height: 20),
                  _sectionHeader('أحدث المعارض', AppRoutes.EXHIBITIONS),
                  ...controller.latestExhibitions.map((e) => ExhibitionCard(
                    exhibition: e,
                    onTap: () => Get.toNamed(AppRoutes.EXHIBITION_DETAIL, arguments: e),
                    onFavorite: () {},
                  )),
                  const SizedBox(height: 20),
                  _sectionHeader('الفعاليات القادمة', AppRoutes.EVENTS),
                  ...controller.upcomingEvents.map((e) => EventCard(event: e, onTap: () => Get.toNamed(AppRoutes.EVENTS), showFavorite: true, onFavorite: () {})),
                  const SizedBox(height: 20),
                ],
              )),
            ],
          ),
        )),
      ),
    );
  }

  Widget _performanceCard(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('ملخص الأداء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const Spacer(),
        Obx(() => DropdownButton<String>(
          value: controller.selectedPeriod.value,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: const TextStyle(fontSize: 12, color: AppColors.darkPrimary),
          items: controller.periods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) => controller.changePeriod(v ?? controller.selectedPeriod.value),
        )),
      ]),
      const SizedBox(height: 12),
      Obx(() => GridView.count(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.4,
        children: [
          StatsCard(label: 'إجمالي الحجوزات', value: '${controller.totalBookings}', icon: Icons.bookmark_outlined, iconColor: AppColors.darkPrimary, trend: 8.5),
          StatsCard(label: 'الأجنحة النشطة', value: '${controller.activeBooths}', icon: Icons.grid_view, iconColor: AppColors.success, trend: 12.0),
          StatsCard(label: 'الفعاليات المنشورة', value: '${controller.publishedEvents}', icon: Icons.event, iconColor: AppColors.darkSecondary, trend: 22.1),
          StatsCard(label: 'إجمالي التفاعل', value: _fmt(controller.totalEngagement.value), icon: Icons.trending_up, iconColor: AppColors.orange, trend: 15.7),
        ],
      )),
    ]),
  );

  String _fmt(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : '$v';

  Widget _quickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.store, 'label': 'تصفح معارض', 'route': AppRoutes.EXHIBITIONS, 'color': AppColors.darkPrimary},
      {'icon': Icons.grid_view, 'label': 'حجز جناح', 'route': AppRoutes.BOOTHS, 'color': AppColors.darkSecondary},
      {'icon': Icons.favorite, 'label': 'مفضلاتي', 'route': AppRoutes.FAVORITES, 'color': AppColors.darkAccent},
      {'icon': Icons.event, 'label': 'إنشاء فعالية', 'route': AppRoutes.CREATE_EVENT, 'color': AppColors.success},
      {'icon': Icons.bar_chart, 'label': 'التقارير', 'route': AppRoutes.REPORTS, 'color': AppColors.info},
      {'icon': Icons.message, 'label': 'التواصل', 'route': AppRoutes.MESSAGES, 'color': AppColors.orange},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('الإجراءات السريعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
      const SizedBox(height: 12),
      SizedBox(
        height: 88,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: actions.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => Get.toNamed(actions[i]['route'] as String),
            child: Container(
              width: 72, margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: (actions[i]['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(actions[i]['icon'] as IconData, color: actions[i]['color'] as Color, size: 24),
                ),
                const SizedBox(height: 6),
                Text(actions[i]['label'] as String, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center, maxLines: 2),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _sectionHeader(String title, String route) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const Spacer(),
      GestureDetector(
        onTap: () => Get.toNamed(route),
        child: const Text('عرض الكل', style: TextStyle(fontSize: 12, color: AppColors.darkPrimary, fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}
