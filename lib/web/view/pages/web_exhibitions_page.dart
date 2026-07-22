import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/exhibitions_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../widgets/web_exhibition_card.dart';

class WebExhibitionsPage extends StatelessWidget {
  const WebExhibitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExhibitionsController>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Filters sidebar ──────────────────────────────
          SizedBox(width: 240, child: _FiltersPanel(c: c)),
          const SizedBox(width: 24),
          // ── Grid ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search
                TextField(
                  controller: c.searchCtrl,
                  onChanged: c.onSearch,
                  style: TextStyle(color: WebTheme.text),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن معرض...',
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
                Expanded(
                  child: Obx(() {
                    final list = c.filtered.toList();
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
                              Icons.search_off_rounded,
                              size: 56,
                              color: AppColors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد معارض مطابقة',
                              style: TextStyle(color: AppColors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    return LayoutBuilder(
                      builder: (_, constraints) {
                        const spacing = 20.0;
                        final cols = (constraints.maxWidth /
                                (280 + spacing))
                            .floor()
                            .clamp(1, 3);
                        final cardWidth =
                            (constraints.maxWidth -
                                    spacing * (cols - 1)) /
                                cols;
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: list
                                .map(
                                  (e) => SizedBox(
                                    width: cardWidth,
                                    child: WebExhibitionCard(
                                        exhibition: e),
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
}

// ── Filters panel ───────────────────────────────────────────
class _FiltersPanel extends StatelessWidget {
  final ExhibitionsController c;
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
                () => c.activeFilterCount > 0
                    ? GestureDetector(
                        onTap: c.clearFilters,
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _group(
                    'الحالة',
                    () => c.statusFilter.value,
                    c.applyFilter,
                    () => c.filters,
                  ),
                  const SizedBox(height: 20),
                  _group(
                    'النوع / القطاع',
                    () => c.sectorFilter.value,
                    c.setSector,
                    () => c.availableSectors,
                  ),
                  const SizedBox(height: 20),
                  _group(
                    'البلد / المدينة',
                    () => c.cityFilter.value,
                    c.setCity,
                    () => c.availableCities,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(
    String title,
    String Function() selected,
    void Function(String) onTap,
    List<String> Function() options,
  ) => Column(
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
}
