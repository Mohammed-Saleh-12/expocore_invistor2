import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/booth/booth_model.dart';
import 'web_status_chip.dart';

// ════════════════════════════════════════════════════════════
//  WebBoothCard  —  كرت الجناح المشترك (أجنحتي + المفضلة)
// ════════════════════════════════════════════════════════════
class WebBoothCard extends StatelessWidget {
  final BoothModel booth;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  const WebBoothCard({
    super.key,
    required this.booth,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

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
          // ── Header ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: WebTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: WebTheme.primary,
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

          // ── Info row ────────────────────────────────────
          Row(
            children: [
              _info(Icons.straighten_rounded, '${booth.area.toInt()} م²'),
              const SizedBox(width: 16),
              _info(Icons.payments_outlined, '${booth.price.toInt()} ر.س'),
            ],
          ),
          const SizedBox(height: 14),

          // ── Action buttons ───────────────────────────────
          Row(
            children: [
              Expanded(
                child: _btn(
                  label: primaryLabel,
                  filled: true,
                  onTap: onPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _btn(
                  label: secondaryLabel,
                  filled: false,
                  onTap: onSecondary,
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
            : Border.all(color: WebTheme.primary.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.white : WebTheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
