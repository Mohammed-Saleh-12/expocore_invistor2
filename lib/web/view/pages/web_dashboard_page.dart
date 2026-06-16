import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/dashboard_controller.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../controllers/web_nav_controller.dart';
import '../widgets/web_exhibition_card.dart';
import '../widgets/web_billboard.dart';
import '../widgets/web_event_billboard.dart';
import '../widgets/web_section_header.dart';

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

                // ── Quick actions ─────────────────────────
                _sectionTitle('الإجراءات السريعة'),
                const SizedBox(height: 16),
                _quickActions(),
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
                          onAll: () => WebNavController.to.select(4),
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
                  onAll: () => WebNavController.to.select(4),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final list = events.myExhibitionSponsorEvents;
                  if (list.isEmpty)
                    return _emptyHint('لا توجد فعاليات في معارضك المشترك بها');
                  return Column(
                    children: list
                        .take(4)
                        .map((e) => _SponsorEventTile(event: e))
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
                  color: AppColors.darkPrimary,
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
            AppColors.darkPrimary,
            '+8.5%',
          ),
          _StatData(
            'الأجنحة النشطة',
            '${c.activeBooths.value}',
            Icons.grid_view_rounded,
            AppColors.darkSecondary,
            '+12%',
          ),
          _StatData(
            'الفعاليات المنشورة',
            '${c.publishedEvents.value}',
            Icons.event_rounded,
            AppColors.darkAccent,
            '+22%',
          ),
          _StatData(
            'إجمالي التفاعل',
            c.formatEngagement(c.totalEngagement.value),
            Icons.trending_up_rounded,
            AppColors.darkPink,
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

  // ── Quick actions ──────────────────────────────────────────
  Widget _quickActions() {
    final actions = [
      (
        _QA(
          Icons.qr_code_scanner_rounded,
          'مسح QR',
          AppColors.darkAccent,
          gradient: false,
        ),
        WebNavController.to.openScanner,
      ),
      (
        _QA(Icons.add_circle_outline, 'نشر فعالية', AppColors.darkSecondary),
        WebNavController.to.openCreateEvent,
      ),
      (
        _QA(Icons.event_note, 'فعالياتي', AppColors.darkPrimary),
        () => WebNavController.to.select(3),
      ),
      (
        _QA(Icons.workspace_premium_outlined, 'رعاياتي', AppColors.orange),
        () => WebNavController.to.select(4),
      ),
      (
        _QA(Icons.bar_chart, 'التقارير', AppColors.info),
        () => WebNavController.to.select(5),
      ),
      (
        _QA(Icons.message, 'التواصل', const Color.fromARGB(255, 192, 31, 255)),
        () => WebNavController.to.select(6),
      ),
    ];
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: actions
          .map((a) => _QuickActionBtn(qa: a.$1, onTap: a.$2))
          .toList(),
    );
  }

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
      Text(
        t,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: WebTheme.text,
        ),
      ),
    ],
  );

  Widget _sectionTitleWithAction(String t, {required VoidCallback onAll}) =>
      Row(
        children: [
          Expanded(child: _sectionTitle(t)),
          GestureDetector(
            onTap: onAll,
            child: Text(
              'عرض الكل',
              style: TextStyle(
                color: AppColors.darkPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
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

// ── Quick action model + button ──────────────────────────────
class _QA {
  final IconData icon;
  final String label;
  final Color color;
  final bool gradient;
  _QA(this.icon, this.label, this.color, {this.gradient = false});
}

class _QuickActionBtn extends StatelessWidget {
  final _QA qa;
  final VoidCallback onTap;
  const _QuickActionBtn({required this.qa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: WebTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WebTheme.border),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: qa.gradient ? AppColors.favoriteGradient : null,
                color: qa.gradient ? null : qa.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                qa.icon,
                color: qa.gradient ? WebTheme.text : qa.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              qa.label,
              style: TextStyle(
                color: WebTheme.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sponsor event tile ────────────────────────────────────────
class _SponsorEventTile extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  const _SponsorEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => WebNavController.to.openSponsorEvent(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
                gradient: AppColors.favoriteGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.campaign_rounded,
                color: WebTheme.text,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: TextStyle(
                      color: WebTheme.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.exhibitionName} • ${event.date} • ${event.place}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.darkPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event.type,
                style: TextStyle(color: AppColors.darkPink, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    return Container(
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
    );
  }
}
