import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/booth/booth_model.dart';

class BoothCard extends StatelessWidget {
  final BoothModel booth;
  final VoidCallback onManage;
  final VoidCallback onFavorite;
  final VoidCallback? onReport;
  final VoidCallback? onViewMap;

  const BoothCard({
    super.key,
    required this.booth,
    required this.onManage,
    required this.onFavorite,
    this.onReport,
    this.onViewMap,
  });

  bool get _isApproved => booth.status == 'active';

  Color _statusColor(String s) {
    switch (s) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.info;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'active':
        return 'نشط';
      case 'pending':
        return 'قيد المراجعة';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'منتهٍ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onManage,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkCardGradient : null,
          color: isDark ? null : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(16),
                  ),
                  child: Image.network(
                    booth.imageUrl,
                    width: 100,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 130,
                      color: AppColors.darkSurface,
                      child: const Icon(Icons.store, color: AppColors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Icon(
                      booth.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: booth.isFavorite
                          ? AppColors.error
                          : AppColors.grey,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'جناح ${booth.number}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(booth.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _statusLabel(booth.status),
                            style: TextStyle(
                              color: _statusColor(booth.status),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booth.exhibitionName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    Text(
                      'المساحة: ${booth.area.toInt()}م²',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                    Text(
                      'السعر: ${booth.price.toInt()} ريال',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isApproved)
                      _ApprovedButtons(onManage: onManage, onReport: onReport)
                    else
                      _PendingButtons(
                        onManage: onManage,
                        onViewMap: onViewMap,
                        onReport: onReport,
                      ),
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

class _ApprovedButtons extends StatelessWidget {
  final VoidCallback onManage;
  final VoidCallback? onReport;

  const _ApprovedButtons({required this.onManage, this.onReport});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onManage,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.favoriteGradient,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              'إدارة',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
        const SizedBox(width: 6),
        if (onReport != null)
          GestureDetector(
            onTap: onReport,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkPrimary),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'التقرير',
                style: TextStyle(color: AppColors.darkPrimary, fontSize: 11),
              ),
            ),
          ),
      ],
    );
  }
}

class _PendingButtons extends StatelessWidget {
  final VoidCallback onManage;
  final VoidCallback? onViewMap;
  final VoidCallback? onReport;

  const _PendingButtons({
    required this.onManage,
    this.onViewMap,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onManage,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.favoriteGradient,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              'استعراض الجناح',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
        const SizedBox(width: 6),
        if (onViewMap != null)
          GestureDetector(
            onTap: onViewMap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkPrimary),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 11, color: AppColors.darkPrimary),
                  SizedBox(width: 3),
                  Text(
                    'على الخريطة',
                    style: TextStyle(color: AppColors.darkPrimary, fontSize: 10),
                  ),
                ],
              ),
            ),
          )
        else if (onReport != null)
          GestureDetector(
            onTap: onReport,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkPrimary),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'التقرير',
                style: TextStyle(color: AppColors.darkPrimary, fontSize: 11),
              ),
            ),
          ),
      ],
    );
  }
}
