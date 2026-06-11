import 'package:flutter/material.dart';
import '../web_theme.dart';
import '../../core/constant/appcolors.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../controllers/web_nav_controller.dart';

// ════════════════════════════════════════════════════════════
//  WebExhibitionCard  —  بطاقة معرض بتصميم ويب
// ════════════════════════════════════════════════════════════
class WebExhibitionCard extends StatefulWidget {
  final ExhibitionModel exhibition;
  final VoidCallback?   onTap;
  final VoidCallback?   onFavorite;
  const WebExhibitionCard({super.key, required this.exhibition, this.onTap, this.onFavorite});

  @override
  State<WebExhibitionCard> createState() => _WebExhibitionCardState();
}

class _WebExhibitionCardState extends State<WebExhibitionCard> {
  bool _hover = false;

  Color get _statusColor {
    switch (widget.exhibition.status) {
      case 'active':   return AppColors.success;
      case 'upcoming': return AppColors.info;
      default:         return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exhibition;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap ?? () => WebNavController.to.openExhibition(widget.exhibition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _hover ? (Matrix4.identity()..translate(0.0, -6.0)) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: WebTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hover ? AppColors.darkPrimary.withOpacity(0.5) : WebTheme.border,
            ),
            boxShadow: _hover
                ? [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12))]
                : [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      e.imageUrl,
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 170,
                        color: AppColors.darkSurface,
                        child: Icon(Icons.image, size: 48, color: AppColors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(e.statusLabel,
                          style: TextStyle(color: WebTheme.text, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              // ── Body ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: WebTheme.text, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _row(Icons.location_on_outlined, '${e.location}، ${e.city}'),
                    const SizedBox(height: 4),
                    _row(Icons.calendar_today_outlined, '${e.startDate} — ${e.endDate}'),
                    const SizedBox(height: 12),
                    // sectors
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: e.sectors.take(3).map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.darkPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(s, style: TextStyle(color: AppColors.darkPink, fontSize: 10)),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.darkSecondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${e.availableBooths} جناح متاح',
                              style: TextStyle(color: AppColors.darkSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_rounded,
                            color: _hover ? AppColors.darkPrimary : AppColors.grey, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.grey, fontSize: 12)),
          ),
        ],
      );
}
