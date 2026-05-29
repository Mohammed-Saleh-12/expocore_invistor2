import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/events_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../data/model/event/sponsorship_booking_model.dart';

class MySponsorshipDetailView extends StatelessWidget {
  const MySponsorshipDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = Get.arguments as SponsorshipBookingModel;
    final ctrl = Get.find<EventsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = ctrl.statusColor(booking.status);
    final statusLabel = ctrl.statusLabel(booking.status);
    final remaining = (booking.totalDays - booking.currentDay)
        .clamp(0, booking.totalDays);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBg : AppColors.lightBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.darkPrimary,
                          AppColors.darkSecondary
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const Icon(Icons.campaign_outlined,
                            color: Colors.white, size: 48),
                        const SizedBox(height: 8),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            booking.eventName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & days progress
                  _statusProgressCard(
                      context, isDark, booking, statusColor,
                      statusLabel, remaining),
                  const SizedBox(height: 16),
                  // Event details
                  _card(
                    isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('تفاصيل الفعالية'),
                        _detailRow(Icons.category_outlined, 'النوع',
                            booking.eventType),
                        _detailRow(Icons.store_outlined, 'المعرض',
                            booking.exhibitionName),
                        _detailRow(Icons.calendar_today_outlined,
                            'التاريخ', booking.date),
                        _detailRow(Icons.access_time_outlined, 'الوقت',
                            booking.time),
                        _detailRow(Icons.location_on_outlined, 'المكان',
                            booking.place),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Booking details
                  _card(
                    isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('تفاصيل الحجز'),
                        _detailRow(Icons.schedule_outlined, 'المدة',
                            booking.selectedDurationLabel),
                        _detailRow(Icons.payments_outlined, 'السعر',
                            '${booking.price.toStringAsFixed(0)} ﷼'),
                        _detailRow(Icons.event_available_outlined,
                            'تاريخ الحجز', booking.bookedAt),
                        _detailRow(Icons.verified_outlined, 'الحالة',
                            statusLabel),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Analytics
                  _card(
                    isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('تحليلات الأداء'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _analyticsTile(context, 'إجمالي الزوار',
                                '${booking.totalVisitors}',
                                Icons.people_outline, AppColors.darkPrimary),
                            const SizedBox(width: 12),
                            _analyticsTile(context, 'الحضور الفعلي',
                                '${booking.totalAttendees}',
                                Icons.how_to_reg_outlined, AppColors.success),
                          ],
                        ),
                        if (booking.dailyVisitors.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _sectionTitle('الزوار اليوميون'),
                          const SizedBox(height: 8),
                          ...List.generate(
                              booking.dailyVisitors.length,
                              (i) => _dailyVisitorRow(
                                  context,
                                  i + 1,
                                  booking.dailyVisitors[i],
                                  booking.dailyVisitors.fold(
                                          0, (a, b) => a > b ? a : b))),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusProgressCard(
      BuildContext context,
      bool isDark,
      SponsorshipBookingModel booking,
      Color statusColor,
      String statusLabel,
      int remaining) {
    final progress = booking.totalDays > 0
        ? booking.currentDay / booking.totalDays
        : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              Text('اليوم ${booking.currentDay} من ${booking.totalDays}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.darkSurface,
              valueColor:
                  AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            remaining > 0
                ? 'متبقي $remaining ${remaining == 1 ? 'يوم' : 'أيام'} على انتهاء الفعالية'
                : 'انتهت الفعالية',
            style: TextStyle(
                fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

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
                offset: const Offset(0, 3))
          ],
        ),
        child: child,
      );

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700)),
      );

  Widget _detailRow(IconData icon, String label, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.darkPrimary),
            const SizedBox(width: 8),
            Text('$label: ',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.grey),
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
      );

  Widget _analyticsTile(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _dailyVisitorRow(BuildContext context, int day, int count,
      int maxCount) {
    final ratio = maxCount > 0 ? count / maxCount : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 50,
              child: Text('اليوم $day',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grey))),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                backgroundColor: AppColors.darkSurface,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.darkPrimary),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
