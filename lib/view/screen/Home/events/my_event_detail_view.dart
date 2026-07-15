import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/events_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../../data/model/event/event_model.dart';

class MyEventDetailView extends StatelessWidget {
  const MyEventDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final event = Get.arguments as EventModel;
    final ctrl = Get.find<EventsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = (event.totalEventDays - event.currentDay).clamp(
      0,
      event.totalEventDays,
    );
    final seatsRemaining = (event.totalSeats - event.bookedSeats).clamp(
      0,
      event.totalSeats,
    );
    final fillRate = event.totalSeats > 0
        ? event.bookedSeats / event.totalSeats
        : 0.0;
    final tc = event.ticketCategory; // 'paid' | 'free' | 'none'

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        slivers: [
          // Hero app bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1D1A39), AppColors.darkPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _typeIcon(event.type),
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          event.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & timeline
                  _statusCard(isDark, event, remaining),
                  const SizedBox(height: 14),
                  // Event details
                  _card(
                    isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('event_section_details'.tr),
                        _detailRow(
                          Icons.location_on_outlined,
                          'الموقع',
                          event.place.isNotEmpty
                              ? event.place
                              : 'جناح ${event.boothNumber}',
                        ),
                        _detailRow(
                          Icons.store_outlined,
                          'المعرض',
                          event.exhibitionName,
                        ),
                        _detailRow(
                          Icons.calendar_today_outlined,
                          'التاريخ',
                          event.date,
                        ),
                        _detailRow(
                          Icons.access_time_outlined,
                          'الوقت',
                          event.time,
                        ),
                        _detailRow(
                          Icons.timelapse_outlined,
                          'المدة',
                          '${event.durationDays} ${event.durationDays == 1 ? 'يوم' : 'أيام'}',
                        ),
                        if (event.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          Text(
                            event.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Seats / Tickets section ───────────────────
                  // paid + free → show seat stats & fill-rate bar
                  // paid only  → show ticket price & requests button
                  // none       → show general registration info only
                  if (tc != 'none') ...[
                    _card(
                      isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('ticket_management'.tr),
                          const SizedBox(height: 10),
                          // Seat stats — visible for both paid and free
                          Row(
                            children: [
                              _ticketStat(
                                context,
                                'total_seats'.tr,
                                '${event.totalSeats}',
                                AppColors.info,
                              ),
                              const SizedBox(width: 10),
                              _ticketStat(
                                context,
                                'booked_seats'.tr,
                                '${event.bookedSeats}',
                                AppColors.info,
                              ),
                              const SizedBox(width: 10),
                              _ticketStat(
                                context,
                                'remaining_seats'.tr,
                                '$seatsRemaining',
                                AppColors.success,
                              ),
                              const SizedBox(width: 10),
                              _ticketStat(
                                context,
                                'attended'.tr,
                                '${event.scannedCount}',
                                AppColors.success,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Fill-rate bar — visible for both paid and free
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'occupancy_rate'.tr,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${(fillRate * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: fillRate.clamp(0.0, 1.0),
                                  backgroundColor: AppColors.darkSurface,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.darkPrimary,
                                      ),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Paid: show price — Free: show free-entry label
                          if (tc == 'paid')
                            _detailRow(
                              Icons.payments_outlined,
                              'event_ticket_price_hint'.tr,
                              '${event.ticketPrice.toStringAsFixed(0)} ﷼',
                            )
                          else
                            _detailRow(
                              Icons.card_giftcard_outlined,
                              'entry_type'.tr,
                              'free_general_invite'.tr,
                            ),
                          // Requests button — paid events only
                          if (tc == 'paid') ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: Obx(() {
                                final pending = ctrl.pendingRequestsCount(
                                  event.id,
                                );
                                return OutlinedButton.icon(
                                  onPressed: () => Get.toNamed(
                                    AppRoutes.TICKET_REQUESTS,
                                    arguments: event,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.darkPrimary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.confirmation_num_outlined,
                                    color: AppColors.darkPrimary,
                                    size: 18,
                                  ),
                                  label: Text(
                                    pending > 0
                                        ? '${'ticket_management'.tr} ($pending)'
                                        : 'ticket_management'.tr,
                                    style: const TextStyle(
                                      color: AppColors.darkPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    // General event — no ticket UI at all
                    _card(
                      isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('registration_info'.tr),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.darkPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  color: AppColors.darkPrimary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  event.isGeneralInvitation
                                      ? 'general_invite_desc'.tr
                                      : 'onsite_registration'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.darkPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _detailRow(
                            Icons.people_outline,
                            'participants'.tr,
                            '${event.registeredCount} / ${event.maxParticipants}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'ورشة عمل':
        return Icons.school_outlined;
      case 'عرض مباشر':
        return Icons.live_tv_outlined;
      case 'مسابقة':
        return Icons.emoji_events_outlined;
      case 'لقاء B2B':
        return Icons.handshake_outlined;
      case 'ندوة':
        return Icons.record_voice_over_outlined;
      case 'حفل':
        return Icons.celebration_outlined;
      case 'مقابلة':
        return Icons.mic_outlined;
      case 'مؤتمر':
        return Icons.groups_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  Widget _statusCard(bool isDark, EventModel event, int remaining) {
    final started = event.currentDay > 0;
    final ended = remaining == 0 && started;
    final color = ended
        ? AppColors.grey
        : started
        ? AppColors.darkSecondary
        : AppColors.darkPrimary;
    final label = ended
        ? 'status_ended_f'.tr
        : started
        ? 'status_ongoing'.tr
        : 'status_upcoming_f'.tr;
    final progress = event.totalEventDays > 0
        ? event.currentDay / event.totalEventDays
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statusBadge(label, color),
              const Spacer(),
              Text(
                started
                    ? 'اليوم ${event.currentDay} من ${event.totalEventDays}'
                    : 'لم تبدأ بعد',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.darkSurface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            !started
                ? 'الفعالية لم تبدأ بعد'
                : remaining > 0
                ? 'متبقي $remaining ${remaining == 1 ? 'يوم' : 'أيام'}'
                : 'انتهت الفعالية',
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _card(bool isDark, {required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: isDark ? AppColors.darkCardGradient : null,
      color: isDark ? null : AppColors.lightCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  );

  Widget _detailRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.darkPrimary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _ticketStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
