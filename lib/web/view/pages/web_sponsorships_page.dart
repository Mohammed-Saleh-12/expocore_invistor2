import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/sponsorship_booking_model.dart';
import '../widgets/web_section_header.dart';
import '../widgets/web_status_chip.dart';
import '../../controllers/web_nav_controller.dart';

// ════════════════════════════════════════════════════════════
//  WebSponsorshipsPage  —  رعاياتي (مطابقة لـ my_sponsorships)
// ════════════════════════════════════════════════════════════
class WebSponsorshipsPage extends StatelessWidget {
  const WebSponsorshipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EventsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fixed header ──────────────────────────────────
        Container(
          color: WebTheme.bg,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
          child: const WebSectionHeader(
            title: 'رعاياتي',
            subtitle: 'الفعاليات التي ترعاها في المعارض',
          ),
        ),

        // ── Scrollable sponsorships list ───────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Obx(() {
              final list = c.mySponsorshipBookings.toList();
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
                    Icon(Icons.workspace_premium_outlined,
                        size: 56,
                        color: AppColors.grey.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text('لا توجد رعايات حتى الآن',
                        style: TextStyle(color: AppColors.grey)),
                    const SizedBox(height: 6),
                    Text('تصفّح فعاليات المعارض وقدّم طلب رعاية',
                        style: TextStyle(
                            color: AppColors.grey, fontSize: 12)),
                  ]),
                );
              }
              return Column(
                children: list
                    .map((b) => _SponsorshipCard(booking: b))
                    .toList(),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SponsorshipCard extends StatelessWidget {
  final SponsorshipBookingModel booking;
  const _SponsorshipCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => WebNavController.to.openSponsorship(booking),
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
              child: Icon(Icons.workspace_premium_rounded,
                  color: WebTheme.text, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.eventName,
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
                    booking.exhibitionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    _meta(Icons.timelapse_rounded,
                        booking.selectedDurationLabel),
                    const SizedBox(width: 16),
                    _meta(Icons.calendar_today_outlined, booking.date),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                WebStatusChip(status: booking.status),
                const SizedBox(height: 8),
                Text(
                  '${booking.price.toInt()} ر.س',
                  style: TextStyle(
                    color: AppColors.darkAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(color: AppColors.grey, fontSize: 12)),
      ]);
}
