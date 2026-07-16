import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/favorites_controller.dart';
import '../../../controller/Home/booth_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/booth/booth_model.dart';
import '../widgets/web_section_header.dart';
import '../widgets/web_exhibition_card.dart';
import '../widgets/web_sponsor_event_card.dart';
import '../widgets/web_status_chip.dart';
import '../../controllers/web_nav_controller.dart';

class WebFavoritesPage extends StatelessWidget {
  const WebFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FavoritesController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fixed header + filter bar ──────────────────────
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

              // ── Category filter pills ──
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: FavoritesController.webFilters.map((f) {
                    final active = c.webCategoryFilter.value == f;
                    return GestureDetector(
                      onTap: () => c.setWebFilter(f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              active ? AppColors.favoriteGradient : null,
                          color: active ? null : WebTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            color:
                                active ? Colors.white : AppColors.grey,
                            fontSize: 13,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── Scrollable content ─────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Obx(() {
              final filter      = c.webCategoryFilter.value;
              final exhibitions = c.favoriteExhibitions.toList();
              final events      = c.favoriteEvents.toList();
              final booths      = c.favoriteBooths.toList();

              final showExhibitions = filter == 'معارض';
              final showEvents      = filter == 'فعاليات';
              final showBooths      = filter == 'أجنحة';

              final visibleExhibitions =
                  showExhibitions ? exhibitions : <dynamic>[];
              final visibleEvents =
                  showEvents ? events : <dynamic>[];
              final visibleBooths =
                  showBooths ? booths : <dynamic>[];

              final isEmpty = visibleExhibitions.isEmpty &&
                  visibleEvents.isEmpty &&
                  visibleBooths.isEmpty;

              if (isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(60),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 56,
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد عناصر في هذه الفئة',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Exhibitions ────────────────────────────
                  if (showExhibitions && exhibitions.isNotEmpty) ...[
                    _subTitle('المعارض', exhibitions.length),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: exhibitions
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
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Events ─────────────────────────────────
                  if (showEvents && events.isNotEmpty) ...[
                    _subTitle('الفعاليات', events.length),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: events
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
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Booths ─────────────────────────────────
                  if (showBooths && booths.isNotEmpty) ...[
                    _subTitle('الأجنحة', booths.length),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, cons) {
                        final cols = cons.maxWidth > 1100
                            ? 3
                            : (cons.maxWidth > 700 ? 2 : 1);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: booths.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.05,
                          ),
                          itemBuilder: (_, i) => _FavBoothCard(
                            booth: booths[i],
                            onRemove: () => c.removeBooth(booths[i]),
                            boothCtrl: Get.find<BoothController>(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _subTitle(String t, int count) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Text(
          t,
          style: TextStyle(
            color: WebTheme.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: WebTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: WebTheme.pink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Favourite booth card (matches _BoothCard style + remove button) ──────────
class _FavBoothCard extends StatelessWidget {
  final BoothModel booth;
  final VoidCallback onRemove;
  final BoothController boothCtrl;

  const _FavBoothCard({
    required this.booth,
    required this.onRemove,
    required this.boothCtrl,
  });

  bool get _approved => booth.status == 'active';
  bool get _ended    => booth.status == 'ended';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WebTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: WebTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: WebTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جناح ${booth.number}',
                      style: TextStyle(
                        color: WebTheme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      booth.exhibitionName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              WebStatusChip(status: booth.status),
            ],
          ),
          const Spacer(),

          // ── Info row ────────────────────────────────────
          Row(
            children: [
              _info(Icons.straighten_rounded, '${booth.area.toInt()} م²'),
              const SizedBox(width: 16),
              _info(Icons.payments_outlined, '${booth.price.toInt()} ر.س'),
            ],
          ),
          const SizedBox(height: 10),

          // ── Status-based action buttons (same as أجنحتي) ──
          Row(
            children: [
              Expanded(
                child: _btn(
                  label: _approved ? 'إدارة' : 'تفاصيل',
                  filled: true,
                  onTap: () => _approved
                      ? WebNavController.to.openBoothManagement(booth)
                      : WebNavController.to.openBooth(
                          booth,
                          report: boothCtrl.buildBoothReport(booth),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: (_approved || _ended)
                    ? _btn(
                        label: 'التقرير',
                        filled: false,
                        onTap: () => WebNavController.to.openReport(
                          boothCtrl.buildBoothReport(booth),
                        ),
                      )
                    : _btn(
                        label: 'خريطة 3D',
                        filled: false,
                        onTap: () => WebNavController.to.openMap(),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Remove from favourites ───────────────────────
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.error.withOpacity(0.45)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: AppColors.error, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    'إزالة من المفضلة',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: AppColors.grey),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: AppColors.grey, fontSize: 12)),
    ],
  );

  Widget _btn({
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: filled ? AppColors.favoriteGradient : null,
            border: filled
                ? null
                : Border.all(color: WebTheme.primary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : WebTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
