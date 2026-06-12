import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/exhibition/exhibition_model.dart';
import '../../controllers/web_nav_controller.dart';
import '../../models/web_theme.dart';

// ════════════════════════════════════════════════════════════
//  WebBillboard  —  شريط إعلانات متحرك (carousel) أعلى الرئيسية
// ════════════════════════════════════════════════════════════
class WebBillboard extends StatefulWidget {
  final List<ExhibitionModel> items;
  const WebBillboard({super.key, required this.items});

  @override
  State<WebBillboard> createState() => _WebBillboardState();
}

class _WebBillboardState extends State<WebBillboard> {
  final _ctrl = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAuto();
  }

  void _startAuto() {
    _timer?.cancel();
    if (widget.items.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_ctrl.hasClients) return;
      _page = (_page + 1) % widget.items.length;
      _ctrl.animateToPage(
        _page,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (widget.items.isEmpty) return;
    final next = (_page + 1) % widget.items.length;
    _ctrl.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _prev() {
    if (widget.items.isEmpty) return;
    final prev = (_page - 1 + widget.items.length) % widget.items.length;
    _ctrl.animateToPage(
      prev,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) =>
                _AdCard(item: widget.items[i], prev: _prev, next: _next),
          ),
        ),

        const SizedBox(height: 12),
        // ── Dots ─────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: active ? AppColors.favoriteGradient : null,
                color: active ? null : AppColors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Single ad card ──────────────────────────────────────────
class _AdCard extends StatefulWidget {
  final ExhibitionModel item;
  final Function next;
  final Function prev;
  const _AdCard({required this.item, required this.next, required this.prev});

  @override
  State<_AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<_AdCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.item;
    final n = widget.prev;
    final p = widget.next;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => WebNavController.to.openExhibition(e),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          transform: _hover
              ? (Matrix4.identity()..translate(0.0, -4.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkPrimary.withOpacity(_hover ? 0.4 : 0.2),
                blurRadius: _hover ? 28 : 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                Image.network(
                  e.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.darkSurface),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        AppColors.darkBg.withOpacity(0.92),
                        AppColors.darkBg.withOpacity(0.55),
                        AppColors.darkBg.withOpacity(0.15),
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.favoriteGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'إعلان مميّز',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        e.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${e.location}، ${e.city}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${e.startDate} — ${e.endDate}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: WebTheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'اكتشف المعرض',
                              style: TextStyle(
                                color: WebTheme.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 16,
                              color: AppColors.darkPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // // Left arrow
                // Positioned(
                //   left: 6,
                //   child: _NavButton(
                //     icon: Icons.chevron_left_rounded,
                //     onTap: p(),
                //   ),
                // ),

                // // Right arrow
                // Positioned(
                //   right: 6,
                //   child: _NavButton(
                //     icon: Icons.chevron_right_rounded,
                //     onTap: n(),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
