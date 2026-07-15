import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/dashboard_controller.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_nav_controller.dart';
import '../widgets/web_exhibition_card.dart';
import '../widgets/web_billboard.dart';
import '../widgets/web_event_billboard.dart';
import '../widgets/web_sponsor_event_card.dart';

class WebDashboardPage extends StatelessWidget {
  const WebDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    final events = Get.find<EventsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Scrollable content ────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Exhibitions billboard ─────────────────
                Obx(() {
                  final ads = c.featuredExhibitions.toList();
                  if (ads.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('المعارض المميّزة'),
                        const SizedBox(height: 14),
                        WebBillboard(items: ads),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 28),

                // ── Performance summary (+ period) ────────
                _performanceSection(c),
                const SizedBox(height: 32),

                // ── Latest exhibitions ────────────────────
                _sectionTitleWithAction(
                  'أحدث المعارض',
                  onAll: () => WebNavController.to.select(1),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final list = c.featuredExhibitions.toList();
                  if (list.isEmpty) return _emptyHint('لا توجد معارض حالياً');
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: list
                        .map(
                          (e) => SizedBox(
                            width: 280,
                            child: WebExhibitionCard(exhibition: e),
                          ),
                        )
                        .toList(),
                  );
                }),
                const SizedBox(height: 32),
                // ── Events billboard ──────────────────────
                Obx(() {
                  final evs = events.exhibitionSponsorEvents.toList();
                  if (evs.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 28, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitleWithAction(
                          'فعاليات المعارض الإعلانية',
                          onAll: () => WebNavController.to.openExhibitionEvents(),
                        ),
                        const SizedBox(height: 14),
                        WebEventBillboard(events: evs),
                      ],
                    ),
                  );
                }),
                // ── Upcoming sponsor events ───────────────
                _sectionTitleWithAction(
                  'فعاليات المعارض القادمة',
                  onAll: () => WebNavController.to.openExhibitionEvents(),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final list = events.myExhibitionSponsorEvents;
                  if (list.isEmpty)
                    return _emptyHint('لا توجد فعاليات في معارضك المشترك بها');
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: list
                        .take(4)
                        .map(
                          (e) => SizedBox(
                            width: 280,
                            child: WebSponsorEventCard(event: e),
                          ),
                        )
                        .toList(),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Performance section ────────────────────────────────────
  Widget _performanceSection(DashboardController c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(child: _sectionTitle('ملخص الأداء')),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: WebTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WebTheme.border),
              ),
              child: DropdownButton<String>(
                value: c.selectedPeriod.value,
                underline: const SizedBox(),
                dropdownColor: WebTheme.surfaceAlt,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: WebTheme.primary,
                  size: 20,
                ),
                style: TextStyle(color: WebTheme.text, fontSize: 13),
                items: c.periods
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => c.changePeriod(v ?? c.selectedPeriod.value),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Obx(() {
        final cards = [
          _StatData(
            'إجمالي الحجوزات',
            '${c.totalBookings.value}',
            Icons.bookmark_rounded,
            WebTheme.primary,
            '+8.5%',
          ),
          _StatData(
            'الأجنحة النشطة',
            '${c.activeBooths.value}',
            Icons.grid_view_rounded,
            WebTheme.secondary,
            '+12%',
          ),
          _StatData(
            'الفعاليات المنشورة',
            '${c.publishedEvents.value}',
            Icons.event_rounded,
            WebTheme.accent,
            '+22%',
          ),
          _StatData(
            'إجمالي التفاعل',
            c.formatEngagement(c.totalEngagement.value),
            Icons.trending_up_rounded,
            WebTheme.pink,
            '+15.7%',
          ),
        ];
        return LayoutBuilder(
          builder: (context, cons) {
            final cols = cons.maxWidth > 1100
                ? 4
                : (cons.maxWidth > 700 ? 2 : 1);
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: 2.4,
              children: cards.map((d) => _StatCard(data: d)).toList(),
            );
          },
        );
      }),
    ],
  );

  // ── Section titles ─────────────────────────────────────────
  Widget _sectionTitle(String t) => Row(
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
      Obx(() => Text(
        t,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: WebTheme.text,
        ),
      )),
    ],
  );

  Widget _sectionTitleWithAction(String t, {required VoidCallback onAll}) =>
      Row(
        children: [
          Expanded(child: _sectionTitle(t)),
          GestureDetector(
            onTap: onAll,
            child: Obx(() => Text(
              'عرض الكل',
              style: TextStyle(
                color: WebTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            )),
          ),
        ],
      );

  Widget _emptyHint(String t) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(36),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: WebTheme.surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(t, style: TextStyle(color: AppColors.grey)),
  );
}

// ── Stat data + card ──────────────────────────────────────────
class _StatData {
  final String label, value, trend;
  final IconData icon;
  final Color color;
  _StatData(this.label, this.value, this.icon, this.color, this.trend);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WebTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.value,
                  style: TextStyle(
                    color: WebTheme.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              data.trend,
              style: TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
