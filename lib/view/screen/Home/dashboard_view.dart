import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/dashboard_controller.dart';
import '../../../controller/Home/notifications_controller.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../widget/Home/bottom_nav_custom.dart';
import '../../widget/Home/stats_card.dart';
import '../../widget/Home/sponsor_event_card.dart';
import '../../widget/Home/exhibition_billboard.dart';
import '../../widget/Home/event_billboard.dart';
import '../../widget/Home/sponsorship_bottom_sheet.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifCtrl = Get.find<NotificationsController>();
    final eventsCtrl = Get.find<EventsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      bottomNavigationBar: const BottomNavCustom(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              await Future.delayed(const Duration(milliseconds: 800)),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                toolbarHeight: 56,
                backgroundColor: isDark
                    ? AppColors.darkBg
                    : AppColors.lightCard,
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Image.asset(
                          isDark
                              ? 'assets/images/logo1.png'
                              : 'assets/images/logo.png',
                          height: 38,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            padding: const EdgeInsets.only(right: 10),
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.lightPrimary,
                              size: 28,
                            ),
                            onPressed: () =>
                                Get.toNamed(AppRoutes.NOTIFICATIONS),
                          ),
                          Obx(
                            () => notifCtrl.unreadCount > 0
                                ? Positioned(
                                    right: 8,
                                    top: 4,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${notifCtrl.unreadCount}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => ExhibitionBillboard(
                        key: ValueKey(controller.featuredExhibitions.length),
                        exhibitions: controller.featuredExhibitions.toList(),
                        onTap: (e) => Get.toNamed(
                          AppRoutes.EXHIBITION_DETAIL,
                          arguments: e,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _performanceCard(context),
                    const SizedBox(height: 20),
                    _quickActions(context),
                    const SizedBox(height: 20),
                    Obx(
                      () => EventBillboard(
                        key: ValueKey(
                          eventsCtrl.exhibitionSponsorEvents.length,
                        ),
                        events: eventsCtrl.exhibitionSponsorEvents.toList(),
                        onTap: (ev) =>
                            _showSponsorSheet(context, ev, eventsCtrl),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Upcoming sponsor events from exhibitions investor participates in
                    _sectionHeader(
                      'فعاليات المعارض القادمة',

                      AppRoutes.EXHIBITION_EVENTS,
                      context,
                    ),
                    Obx(() {
                      final list = eventsCtrl.myExhibitionSponsorEvents;
                      if (list.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            'لا توجد فعاليات في معارضك المشترك بها',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: list
                            .take(3)
                            .map(
                              (ev) => SponsorEventCard(
                                event: ev,
                                onTap: () =>
                                    _showSponsorSheet(context, ev, eventsCtrl),
                                onFavorite: () =>
                                    eventsCtrl.toggleSponsorFavorite(ev),
                              ),
                            )
                            .toList(),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSponsorSheet(
    BuildContext context,
    ExhibitionSponsorEvent ev,
    EventsController ctrl,
  ) {
    ctrl.selectedSponsorDuration.value = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SponsorshipBottomSheet(event: ev),
    );
  }

  Widget _performanceCard(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: AppColors.favoriteGradient,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'ملخص الأداء',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.isDarkMode
                        ? Colors.white
                        : const Color(0xFF1D1A39),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Obx(
              () => DropdownButton<String>(
                value: controller.selectedPeriod.value,
                underline: const SizedBox(),
                menuWidth: 100,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkPrimary,
                ),
                items: controller.periods
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => controller.changePeriod(
                  v ?? controller.selectedPeriod.value,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: [
              StatsCard(
                label: 'إجمالي الحجوزات',
                value: '${controller.totalBookings}',
                icon: Icons.bookmark_outlined,
                iconColor: AppColors.darkPrimary,
                trend: 8.5,
              ),
              StatsCard(
                label: 'الأجنحة النشطة',
                value: '${controller.activeBooths}',
                icon: Icons.grid_view,
                iconColor: AppColors.darkSecondary,
                trend: 12.0,
              ),
              StatsCard(
                label: 'الفعاليات المنشورة',
                value: '${controller.publishedEvents}',
                icon: Icons.event,
                iconColor: AppColors.darkSecondary,
                trend: 22.1,
              ),
              StatsCard(
                label: 'إجمالي التفاعل',
                value: _fmt(controller.totalEngagement.value),
                icon: Icons.trending_up,
                iconColor: AppColors.orange,
                trend: 15.7,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  String _fmt(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : '$v';

  Widget _quickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.qr_code_scanner_rounded,
        'label': 'مسح QR',
        'route': AppRoutes.QR_SCANNER,
        'color': AppColors.darkAccent,
        'gradient': false,
      },
      {
        'icon': Icons.add_circle_outline,
        'label': 'نشر فعالية',
        'route': AppRoutes.CREATE_EVENT,
        'color': AppColors.darkSecondary,
        'gradient': false,
      },
      {
        'icon': Icons.event_note,
        'label': 'فعالياتي',
        'route': AppRoutes.EVENTS,
        'color': AppColors.darkPrimary,
        'gradient': false,
      },
      {
        'icon': Icons.campaign_outlined,
        'label': 'رعاياتي',
        'route': AppRoutes.MY_SPONSORSHIPS,
        'color': AppColors.orange,
        'gradient': false,
      },
      {
        'icon': Icons.bar_chart,
        'label': 'التقارير',
        'route': AppRoutes.REPORTS,
        'color': AppColors.info,
        'gradient': false,
      },
      {
        'icon': Icons.message,
        'label': 'التواصل',
        'route': AppRoutes.MESSAGES,
        'color': const Color.fromARGB(255, 192, 31, 255),
        'gradient': false,
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 22,
                decoration: BoxDecoration(
                  gradient: AppColors.favoriteGradient,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'الإجراءات السريعة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.isDarkMode
                      ? Colors.white
                      : const Color(0xFF1D1A39),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: actions.length,
            itemBuilder: (_, i) {
              final isGrad = actions[i]['gradient'] as bool;
              final color = actions[i]['color'] as Color;
              return GestureDetector(
                onTap: () => Get.toNamed(actions[i]['route'] as String),
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: isGrad ? AppColors.favoriteGradient : null,
                          color: isGrad ? null : color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isGrad
                              ? [
                                  BoxShadow(
                                    color: AppColors.darkPrimary.withOpacity(
                                      0.4,
                                    ),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          actions[i]['icon'] as IconData,
                          color: isGrad ? Colors.white : color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        actions[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isGrad
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isGrad ? AppColors.darkPink : null,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, String route, BuildContext context) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: AppColors.favoriteGradient,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.isDarkMode
                        ? Colors.white
                        : const Color(0xFF1D1A39),
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.toNamed(route),
              child: const Text(
                'عرض الكل',
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
