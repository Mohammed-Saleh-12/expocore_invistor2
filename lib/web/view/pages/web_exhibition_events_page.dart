import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../../view/widget/Home/sponsorship_bottom_sheet.dart';
import '../widgets/web_section_header.dart';
import '../../controllers/web_nav_controller.dart';

class WebExhibitionEventsPage extends StatelessWidget {
  const WebExhibitionEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EventsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: WebTheme.bg,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
          child: WebSectionHeader(
            title: 'فعاليات المعارض الإعلانية',
            subtitle: 'تصفح فعاليات المعارض المتاحة للرعاية',
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Obx(() {
              final list = c.exhibitionSponsorEvents.toList();
              if (c.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                        color: AppColors.darkPrimary),
                  ),
                );
              }
              if (list.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(60),
                  alignment: Alignment.center,
                  child: Column(children: [
                    Icon(Icons.campaign_outlined,
                        size: 56,
                        color: AppColors.grey.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text('لا توجد فعاليات إعلانية متاحة حالياً',
                        style: TextStyle(color: AppColors.grey)),
                  ]),
                );
              }
              return Column(
                children: list
                    .map((e) => _ExhibitionEventCard(
                          event: e,
                          onTap: () => _showSheet(context, e, c),
                        ))
                    .toList(),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _showSheet(
      BuildContext context, ExhibitionSponsorEvent event, EventsController c) {
    c.selectedSponsorDuration.value = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SponsorshipBottomSheet(event: event),
    );
  }
}

class _ExhibitionEventCard extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  final VoidCallback onTap;
  const _ExhibitionEventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: WebTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WebTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.favoriteGradient,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.campaign_rounded,
                  color: WebTheme.text, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: WebTheme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    _meta(Icons.calendar_today_outlined, event.date),
                    const SizedBox(width: 16),
                    if (event.durationOptions.isNotEmpty)
                      _meta(Icons.attach_money_rounded,
                          'من ${event.durationOptions.first.price.toInt()} ر.س'),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.favoriteGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'رعاية',
                style: TextStyle(
                  color: WebTheme.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: AppColors.grey, fontSize: 12)),
      ]);
}
