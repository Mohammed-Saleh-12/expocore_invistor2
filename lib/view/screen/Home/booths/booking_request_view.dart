import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/booking_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../data/model/booth/booth_model.dart';
import '../../../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';
import '../../../widget/Home/custom_text_field.dart';

class BookingRequestView extends GetView<BookingController> {
  const BookingRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final booth = Get.arguments as BoothModel? ?? DummyData.myBooths.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    controller.setBooth(booth);
    return Scaffold(
      appBar: CustomAppBar(title: 'booking_request_title'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _boothSummary(context, booth),
            const SizedBox(height: 20),
            _bookingModeSection(context, isDark, booth),
            const SizedBox(height: 20),
            _dynamicServicesSection(context, isDark),
            const SizedBox(height: 20),
            Text('booking_notes_label'.tr,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            AppTextField(
              controller: controller.notesCtrl,
              maxLines: 3,
              label: 'booking_notes_hint'.tr,
            ),
            const SizedBox(height: 20),
            _costSummary(context),
            const SizedBox(height: 24),
            Obx(() => CustomButton(
                  label: 'booking_submit_btn'.tr,
                  onTap: controller.submitBooking,
                  isLoading: controller.isSubmitting.value,
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── ملخص الجناح ──────────────────────────────────────────────
  Widget _boothSummary(BuildContext context, BoothModel booth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.favoriteGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.grid_view, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'event_booth_prefix'.tr} ${booth.number}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(booth.exhibitionName,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              Text('${booth.price.toInt()} ${'booking_per_exhibition'.tr}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.orange, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // ── قسم وضع الحجز (كامل / أيام محددة) ───────────────────────
  Widget _bookingModeSection(BuildContext context, bool isDark, BoothModel booth) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkPrimary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.date_range_outlined, size: 18, color: AppColors.darkPrimary),
            const SizedBox(width: 8),
            Text('booking_dates_label'.tr,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ]),
          // فترة الإتاحة
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.darkPrimary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 14, color: AppColors.darkPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'فترة الإتاحة: ${booth.startDate} → ${booth.endDate}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.darkPrimary,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          // مُبدِّل الوضع
         Row(children: [
                _modeChip(isDark, 'full',   Icons.calendar_month_outlined, 'حجز بالكامل'),
                const SizedBox(width: 10),
                _modeChip(isDark, 'custom', Icons.tune_rounded,             'أيام محددة'),
              ]),
          const SizedBox(height: 14),
          // المحتوى حسب الوضع
          Obx(() => controller.bookingMode.value == 'full'
              ? _fullPeriodInfo(isDark, booth)
              : _customDaysGrid(isDark, booth)),
        ],
      ),
    );
  }

  Widget _modeChip(bool isDark, String mode, IconData icon, String label) {
    return Obx(() {
      final sel = controller.bookingMode.value == mode;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.setBookingMode(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              gradient: sel ? AppColors.favoriteGradient : null,
              color: sel ? null : (isDark ? AppColors.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel ? Colors.transparent : AppColors.darkPrimary.withOpacity(0.3),
              ),
              boxShadow: sel
                  ? [BoxShadow(
                      color: AppColors.darkPrimary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3))]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: sel ? Colors.white : AppColors.darkPrimary),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : null,
                    )),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── وضع الحجز الكامل ─────────────────────────────────────────
  Widget _fullPeriodInfo(bool isDark, BoothModel booth) {
    return Row(children: [
      Expanded(child: _dateInfoBox(isDark,
          label: 'تاريخ البداية', value: booth.startDate,
          icon: Icons.calendar_today_outlined)),
      const SizedBox(width: 12),
      Expanded(child: _dateInfoBox(isDark,
          label: 'تاريخ النهاية', value: booth.endDate,
          icon: Icons.event_available_outlined)),
    ]);
  }

  Widget _dateInfoBox(bool isDark,
      {required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkPrimary.withOpacity(0.35)),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.darkPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 10, color: AppColors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: AppColors.darkPrimary)),
            ],
          ),
        ),
      ]),
    );
  }

  // ── وضع الأيام المحددة (شبكة أيام متتالية) ───────────────────
  Widget _customDaysGrid(bool isDark, BoothModel booth) {
    final days = controller.availableDays;
    if (days.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('لا توجد أيام متاحة لهذا الجناح',
            style: TextStyle(fontSize: 13, color: AppColors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // تعليمات
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.darkSecondary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(children: [
            Icon(Icons.touch_app_outlined, size: 13, color: AppColors.darkSecondary),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'اختر يوم البداية ثم يوم النهاية — يجب أن تكون الأيام متتالية',
                style: TextStyle(fontSize: 11, color: AppColors.darkSecondary),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        // شبكة الأيام
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days.map((day) => Obx(() {
            final isStart  = controller.isDayRangeStart(day);
            final isEnd    = controller.isDayRangeEnd(day);
            final inRange  = controller.isDayInRange(day);
            final dayLabel = '${day.day}/${day.month}';
            final weekDay  = _weekDayAr(day.weekday);

            Color bg;
            Color textColor;
            Border border;

            if (isStart || isEnd) {
              bg        = AppColors.darkPrimary;
              textColor = Colors.white;
              border    = Border.all(color: Colors.transparent);
            } else if (inRange) {
              bg        = AppColors.darkPrimary.withOpacity(0.15);
              textColor = AppColors.darkPrimary;
              border    = Border.all(color: AppColors.darkPrimary.withOpacity(0.4));
            } else {
              bg        = isDark ? AppColors.darkCard : Colors.white;
              textColor = isDark ? Colors.white70 : Colors.black87;
              border    = Border.all(color: AppColors.grey.withOpacity(0.3));
            }

            return GestureDetector(
              onTap: () => controller.tapDay(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                  border: border,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(weekDay,
                        style: TextStyle(
                            fontSize: 9,
                            color: inRange || isStart || isEnd
                                ? textColor.withOpacity(0.8)
                                : AppColors.grey)),
                    const SizedBox(height: 2),
                    Text(dayLabel,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textColor)),
                  ],
                ),
              ),
            );
          })).toList(),
        ),
        const SizedBox(height: 12),
        // ملخص النطاق المحدد
        Obx(() {
          final sDate = controller.effectiveStartDate;
          final eDate = controller.effectiveEndDate;
          if (sDate.isEmpty) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.darkPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_outline,
                  size: 14, color: AppColors.darkPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  eDate.isEmpty || eDate == sDate
                      ? 'تم اختيار: $sDate (يوم واحد)'
                      : 'من: $sDate → إلى: $eDate  (${controller.effectiveDuration} أيام)',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.darkPrimary,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          );
        }),
      ],
    );
  }

  String _weekDayAr(int weekday) {
    const days = ['', 'الإثنين', 'الثلاثاء', 'الأربعاء',
                  'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return weekday >= 1 && weekday <= 7 ? days[weekday] : '';
  }

  // ── خدمات ديناميكية ─────────────────────────────────────────
  Widget _dynamicServicesSection(BuildContext context, bool isDark) {
    return Obx(() {
      final booth    = controller.booth.value;
      final services = booth?.services ?? {};
      if (services.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('booking_extra_services'.tr,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...services.entries.map((entry) => Obx(() {
                final selected = controller.serviceSelections[entry.key] ?? false;
                return GestureDetector(
                  onTap: () => controller.toggleService(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.darkPrimary.withOpacity(0.1)
                          : (isDark ? AppColors.darkCard : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.darkPrimary
                            : AppColors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(children: [
                      Icon(Icons.room_service_rounded,
                          size: 20,
                          color: selected ? AppColors.darkPrimary : AppColors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected
                                ? (isDark ? Colors.white : Colors.black87)
                                : AppColors.grey,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value.toInt()} ريال',
                        style: TextStyle(
                          fontSize: 12,
                          color: selected ? AppColors.orange : AppColors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          gradient: selected ? AppColors.favoriteGradient : null,
                          color: selected ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : AppColors.grey.withOpacity(0.4),
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 13)
                            : null,
                      ),
                    ]),
                  ),
                );
              })),
        ],
      );
    });
  }

  // ── ملخص التكلفة ─────────────────────────────────────────────
  Widget _costSummary(BuildContext context) => Obx(() {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final booth  = controller.booth.value;
        final svc    = booth?.services ?? {};
        final dur    = controller.effectiveDuration;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.darkCardGradient : null,
            color: isDark ? null : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('booking_cost_summary'.tr,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const Divider(height: 16),
              _costRow(
                'booking_base_rent'.tr,
                '${((booth?.price ?? 0) * dur).toInt()} ريال',
              ),
              ...svc.entries.where((e) =>
                  controller.serviceSelections[e.key] ?? false).map((e) =>
                  _costRow(e.key, '${e.value.toInt()} ريال')),
              const Divider(height: 16),
              Row(children: [
                Text('booking_total'.tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${controller.total.toInt()} ريال',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.orange)),
              ]),
            ],
          ),
        );
      });

  Widget _costRow(String label, String val) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
          const Spacer(),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      );
}
