import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/exhibition/exhibition_model.dart';
import 'favorite_button.dart';

class ExhibitionCard extends StatelessWidget {
  final ExhibitionModel exhibition;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const ExhibitionCard({
    super.key,
    required this.exhibition,
    required this.onTap,
    required this.onFavorite,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'upcoming':
        return AppColors.info;
      default:
        return AppColors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'جارٍ';
      case 'upcoming':
        return 'قادم';
      default:
        return 'منتهٍ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkCardGradient : null,
          color: isDark ? null : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    exhibition.imageUrl,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: AppColors.darkSurface,
                      child: const Icon(
                        Icons.image,
                        size: 48,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(exhibition.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _statusColor(exhibition.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _statusLabel(exhibition.status),
                      style: TextStyle(
                        color: _statusColor(exhibition.status),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: FavoriteButton(
                    isFavorite: exhibition.isFavorite,
                    onTap: onFavorite,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exhibition.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exhibition.location}، ${exhibition.city}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exhibition.startDate} — ${exhibition.endDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${exhibition.availableBooths} جناح متاح',
                          style: const TextStyle(
                            color: AppColors.darkPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
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
                            'عرض التفاصيل',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
}
