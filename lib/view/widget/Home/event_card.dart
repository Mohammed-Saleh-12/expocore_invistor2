import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/event_model.dart';
import 'favorite_button.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool showFavorite;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onFavorite,
    this.showFavorite = false,
  });

  IconData _typeIcon(String type) {
    switch (type) {
      case 'ورشة عمل': return Icons.school_outlined;
      case 'عرض مباشر': return Icons.live_tv_outlined;
      case 'مسابقة': return Icons.emoji_events_outlined;
      case 'لقاء B2B': return Icons.handshake_outlined;
      default: return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = event.maxParticipants > 0 ? event.registeredCount / event.maxParticipants : 0.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkCardGradient : null,
          color: isDark ? null : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.darkCTAGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon(event.type), color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text('${event.type} • ${event.exhibitionName}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                  Text('${event.date} — ${event.time}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: AppColors.darkSurface,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkPrimary),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${event.registeredCount}/${event.maxParticipants}', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                  ]),
                ],
              ),
            ),
            if (showFavorite && onFavorite != null)
              FavoriteButton(isFavorite: event.isFavorite, onTap: onFavorite!, size: 32),
          ],
        ),
      ),
    );
  }
}
