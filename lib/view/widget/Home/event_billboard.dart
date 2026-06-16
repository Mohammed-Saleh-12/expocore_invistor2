import 'package:expocore_invistor2/web/models/web_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../controller/Home/event_billboard_controller.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';

class EventBillboard extends StatelessWidget {
  final List<ExhibitionSponsorEvent> events;
  final void Function(ExhibitionSponsorEvent)? onTap;

  const EventBillboard({super.key, required this.events, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    final ctrl = Get.put(EventBillboardController(), tag: 'event_billboard');
    ctrl.init(events.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 22,
                decoration: BoxDecoration(
                  gradient: AppColors.favoriteGradient,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'فعاليات اعلانية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: WebTheme.text,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: ctrl.pageCtrl,
                itemCount: events.length,
                onPageChanged: ctrl.onPageChanged,
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () => onTap?.call(events[index]),
                  child: _EventBillboardSlide(event: events[index]),
                ),
              ),
            ),
            Positioned(
              left: 6,
              child: _NavBtn(
                icon: Icons.chevron_left_rounded,
                onTap: ctrl.prev,
              ),
            ),
            Positioned(
              right: 6,
              child: _NavBtn(
                icon: Icons.chevron_right_rounded,
                onTap: ctrl.next,
              ),
            ),
            Positioned(
              bottom: 10,
              child: Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(events.length, (i) {
                    final isActive = i == ctrl.currentIndex.value;
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
                    colors: [AppColors.darkPrimary, AppColors.darkSecondary],
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
  Widget build(BuildContext context) => GestureDetector(
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
