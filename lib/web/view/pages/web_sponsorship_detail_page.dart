import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/sponsorship_booking_model.dart';
import '../../controllers/web_nav_controller.dart';

// ════════════════════════════════════════════════════════════
//  WebSponsorshipDetailPage  —  تفاصيل الرعاية (مطابقة للتطبيق)
// ════════════════════════════════════════════════════════════
class WebSponsorshipDetailPage extends StatelessWidget {
  final SponsorshipBookingModel booking;
  const WebSponsorshipDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _back(),
              const SizedBox(height: 20),

              // ── Header banner ────────────────────────────
              _banner(),
              const SizedBox(height: 16),

              // ── Status progress ──────────────────────────
              _statusProgress(),
              const SizedBox(height: 16),

              // ── تفاصيل الفعالية ──────────────────────────
              _card('تفاصيل الفعالية', [
                _row(Icons.category_outlined, 'النوع', booking.eventType),
                _row(Icons.storefront_rounded, 'المعرض', booking.exhibitionName),
                _row(Icons.calendar_today_outlined, 'التاريخ', booking.date),
                _row(Icons.access_time_rounded, 'الوقت', booking.time),
                _row(Icons.location_on_outlined, 'المكان', booking.place),
              ]),
              const SizedBox(height: 16),

              // ── تفاصيل الحجز ─────────────────────────────
              _card('تفاصيل الحجز', [
                _row(Icons.timelapse_rounded, 'المدة', booking.selectedDurationLabel),
                _row(Icons.payments_outlined, 'السعر', '${booking.price.toInt()} ر.س'),
                _row(Icons.event_available_outlined, 'تاريخ الحجز', booking.bookedAt),
                _row(Icons.verified_outlined, 'الحالة', booking.statusLabel),
              ]),
              const SizedBox(height: 16),

              // ── تحليلات الأداء ───────────────────────────
              _card('تحليلات الأداء', [
                Row(
                  children: [
                    _statTile('الحضور الفعلي', '${booking.totalAttendees}', Icons.how_to_reg_outlined, AppColors.darkSecondary),
                    const SizedBox(width: 14),
                    _statTile('إجمالي الزوار', '${booking.totalVisitors}', Icons.groups_outlined, AppColors.darkPrimary),
                  ],
                ),
                const SizedBox(height: 20),
                _dailyVisitors(),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────
  Widget _banner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7A1FFF), Color(0xFFFF1592)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.campaign_rounded, color: WebTheme.text, size: 44),
            const SizedBox(height: 14),
            Text(booking.eventName,
                textAlign: TextAlign.center,
                style: TextStyle(color: WebTheme.text, fontSize: 22, fontWeight: FontWeight.w900)),
          ],
        ),
      );

  // ── Status progress ───────────────────────────────────────
  Widget _statusProgress() {
    final total = booking.totalDays <= 0 ? 1 : booking.totalDays;
    final progress = (booking.currentDay / total).clamp(0.0, 1.0);
    final remaining = (total - booking.currentDay).clamp(0, total);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('اليوم ${booking.currentDay} من ${booking.totalDays}',
                  style: TextStyle(color: WebTheme.text, fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withOpacity(0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 7, height: 7, decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(booking.statusLabel, style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.darkBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          const SizedBox(height: 10),
          Text('متبقي $remaining يوم على انتهاء الفعالية',
              style: TextStyle(color: AppColors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  // ── Daily visitors ────────────────────────────────────────
  Widget _dailyVisitors() {
    final data = booking.dailyVisitors;
    if (data.isEmpty) return const SizedBox.shrink();
    final maxV = data.reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الزوار اليوميون',
            style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        ...List.generate(data.length, (i) {
          final ratio = maxV == 0 ? 0.0 : data[i] / maxV;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(width: 48, child: Text('${data[i]}', style: TextStyle(color: AppColors.grey, fontSize: 12))),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 12,
                      backgroundColor: AppColors.darkBg,
                      valueColor: const AlwaysStoppedAnimation(AppColors.darkPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('اليوم ${i + 1}', style: TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Pieces ────────────────────────────────────────────────
  Widget _back() => GestureDetector(
        onTap: WebNavController.to.closeDetail,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: WebTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: WebTheme.border)),
            child: Icon(Icons.arrow_forward_rounded, color: WebTheme.text, size: 20),
          ),
          const SizedBox(width: 10),
          Text('رجوع', style: TextStyle(color: AppColors.grey, fontSize: 14)),
        ]),
      );

  Widget _card(String title, List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: WebTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: WebTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: WebTheme.text, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      );

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, size: 19, color: AppColors.darkPrimary),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: AppColors.grey, fontSize: 14)),
          Expanded(child: Text(value, style: TextStyle(color: WebTheme.text, fontSize: 14, fontWeight: FontWeight.w600))),
        ]),
      );

  Widget _statTile(String label, String value, IconData icon, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 10),
              Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
        ),
      );

}
