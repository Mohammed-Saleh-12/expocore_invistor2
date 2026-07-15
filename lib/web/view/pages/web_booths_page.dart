import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/booth_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../widgets/web_section_header.dart';
import '../widgets/web_booth_card.dart';
import '../../controllers/web_nav_controller.dart';

class WebBoothsPage extends StatelessWidget {
  const WebBoothsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BoothController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fixed header + filters ────────────────────────
        Container(
          color: WebTheme.bg,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WebSectionHeader(
                title: 'أجنحتي',
                subtitle: 'إدارة الأجنحة المحجوزة وتقاريرها',
              ),
              const SizedBox(height: 20),
              // ── Status filters ──────────────────────────
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: c.filters.map((f) {
                    final active = c.statusFilter.value == f;
                    return GestureDetector(
                      onTap: () => c.applyFilter(f),
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
                          f,
                          style: TextStyle(
                            color: active ? Colors.white : AppColors.grey,
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

        // ── Scrollable booths grid ─────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Obx(() {
              final list = c.filtered.toList();
              if (list.isEmpty) return _empty();
              return LayoutBuilder(
                builder: (context, cons) {
                  final cols = cons.maxWidth > 1100
                      ? 3
                      : (cons.maxWidth > 700 ? 2 : 1);
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
                      final approved = b.status == 'active';
                      return WebBoothCard(
                        booth: b,
                        primaryLabel: approved ? 'إدارة' : 'تفاصيل',
                        onPrimary: () => approved
                            ? WebNavController.to.openBoothManagement(b)
                            : WebNavController.to.openBooth(
                                b,
                                report: c.buildBoothReport(b),
                              ),
                        secondaryLabel:
                            (approved || b.status == 'ended') ? 'التقرير' : 'خريطة 3D',
                        onSecondary: () =>
                            (approved || b.status == 'ended')
                                ? WebNavController.to
                                    .openReport(c.buildBoothReport(b))
                                : WebNavController.to.openMap(),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _empty() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(60),
    alignment: Alignment.center,
    child: Column(
      children: [
        Icon(
          Icons.grid_off_rounded,
          size: 56,
          color: AppColors.grey.withOpacity(0.5),
        ),
        const SizedBox(height: 12),
        Text('لا توجد أجنحة', style: TextStyle(color: AppColors.grey)),
      ],
    ),
  );
}

