import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/booth_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/booth/booth_model.dart';
import '../widgets/web_section_header.dart';
import '../widgets/web_status_chip.dart';
import '../../controllers/web_nav_controller.dart';

// ════════════════════════════════════════════════════════════
//  WebBoothsPage  —  أجنحتي
// ════════════════════════════════════════════════════════════
class WebBoothsPage extends StatelessWidget {
  const WebBoothsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BoothController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: WebSectionHeader(
                  title: 'أجنحتي',
                  subtitle: 'إدارة الأجنحة المحجوزة وتقاريرها',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Status filters ───────────────────────────────
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
                        color: active ? WebTheme.text : AppColors.grey,
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Booths grid ──────────────────────────────────
          Obx(() {
            final list = c.filtered.toList();
            if (list.isEmpty) {
              return _empty();
            }
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
                  itemBuilder: (_, i) => _BoothCard(booth: list[i], c: c),
                );
              },
            );
          }),
        ],
      ),
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

// ── Booth card ──────────────────────────────────────────────
class _BoothCard extends StatelessWidget {
  final BoothModel booth;
  final BoothController c;
  const _BoothCard({required this.booth, required this.c});

  bool get _approved => booth.status == 'active';

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
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: AppColors.darkPrimary,
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
          Row(
            children: [
              _info(Icons.straighten_rounded, '${booth.area.toInt()} م²'),
              const SizedBox(width: 16),
              _info(Icons.payments_outlined, '${booth.price.toInt()} ر.س'),
            ],
          ),
          const SizedBox(height: 14),
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
                          report: c.buildBoothReport(booth),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _approved
                    ? _btn(
                        label: 'التقرير',
                        filled: false,
                        onTap: () => WebNavController.to.openReport(
                          c.buildBoothReport(booth),
                        ),
                      )
                    : booth.status == 'ended'
                        ? _btn(
                            label: 'التقرير',
                            filled: false,
                            onTap: () => WebNavController.to.openReport(
                              c.buildBoothReport(booth),
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
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 15, color: AppColors.grey),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: AppColors.grey, fontSize: 12)),
    ],
  );

  Widget _btn({
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: filled ? AppColors.favoriteGradient : null,
        border: filled
            ? null
            : Border.all(color: AppColors.darkPrimary.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? WebTheme.text : AppColors.darkPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
