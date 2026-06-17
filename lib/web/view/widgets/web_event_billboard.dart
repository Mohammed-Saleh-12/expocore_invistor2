import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../controllers/web_nav_controller.dart';
import '../../controllers/web_billboard_controller.dart';

class WebEventBillboard extends StatelessWidget {
  final List<ExhibitionSponsorEvent> events;
  const WebEventBillboard({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    final ctrl = Get.put(WebBillboardController(), tag: 'web_events_billboard');
    ctrl.init(events.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: ctrl.pageCtrl,
                itemCount: events.length,
                onPageChanged: ctrl.onPageChanged,
                itemBuilder: (_, i) =>
                    _EventSlide(event: events[i], ctrl: ctrl),
              ),
            ),
            if (events.length > 1) ...[
              Positioned(
                left: 14,
                child: _NavBtn(
                  onTap: ctrl.prev,
                  icon: Icons.arrow_back_ios_new_rounded,
                ),
              ),
              Positioned(
                right: 14,
                child: _NavBtn(
                  onTap: ctrl.next,
                  icon: Icons.arrow_forward_ios_rounded,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(events.length, (i) {
              final active = i == ctrl.currentIndex.value;
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
        ),
      ],
    );
  }
}

// ── Navigation button ────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  const _NavBtn({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    final hover = false.obs;
    return Obx(
      () => MouseRegion(
        onEnter: (_) => hover.value = true,
        onExit: (_) => hover.value = false,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hover.value
                  ? Colors.black.withOpacity(0.72)
                  : Colors.black.withOpacity(0.42),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

// ── Event slide card ─────────────────────────────────────────
class _EventSlide extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  final WebBillboardController ctrl;
  const _EventSlide({required this.event, required this.ctrl});

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
    final hover = false.obs;
    return Obx(
      () => MouseRegion(
        onEnter: (_) => hover.value = true,
        onExit: (_) => hover.value = false,
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => WebNavController.to.openSponsorEvent(event),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            transform: hover.value
                ? (Matrix4.identity()..translate(0.0, -4.0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: WebTheme.bg,
                  blurRadius: hover.value ? 28 : 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Background image ─────────────────────
                  Image.network(
                    event.exhibitionImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: WebTheme.surfaceAlt,
                      child: const Icon(
                        Icons.image,
                        size: 72,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  // ── Dark overlay ─────────────────────────
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x55000000), Color(0xE8000000)],
                        stops: [0.2, 1.0],
                      ),
                    ),
                  ),
                  // ── Favorite button (top-right, below badge) ─
                  Positioned(
                    top: 54,
                    right: 16,
                    child: Obx(() {
                      final eventsCtrl = Get.find<EventsController>();
                      eventsCtrl.exhibitionSponsorEvents.length;
                      return GestureDetector(
                        onTap: () => eventsCtrl.toggleSponsorFavorite(event),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.50),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            event.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: event.isFavorite
                                ? AppColors.error
                                : Colors.white,
                            size: 18,
                          ),
                        ),
                      );
                    }),
                  ),
                  // ── Type badge (top-right) ────────────────
                  Positioned(
                    top: 14,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            WebTheme.primary,
                            WebTheme.secondary,
                          ],
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
                  // ── Category badge (top-left) ─────────────
                  Positioned(
                    top: 14,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: WebTheme.primary.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _typeIcon(event.type),
                            size: 12,
                            color: Colors.white,
                          ),
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
                  // ── Content (bottom) ─────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.store_outlined,
                                size: 13,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.exhibitionName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                event.date,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (event.durationOptions.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
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
          ),
        ),
      ),
    );
  }
}
