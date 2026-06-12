import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/exhibition/exhibition_model.dart';
import '../../controllers/web_nav_controller.dart';
import '../../controllers/web_billboard_controller.dart';
import '../../models/web_theme.dart';

class WebBillboard extends StatelessWidget {
  final List<ExhibitionModel> items;
  const WebBillboard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final ctrl = Get.put(WebBillboardController(), tag: 'web_billboard');
    ctrl.init(items.length);
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: ctrl.pageCtrl,
            itemCount: items.length,
            onPageChanged: ctrl.onPageChanged,
            itemBuilder: (_, i) => _AdCard(item: items[i], ctrl: ctrl),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (i) {
                final active = i == ctrl.currentIndex.value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 26 : 8, height: 8,
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.favoriteGradient : null,
                    color: active ? null : AppColors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            )),
      ],
    );
  }
}

class _AdCard extends StatelessWidget {
  final ExhibitionModel item;
  final WebBillboardController ctrl;
  const _AdCard({required this.item, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final hover = false.obs;
    final e = item;
    return Obx(() => MouseRegion(
          onEnter: (_) => hover.value = true,
          onExit: (_) => hover.value = false,
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => WebNavController.to.openExhibition(e),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              transform: hover.value ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: AppColors.darkPrimary.withOpacity(hover.value ? 0.4 : 0.2), blurRadius: hover.value ? 28 : 16, offset: const Offset(0, 10))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(e.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.darkSurface)),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight, end: Alignment.centerLeft,
                          colors: [AppColors.darkBg.withOpacity(0.92), AppColors.darkBg.withOpacity(0.55), AppColors.darkBg.withOpacity(0.15)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(20)),
                            child: const Text('إعلان مميّز', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 14),
                          Text(e.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 15, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text('${e.location}، ${e.city}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(width: 16),
                              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text('${e.startDate} — ${e.endDate}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(color: WebTheme.surface.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('اكتشف المعرض', style: TextStyle(color: WebTheme.text, fontSize: 13, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.darkPrimary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
