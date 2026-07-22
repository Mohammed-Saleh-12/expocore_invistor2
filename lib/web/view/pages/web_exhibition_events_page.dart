import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../../view/widget/Home/sponsorship_bottom_sheet.dart';
import '../widgets/web_section_header.dart';

class WebExhibitionEventsPage extends StatelessWidget {
  const WebExhibitionEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EventsController>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Filters sidebar ──────────────────────────────
          SizedBox(width: 240, child: _FiltersPanel(c: c)),
          const SizedBox(width: 24),

          // ── Main content ─────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WebSectionHeader(
                  title: 'فعاليات المعارض الإعلانية',
                  subtitle: 'تصفح فعاليات المعارض المتاحة للرعاية',
                ),
                const SizedBox(height: 20),

                // ── Search ───────────────────────────────────
                TextField(
                  controller: c.sponsorSearchCtrl,
                  onChanged: c.onSponsorSearch,
                  style: TextStyle(color: WebTheme.text),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن فعالية أو معرض...',
                    hintStyle: TextStyle(
                      color: AppColors.grey.withOpacity(0.6),
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColors.grey),
                    filled: true,
                    fillColor: WebTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ── Grid ─────────────────────────────────────
                Expanded(
                  child: Obx(() {
                    final list = c.filteredSponsorEvents;
                    if (c.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: WebTheme.primary,
                        ),
                      );
                    }
                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.campaign_outlined,
                              size: 56,
                              color: AppColors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد فعاليات مطابقة',
                              style: TextStyle(color: AppColors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    return LayoutBuilder(
                      builder: (_, constraints) {
                        const spacing = 20.0;
                        final cols = (constraints.maxWidth / (280 + spacing))
                            .floor()
                            .clamp(1, 3);
                        final cardWidth =
                            (constraints.maxWidth - spacing * (cols - 1)) /
                            cols;
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: list
                                .map(
                                  (e) => SizedBox(
                                    width: cardWidth,
                                    child: _WebSponsorEventCard(
                                      event: e,
                                      ctrl: c,
                                      onTap: () => _showSheet(context, e, c),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSheet(
    BuildContext context,
    ExhibitionSponsorEvent event,
    EventsController c,
  ) {
    c.selectedSponsorDuration.value = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SponsorshipBottomSheet(event: event),
    );
  }
}

// ── Filters sidebar ──────────────────────────────────────────────────────────
class _FiltersPanel extends StatelessWidget {
  final EventsController c;
  const _FiltersPanel({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WebTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.tune_rounded, color: WebTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'تصفية',
                style: TextStyle(
                  color: WebTheme.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Obx(
                () => c.sponsorActiveFilterCount > 0
                    ? GestureDetector(
                        onTap: c.clearSponsorFilters,
                        child: Text(
                          'مسح',
                          style: TextStyle(
                            color: WebTheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Filter groups ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // نوع الفعالية
                  _group(
                    title: 'نوع الفعالية',
                    selected: () => c.sponsorTypeFilter.value,
                    onTap: c.setSponsorType,
                    options: () => c.availableSponsorTypes,
                  ),
                  const SizedBox(height: 24),

                  // نطاق السعر
                  _priceSection(context),
                  const SizedBox(height: 24),

                  // نطاق التاريخ
                  _dateSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── نوع الفعالية chips ────────────────────────────────────────────────────
  Widget _group({
    required String title,
    required String Function() selected,
    required void Function(String) onTap,
    required List<String> Function() options,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: WebTheme.text,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      Obx(
        () => Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options().map((o) {
            final active = o == selected();
            return GestureDetector(
              onTap: () => onTap(o),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: active ? AppColors.favoriteGradient : null,
                  color: active ? null : WebTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  o,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.grey,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );

  // ── نطاق السعر ───────────────────────────────────────────────────────────
  // SliderTheme MUST be outside Obx so it uses the build-phase context correctly.
  Widget _priceSection(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: WebTheme.primary,
        inactiveTrackColor: WebTheme.surfaceAlt,
        thumbColor: WebTheme.primary,
        overlayColor: WebTheme.primary.withOpacity(0.15),
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 7,
        ),
        trackHeight: 3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'السعر',
            style: TextStyle(
              color: WebTheme.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Obx(() {
            final maxLimit = c.sponsorComputedMaxPrice;
            final r = c.sponsorPriceRange.value;
            final current = (r.start == 0 && r.end == 0)
                ? RangeValues(0, maxLimit)
                : r;
            return Column(
              children: [
                RangeSlider(
                  min: 0,
                  max: maxLimit,
                  values: current,
                  onChanged: c.setSponsorPriceRange,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${current.start.toStringAsFixed(0)} ﷼',
                      style: TextStyle(color: AppColors.grey, fontSize: 11),
                    ),
                    Text(
                      '${current.end.toStringAsFixed(0)} ﷼',
                      style: TextStyle(color: AppColors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── نطاق التاريخ ─────────────────────────────────────────────────────────
  Widget _dateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ',
          style: TextStyle(
            color: WebTheme.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => _datePicker(
            context: context,
            label: 'من تاريخ',
            value: c.sponsorDateStart.value,
            onPick: (d) => c.setSponsorDateStart(_fmt(d)),
            onClear: () => c.setSponsorDateStart(''),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => _datePicker(
            context: context,
            label: 'إلى تاريخ',
            value: c.sponsorDateEnd.value,
            onPick: (d) => c.setSponsorDateEnd(_fmt(d)),
            onClear: () => c.setSponsorDateEnd(''),
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _datePicker({
    required BuildContext context,
    required String label,
    required String value,
    required void Function(DateTime) onPick,
    required VoidCallback onClear,
  }) {
    final active = value.isNotEmpty;
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final initial = active ? (DateTime.tryParse(value) ?? now) : now;
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: DateTime(2032),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? WebTheme.primary.withOpacity(0.1)
              : WebTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? WebTheme.primary.withOpacity(0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 15,
              color: active ? WebTheme.primary : AppColors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                active ? value : label,
                style: TextStyle(
                  color: active ? WebTheme.primary : AppColors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            if (active)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 14, color: AppColors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Web sponsor-event card ────────────────────────────────────────────────────
class _WebSponsorEventCard extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  final EventsController ctrl;
  final VoidCallback onTap;

  const _WebSponsorEventCard({
    required this.event,
    required this.ctrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hover = false.obs;
    final minPrice = event.durationOptions.isNotEmpty
        ? event.durationOptions.first.price
        : 0.0;

    return Obx(
      () => MouseRegion(
        onEnter: (_) => hover.value = true,
        onExit: (_) => hover.value = false,
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: hover.value
                ? (Matrix4.identity()..translate(0.0, -6.0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: WebTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hover.value
                    ? WebTheme.primary.withOpacity(0.5)
                    : WebTheme.border,
              ),
              boxShadow: hover.value
                  ? [
                      BoxShadow(
                        color: WebTheme.primary.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image header ───────────────────────────
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: event.exhibitionImageUrl.isNotEmpty
                          ? Image.network(
                              event.exhibitionImageUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),

                    // Type badge — top right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Favourite — top left
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Obx(() {
                        ctrl.exhibitionSponsorEvents.length;
                        return GestureDetector(
                          onTap: () => ctrl.toggleSponsorFavorite(event),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              event.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: event.isFavorite
                                  ? AppColors.error
                                  : Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                // ── Content ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: WebTheme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${event.type} • ${event.exhibitionName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _infoRow(
                        Icons.calendar_today_outlined,
                        '${event.date}   ${event.startTime} — ${event.endTime}',
                      ),
                      const SizedBox(height: 4),
                      _infoRow(Icons.location_on_outlined, event.place),
                      const SizedBox(height: 4),
                      _infoRow(
                        Icons.schedule_outlined,
                        'مدة الإدراج: ${event.listingDays} أيام',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              'من ${minPrice.toStringAsFixed(0)} ﷼',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.favoriteGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'احجز الآن',
                              style: TextStyle(
                                color: WebTheme.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    height: 160,
    width: double.infinity,
    color: WebTheme.surfaceAlt,
    child: Icon(
      Icons.campaign_rounded,
      size: 48,
      color: AppColors.grey.withOpacity(0.4),
    ),
  );

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 13, color: AppColors.grey),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.grey, fontSize: 12),
        ),
      ),
    ],
  );
}
