import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/web_theme.dart';
import '../../../core/constant/appcolors.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../controllers/web_nav_controller.dart';

class WebSponsorEventCard extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  const WebSponsorEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onFavorite,
  });

  IconData get _typeIcon {
    switch (event.type) {
      case 'مؤتمر':
        return Icons.record_voice_over_outlined;
      case 'ندوة':
        return Icons.people_outline;
      case 'حفل افتتاح':
      case 'حفل ختامي':
        return Icons.celebration_outlined;
      case 'مسابقة':
        return Icons.emoji_events_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hover = false.obs;
    final e = event;
    final minPrice =
        e.durationOptions.isNotEmpty ? e.durationOptions.first.price : 0.0;

    return Obx(
      () => MouseRegion(
        onEnter: (_) => hover.value = true,
        onExit: (_) => hover.value = false,
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap ?? () => WebNavController.to.openSponsorEvent(event),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image header ────────────────────────────
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        e.exhibitionImageUrl,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 170,
                          color: WebTheme.surfaceAlt,
                          child: const Icon(
                            Icons.image,
                            size: 48,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                    // Type badge (top-right)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [WebTheme.primary, WebTheme.secondary],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          e.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Favorite button (top-left)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Obx(() {
                        final eventsCtrl = Get.find<EventsController>();
                        eventsCtrl.exhibitionSponsorEvents.length;
                        return GestureDetector(
                          onTap:
                              onFavorite ??
                              () => eventsCtrl.toggleSponsorFavorite(event),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              e.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  e.isFavorite ? AppColors.error : Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                // ── Content ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with icon
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: WebTheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _typeIcon,
                              color: WebTheme.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: WebTheme.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _row(
                        Icons.store_outlined,
                        e.exhibitionName,
                      ),
                      const SizedBox(height: 4),
                      _row(
                        Icons.calendar_today_outlined,
                        '${e.date}   ${e.startTime} — ${e.endTime}',
                      ),
                      const SizedBox(height: 4),
                      _row(Icons.location_on_outlined, e.place),
                      const SizedBox(height: 4),
                      _row(
                        Icons.schedule_outlined,
                        'مدة الإدراج: ${e.listingDays} أيام',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.35),
                              ),
                            ),
                            child: Text(
                              minPrice > 0
                                  ? 'من ${minPrice.toStringAsFixed(0)} ﷼'
                                  : '${e.durationOptions.length} خيارات',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: hover.value
                                ? WebTheme.primary
                                : AppColors.grey,
                            size: 20,
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

  Widget _row(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: AppColors.grey),
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
