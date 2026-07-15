import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/favorites_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_nav_controller.dart';
import '../widgets/web_section_header.dart';
import '../widgets/web_exhibition_card.dart';
import '../widgets/web_sponsor_event_card.dart';
import '../widgets/web_booth_card.dart';

// ════════════════════════════════════════════════════════════
//  WebFavoritesPage
// ════════════════════════════════════════════════════════════
class WebFavoritesPage extends StatelessWidget {
  const WebFavoritesPage({super.key});

  static const _tabs = ['معارض', 'فعاليات', 'أجنحة'];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FavoritesController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fixed header + filter bar ─────────────────────
        Container(
          color: WebTheme.bg,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WebSectionHeader(
                title: 'المفضلة',
                subtitle: 'المعارض والفعاليات والأجنحة المحفوظة',
              ),
              const SizedBox(height: 20),

              // ── Filter tabs ────────────────────────────
              Obx(() => Wrap(
                spacing: 8,
                children: List.generate(_tabs.length, (i) {
                  final active = c.selectedTab.value == i;
                  return GestureDetector(
                    onTap: () => c.setTab(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: active ? AppColors.favoriteGradient : null,
                        color: active ? null : WebTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          color: active ? Colors.white : AppColors.grey,
                          fontSize: 13,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              )),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── Scrollable content ────────────────────────────
        Expanded(
          child: Obx(() {
            final tab = c.selectedTab.value;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: tab == 0
                  ? _ExhibitionsTab(c: c)
                  : tab == 1
                  ? _EventsTab(c: c)
                  : _BoothsTab(c: c),
            );
          }),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Tab: المعارض
// ════════════════════════════════════════════════════════════
class _ExhibitionsTab extends StatelessWidget {
  final FavoritesController c;
  const _ExhibitionsTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = c.favoriteExhibitions.toList();
      if (list.isEmpty) return _empty('لا توجد معارض في المفضلة', Icons.business_outlined);
      return Wrap(
        spacing: 20,
        runSpacing: 20,
        children: list
            .map(
              (e) => SizedBox(
                width: 300,
                child: WebExhibitionCard(
                  exhibition: e,
                  onFavorite: () => c.removeExhibition(e),
                ),
              ),
            )
            .toList(),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════
//  Tab: الفعاليات
// ════════════════════════════════════════════════════════════
class _EventsTab extends StatelessWidget {
  final FavoritesController c;
  const _EventsTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = c.favoriteEvents.toList();
      if (list.isEmpty) return _empty('لا توجد فعاليات في المفضلة', Icons.event_outlined);
      return Wrap(
        spacing: 20,
        runSpacing: 20,
        children: list
            .map(
              (ev) => SizedBox(
                width: 320,
                child: WebSponsorEventCard(
                  event: ev,
                  onFavorite: () => c.removeEvent(ev),
                ),
              ),
            )
            .toList(),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════
//  Tab: الأجنحة
// ════════════════════════════════════════════════════════════
class _BoothsTab extends StatelessWidget {
  final FavoritesController c;
  const _BoothsTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = c.favoriteBooths.toList();
      if (list.isEmpty) return _empty('لا توجد أجنحة في المفضلة', Icons.storefront_outlined);
      return LayoutBuilder(
        builder: (context, cons) {
          final cols = cons.maxWidth > 1100 ? 3 : (cons.maxWidth > 700 ? 2 : 1);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (_, i) {
              final b = list[i];
              return WebBoothCard(
                booth: b,
                primaryLabel: 'تفاصيل',
                onPrimary: () => WebNavController.to.openBooth(b),
                secondaryLabel: 'إزالة',
                onSecondary: () => c.removeBooth(b),
              );
            },
          );
        },
      );
    });
  }
}

// ── Shared empty state ────────────────────────────────────────
Widget _empty(String message, IconData icon) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(60),
  alignment: Alignment.center,
  child: Column(
    children: [
      Icon(icon, size: 56, color: AppColors.grey.withOpacity(0.5)),
      const SizedBox(height: 12),
      Text(message, style: TextStyle(color: AppColors.grey)),
    ],
  ),
);
