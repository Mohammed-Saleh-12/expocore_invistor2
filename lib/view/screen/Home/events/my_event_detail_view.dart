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
    final remaining =
        (event.totalEventDays - event.currentDay).clamp(0, event.totalEventDays);
    final seatsRemaining =
        (event.totalSeats - event.bookedSeats).clamp(0, event.totalSeats);
    final fillRate = event.totalSeats > 0
        ? event.bookedSeats / event.totalSeats
        : 0.0;
    final pendingCount = ctrl.pendingRequestsCount(event.id);

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              if (event.hasBookableSeats && pendingCount > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.confirmation_num_outlined,
                            color: Colors.white),
                        onPressed: () => Get.toNamed(
                          AppRoutes.TICKET_REQUESTS,
                          arguments: event,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                              color: AppColors.darkSecondary,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text('$pendingCount',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1D1A39),
                      AppColors.darkPrimary,
                    ],
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
                        child: Icon(_typeIcon(event.type),
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          event.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.type,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
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
                  _card(isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('تفاصيل الفعالية'),
                          _detailRow(Icons.location_on_outlined, 'الموقع',
                              event.place.isNotEmpty
                                  ? event.place
                                  : 'جناح ${event.boothNumber}'),
                          _detailRow(Icons.store_outlined, 'المعرض',
                              event.exhibitionName),
                          _detailRow(Icons.calendar_today_outlined,
                              'التاريخ', event.date),
                          _detailRow(Icons.access_time_outlined, 'الوقت',
                              event.time),
                          _detailRow(Icons.timelapse_outlined, 'المدة',
                              '${event.durationDays} ${event.durationDays == 1 ? 'يوم' : 'أيام'}'),
                          if (event.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Text(event.description,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.grey,
                                    height: 1.7)),
                          ],
                        ],
                      )),
                  const SizedBox(height: 14),

                  // Seats / Tickets section
                  if (event.hasBookableSeats) ...[
                    _card(isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _sectionTitle('إدارة التذاكر'),
                                const Spacer(),
                                // QR Scanner button
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showQrScannerDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkPrimary,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.qr_code_scanner,
                                      color: Colors.white, size: 16),
                                  label: const Text('مسح QR',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _ticketStat(context, 'إجمالي المقاعد',
                                    '${event.totalSeats}',
                                    AppColors.info),
                                const SizedBox(width: 10),
                                _ticketStat(context, 'المحجوزة',
                                    '${event.bookedSeats}',
                                    AppColors.info),
                                const SizedBox(width: 10),
                                _ticketStat(context, 'المتبقية',
                                    '$seatsRemaining',
                                    AppColors.success),
                                const SizedBox(width: 10),
                                _ticketStat(context, 'حضروا',
                                    '${event.scannedCount}',
                                    AppColors.success),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Fill rate bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('نسبة الإشغال',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.grey)),
                                    Text(
                                        '${(fillRate * 100).toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700)),
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
                                            AppColors.darkPrimary),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Ticket price
                            if (event.ticketPrice > 0)
                              _detailRow(Icons.payments_outlined,
                                  'سعر التذكرة',
                                  '${event.ticketPrice.toStringAsFixed(0)} ﷼'),
                            if (event.ticketPrice == 0)
                              _detailRow(Icons.card_giftcard_outlined,
                                  'نوع الدخول', 'دعوة عامة مجانية'),
                            const SizedBox(height: 12),
                            // Manage ticket requests button
                            SizedBox(
                              width: double.infinity,
                              child: Obx(() {
                                final pending =
                                    ctrl.pendingRequestsCount(event.id);
                                return OutlinedButton.icon(
                                  onPressed: () => Get.toNamed(
                                    AppRoutes.TICKET_REQUESTS,
                                    arguments: event,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    side: const BorderSide(
                                        color: AppColors.darkPrimary),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(
                                      Icons.confirmation_num_outlined,
                                      color: AppColors.darkPrimary,
                                      size: 18),
                                  label: Text(
                                    pending > 0
                                        ? 'إدارة طلبات التذاكر ($pending طلب معلّق)'
                                        : 'إدارة طلبات التذاكر',
                                    style: const TextStyle(
                                        color: AppColors.darkPrimary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                );
                              }),
                            ),
                          ],
                        )),
                    const SizedBox(height: 14),
                  ] else ...[
                    // General event info (no bookable seats)
                    _card(isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('معلومات التسجيل'),
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
                                      size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    event.isGeneralInvitation
                                        ? 'دعوة عامة — دخول حر للجميع'
                                        : 'تسجيل في الموقع',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.darkPrimary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            _detailRow(Icons.people_outline,
                                'المشاركون',
                                '${event.registeredCount} / ${event.maxParticipants}'),
                          ],
                        )),
                    const SizedBox(height: 14),
                  ],

                  // Analytics (only if event has started / has data)
                  if (event.dailyAttendees.isNotEmpty &&
                      event.dailyAttendees.any((v) => v > 0)) ...[
                    _card(isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('تحليلات الفعالية'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _analyticsTile(context, 'إجمالي الحضور',
                                    '${event.dailyAttendees.fold(0, (a, b) => a + b)}',
                                    Icons.people_outline,
                                    AppColors.darkPrimary),
                                const SizedBox(width: 12),
                                _analyticsTile(
                                    context,
                                    'مسحوا التذكرة',
                                    '${event.scannedCount}',
                                    Icons.qr_code_scanner,
                                    AppColors.darkSecondary),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _sectionTitle('الحضور اليومي'),
                            ...List.generate(
                                event.dailyAttendees.length,
                                (i) => _dailyBar(
                                    context,
                                    i + 1,
                                    event.dailyAttendees[i],
                                    event.dailyAttendees.fold(
                                        0, (a, b) => a > b ? a : b))),
                            if (event.hasBookableSeats) ...[
                              const SizedBox(height: 14),
                              const Divider(height: 1),
                              const SizedBox(height: 14),
                              _sectionTitle('مقارنة التذاكر'),
                              _comparisonBar(
                                  context,
                                  'التذاكر المباعة',
                                  event.soldTickets,
                                  event.totalSeats,
                                  AppColors.darkPrimary),
                              const SizedBox(height: 8),
                              _comparisonBar(
                                  context,
                                  'الحضور الفعلي',
                                  event.scannedCount,
                                  event.totalSeats,
                                  AppColors.darkSecondary),
                            ],
                          ],
                        )),
                    const SizedBox(height: 24),
                  ] else
                    const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.darkPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.qr_code_scanner,
                  color: AppColors.darkPrimary, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('ماسح QR التذاكر',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'سيتم ربط هذه الميزة بكاميرا الجهاز عند الاتصال بالباكند.\nيتم التحقق من صحة التذكرة عبر الكود المرسل.',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey,
                  height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('حسناً',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'ورشة عمل': return Icons.school_outlined;
      case 'عرض مباشر': return Icons.live_tv_outlined;
      case 'مسابقة': return Icons.emoji_events_outlined;
      case 'لقاء B2B': return Icons.handshake_outlined;
      case 'ندوة': return Icons.record_voice_over_outlined;
      case 'حفل': return Icons.celebration_outlined;
      case 'مقابلة': return Icons.mic_outlined;
      case 'مؤتمر': return Icons.groups_outlined;
      default: return Icons.event_outlined;
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
    final label = ended ? 'انتهت' : started ? 'جارٍ الآن' : 'قادمة';
    final progress = event.totalEventDays > 0
        ? event.currentDay / event.totalEventDays
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05)
          ],
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
                    fontSize: 13, fontWeight: FontWeight.w600),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
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
                offset: const Offset(0, 3))
          ],
        ),
        child: child,
      );

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
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

  Widget _ticketStat(
      BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

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

  Widget _dailyBar(
      BuildContext context, int day, int count, int maxCount) {
    final ratio = maxCount > 0 ? count / maxCount : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 50,
              child: Text('يوم $day',
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
            width: 36,
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  Widget _comparisonBar(BuildContext context, String label, int value,
      int total, Color color) {
    final ratio = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.grey)),
            Text('$value / $total',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            backgroundColor: AppColors.darkSurface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
