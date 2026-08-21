import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';
import 'event_image_provider.dart';

class SponsorEventCard extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool? showFavorite;
  const SponsorEventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onFavorite,
    this.showFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minPrice = event.durationOptions.isNotEmpty
        ? event.durationOptions.first.price
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkCardGradient : null,
          color: isDark ? null : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  _EventImages(event: event),

                  if (onFavorite != null)
                    Positioned(
                      top: 10,
                      left: 8,
                      child: GestureDetector(
                        onTap: onFavorite,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            event.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: event.isFavorite
                                ? AppColors.error
                                : AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${event.type} • ${event.exhibitionName}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.calendar_today_outlined,
                    '${event.date}   ${event.startTime} — ${event.endTime}',
                  ),
                  const SizedBox(height: 4),
                  _infoRow(Icons.location_on_outlined, event.place),
                  const SizedBox(height: 4),
                  _infoRow(
                    Icons.schedule_outlined,
                    'مدة الإدراج: ${event.listingDays} أيام',
                  ),
                  const SizedBox(height: 4),
                  _infoRow(
                    Icons.groups_outlined,
                    'السعة: ${event.capacity} • المسجلون: ${event.registeredCount} • الحضور: ${event.scannedCount}',
                  ),
                  const SizedBox(height: 4),
                  _infoRow(
                    Icons.confirmation_num_outlined,
                    event.ticketType == 'paid'
                        ? 'تذكرة مدفوعة: ${event.ticketPrice.toStringAsFixed(2)} ﷼'
                        : 'الدخول: دعوات مجانية',
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (event.durationOptions.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            'من ${minPrice.toStringAsFixed(0)} ﷼',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.durationOptions.length} خيارات للمشاركة',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
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
                          'احجز الآن',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 13, color: AppColors.grey),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _EventImages extends StatefulWidget {
  final ExhibitionSponsorEvent event;
  const _EventImages({required this.event});

  @override
  State<_EventImages> createState() => _EventImagesState();
}

class _EventImagesState extends State<_EventImages> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.event.images.isNotEmpty
        ? widget.event.images
        : (widget.event.exhibitionImageUrl.isNotEmpty
              ? [widget.event.exhibitionImageUrl]
              : const <String>[]);
    if (images.isEmpty) {
      return Container(
        height: 150,
        color: AppColors.darkSurface,
        child: const Center(
          child: Icon(Icons.image, size: 48, color: AppColors.grey),
        ),
      );
    }
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (_, index) => Image(
              image: eventImageProvider(images[index]),
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.darkSurface,
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (dot) => Container(
                    width: dot == _index ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: dot == _index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
