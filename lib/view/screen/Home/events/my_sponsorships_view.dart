import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/events_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../../data/model/event/sponsorship_booking_model.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/empty_widget.dart';

class MySponshorshipsView extends GetView<EventsController> {
  const MySponshorshipsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'فعالياتي الإعلانية المحجوزة'),
      body: Obx(() {
        if (controller.mySponsorshipBookings.isEmpty) {
          return EmptyWidget(
            message: 'لم تحجز في أي فعالية إعلانية بعد',
            buttonLabel: 'استعراض الفعاليات',
            onAction: () => Get.toNamed(AppRoutes.EXHIBITION_EVENTS),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.mySponsorshipBookings.length,
          itemBuilder: (_, i) {
            final booking = controller.mySponsorshipBookings[i];
            return _SponsorshipBookingCard(
              booking: booking,
              onTap: () => Get.toNamed(
                AppRoutes.SPONSORSHIP_DETAIL,
                arguments: booking,
              ),
            );
          },
        );
      }),
    );
  }
}

class _SponsorshipBookingCard extends StatelessWidget {
  final SponsorshipBookingModel booking;
  final VoidCallback onTap;

  const _SponsorshipBookingCard(
      {required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = Get.find<EventsController>();
    final statusColor = ctrl.statusColor(booking.status);
    final statusLabel = ctrl.statusLabel(booking.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkCardGradient : null,
          color: isDark ? null : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      AppColors.darkPrimary,
                      AppColors.darkSecondary
                    ]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.campaign_outlined,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.eventName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          '${booking.eventType} • ${booking.exhibitionName}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.calendar_today_outlined, booking.date),
            const SizedBox(height: 4),
            _infoRow(Icons.location_on_outlined, booking.place),
            const SizedBox(height: 4),
            _infoRow(
                Icons.schedule_outlined, booking.selectedDurationLabel),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.darkPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat('الزوار', '${booking.totalVisitors}',
                      Icons.people_outline),
                  _stat('الحضور', '${booking.totalAttendees}',
                      Icons.how_to_reg_outlined),
                  _stat('المدة', '${booking.selectedDays} أيام',
                      Icons.timelapse_outlined),
                  _stat('السعر', '${booking.price.toStringAsFixed(0)} ﷼',
                      Icons.payments_outlined),
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
          Text(text,
              style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        ],
      );

  Widget _stat(String label, String value, IconData icon) => Column(
        children: [
          Icon(icon, size: 16, color: AppColors.darkPrimary),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.grey)),
        ],
      );
}
