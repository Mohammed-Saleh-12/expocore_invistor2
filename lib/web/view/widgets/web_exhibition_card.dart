import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/web_theme.dart';
import '../../../core/constant/appcolors.dart';
import '../../../controller/Home/favorites_controller.dart';
import '../../../data/model/exhibition/exhibition_model.dart';
import '../../controllers/web_nav_controller.dart';

class WebExhibitionCard extends StatelessWidget {
  final ExhibitionModel exhibition;
  final VoidCallback?   onTap;
  final VoidCallback?   onFavorite;
  const WebExhibitionCard({super.key, required this.exhibition, this.onTap, this.onFavorite});

  Color get _statusColor {
    switch (exhibition.status) {
      case 'active':   return AppColors.success;
      case 'upcoming': return AppColors.info;
      default:         return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hover = false.obs;
    final e = exhibition;
    return Obx(() => MouseRegion(
          onEnter: (_) => hover.value = true,
          onExit: (_) => hover.value = false,
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap ?? () => WebNavController.to.openExhibition(exhibition),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: hover.value ? (Matrix4.identity()..translate(0.0, -6.0)) : Matrix4.identity(),
              decoration: BoxDecoration(
                color: WebTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: hover.value ? WebTheme.primary.withOpacity(0.5) : WebTheme.border),
                boxShadow: hover.value
                    ? [BoxShadow(color: WebTheme.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(e.imageUrl, height: 170, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 170, color: WebTheme.surfaceAlt, child: const Icon(Icons.image, size: 48, color: AppColors.grey))),
                      ),
                      Positioned(
                        top: 12, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: _statusColor.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                          child: Text(e.statusLabel, style: TextStyle(color: WebTheme.text, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      Positioned(
                        top: 10, left: 10,
                        child: Obx(() {
                          final fav = Get.find<FavoritesController>();
                          final isFav = fav.isExhibitionFavorited(e.id);
                          return GestureDetector(
                            onTap: onFavorite ?? () => fav.toggleFavoriteExhibition(exhibition),
                            child: Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? AppColors.error : Colors.white,
                                size: 18,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: WebTheme.text, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _row(Icons.location_on_outlined, '${e.location}، ${e.city}'),
                        const SizedBox(height: 4),
                        _row(Icons.calendar_today_outlined, '${e.startDate} — ${e.endDate}'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          children: e.sectors.take(3).map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: WebTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text(s, style: TextStyle(color: WebTheme.pink, fontSize: 10)),
                          )).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: WebTheme.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                              child: Text('${e.availableBooths} جناح متاح',
                                  style: TextStyle(color: WebTheme.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_rounded, color: hover.value ? WebTheme.primary : AppColors.grey, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.grey),
          const SizedBox(width: 5),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.grey, fontSize: 12))),
        ],
      );
}
