import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';

class SponsorEventCard extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool? showFavorite;
  const SponsorEventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onFavorite,
    this.showFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minPrice = event.durationOptions.isNotEmpty
        ? event.durationOptions.first.price
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkCardGradient : null,
          color: isDark ? null : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    event.exhibitionImageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: AppColors.darkSurface,
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: AppColors.grey,
                      ),
                    ),
                  ),

                  if (onFavorite != null)
                    Positioned(
                      top: 10,
                      left: 6,
                      child: GestureDetector(
                        onTap: onFavorite,
                        child: Icon(
                          event.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: event.isFavorite
                              ? AppColors.error
                              : AppColors.grey,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${event.type} • ${event.exhibitionName}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  const SizedBox(height: 10),
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
                      const SizedBox(width: 8),
                      Text(
                        '${event.durationOptions.length} خيارات للمشاركة',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.darkPrimary,
                              AppColors.darkSecondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'احجز الآن',
                          style: TextStyle(
                            color: Colors.white,
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
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 13, color: AppColors.grey),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
