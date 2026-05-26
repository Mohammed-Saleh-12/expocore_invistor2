import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/booth/booth_model.dart';
import 'favorite_button.dart';

class BoothCard extends StatelessWidget {
  final BoothModel booth;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback? onReport;

  const BoothCard({
    super.key,
    required this.booth,
    required this.onTap,
    required this.onFavorite,
    this.onReport,
  });

  Color _statusColor(String s) {
    switch (s) {
      case 'active':   return AppColors.success;
      case 'pending':  return AppColors.info;
      case 'rejected': return AppColors.error;
      default:         return AppColors.grey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'active':   return 'نشط';
      case 'pending':  return 'قيد المراجعة';
      case 'rejected': return 'مرفوض';
      default:         return 'منتهٍ';
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                  child: Image.network(booth.imageUrl, width: 100, height: 120, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 100, height: 120, color: AppColors.darkSurface, child: const Icon(Icons.store, color: AppColors.grey))),
                ),
                Positioned(top: 6, right: 6,
                  child: FavoriteButton(isFavorite: booth.isFavorite, onTap: onFavorite, size: 30)),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('جناح ${booth.number}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: _statusColor(booth.status).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(_statusLabel(booth.status), style: TextStyle(color: _statusColor(booth.status), fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(booth.exhibitionName, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                    Text('المساحة: ${booth.area.toInt()}م²', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                    Text('السعر: ${booth.price.toInt()} ريال', style: const TextStyle(fontSize: 11, color: AppColors.orange)),
                    const SizedBox(height: 8),
                    Row(children: [
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(gradient: AppColors.darkCTAGradient, borderRadius: BorderRadius.circular(7)),
                          child: const Text('إدارة', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (onReport != null)
                        GestureDetector(
                          onTap: onReport,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(border: Border.all(color: AppColors.darkPrimary), borderRadius: BorderRadius.circular(7)),
                            child: const Text('التقرير', style: TextStyle(color: AppColors.darkPrimary, fontSize: 11)),
                          ),
                        ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
