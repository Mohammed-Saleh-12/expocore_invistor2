import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';

class EventBillboard extends StatefulWidget {
  final List<ExhibitionSponsorEvent> events;
  final void Function(ExhibitionSponsorEvent)? onTap;

  const EventBillboard({super.key, required this.events, this.onTap});

  @override
  State<EventBillboard> createState() => _EventBillboardState();
}

class _EventBillboardState extends State<EventBillboard> {
  late final PageController _pageController;
  late final Timer _autoTimer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) => _next());
  }

  @override
  void dispose() {
    _autoTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (widget.events.isEmpty) return;
    final next = (_current + 1) % widget.events.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _prev() {
    if (widget.events.isEmpty) return;
    final prev = (_current - 1 + widget.events.length) % widget.events.length;
    _pageController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'فعاليات إعلانية',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.events.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, index) {
                  final ev = widget.events[index];
                  return GestureDetector(
                    onTap: () => widget.onTap?.call(ev),
                    child: _EventBillboardSlide(event: ev),
                  );
                },
              ),
            ),
            Positioned(
              left: 6,
              child: _NavBtn(icon: Icons.chevron_left_rounded, onTap: _prev),
            ),
            Positioned(
              right: 6,
              child: _NavBtn(icon: Icons.chevron_right_rounded, onTap: _next),
            ),
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.events.length, (i) {
                  final isActive = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EventBillboardSlide extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  const _EventBillboardSlide({required this.event});

  IconData _typeIcon(String type) {
    switch (type) {
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              event.exhibitionImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.darkSurface,
                child: const Icon(Icons.image, size: 84, color: AppColors.grey),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x44000000), Color(0xDD000000)],
                  stops: [0.2, 1.0],
                ),
              ),
            ),
            // Sponsorship badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.darkSecondary, AppColors.darkAccent],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'فرصة إعلانية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Type badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon(event.type), size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      event.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.store_outlined,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.exhibitionName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.date,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'من ${event.durationOptions.first.price.toStringAsFixed(0)} ﷼',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${event.listingDays} أيام إعلانية',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
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

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

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
