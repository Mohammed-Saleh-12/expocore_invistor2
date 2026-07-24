import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/booking_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_nav_controller.dart';
import '../../models/web_theme.dart';

// ════════════════════════════════════════════════════════════
//  WebBookingRequestPage  —  طلب حجز جناح (نسخة الويب)
// ════════════════════════════════════════════════════════════
class WebBookingRequestPage extends StatelessWidget {
  const WebBookingRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backBar(),
              const SizedBox(height: 20),
              Text(
                'booking_page_title'.tr,
                style: TextStyle(
                  color: WebTheme.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'booking_request_hint'.tr,
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              _boothSummary(c),
              const SizedBox(height: 20),
              _durationSection(context, c),
              const SizedBox(height: 20),
              _servicesSection(c),
              const SizedBox(height: 20),
              _notesSection(c),
              const SizedBox(height: 20),
              _costSummary(c),
              const SizedBox(height: 24),
              _submitButton(c),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backBar() => GestureDetector(
    onTap: WebNavController.to.closeDetail,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: WebTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WebTheme.border),
          ),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: WebTheme.text,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'btn_back'.tr,
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ),
      ],
    ),
  );

  Widget _boothSummary(BookingController c) => Obx(() {
    final booth = c.booth.value;
    if (booth == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.favoriteGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جناح ${booth.number}',
                  style: TextStyle(
                    color: WebTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  booth.exhibitionName,
                  style: const TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${booth.price.toInt()} ريال',
                style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'full_exhibition_duration'.tr,
                style: const TextStyle(color: AppColors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  });

  Widget _durationSection(
    BuildContext context,
    BookingController c,
  ) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: WebTheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: WebTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.favoriteGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.date_range_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'booking_dates_label'.tr,
              style: TextStyle(
                color: WebTheme.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _webDatePickerBox(context, c, isStart: true)),
            const SizedBox(width: 14),
            Expanded(child: _webDatePickerBox(context, c, isStart: false)),
          ],
        ),
        Obx(() {
          if (c.startDate.value.isEmpty || c.endDate.value.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: WebTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: WebTheme.primary.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: WebTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${'booking_duration_days'.tr}: ${c.duration.value}',
                    style: TextStyle(
                      fontSize: 13,
                      color: WebTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  );

  Widget _webDatePickerBox(
    BuildContext context,
    BookingController c, {
    required bool isStart,
  }) => Obx(() {
    final val = isStart ? c.startDate.value : c.endDate.value;
    final label = isStart ? 'booking_start_date'.tr : 'booking_end_date'.tr;
    final icon = isStart
        ? Icons.calendar_today_outlined
        : Icons.event_available_outlined;
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: now,
          lastDate: DateTime(now.year + 2, 12, 31),
        );
        if (picked != null) {
          if (isStart)
            c.setStartDate(picked);
          else
            c.setEndDate(picked);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: val.isNotEmpty
              ? WebTheme.primary.withOpacity(0.07)
              : WebTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: val.isNotEmpty ? WebTheme.primary : WebTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: val.isNotEmpty ? WebTheme.primary : AppColors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (val.isEmpty)
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    )
                  else
                    Text(
                      val.isEmpty ? '' : val,
                      style: TextStyle(
                        color: val.isEmpty ? AppColors.grey : WebTheme.text,
                        fontSize: 13,
                        fontWeight: val.isEmpty
                            ? FontWeight.w400
                            : FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  });

  Widget _servicesSection(BookingController c) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: WebTheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: WebTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.favoriteGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.room_service_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'booking_services_label'.tr,
              style: TextStyle(
                color: WebTheme.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          final services = c.booth.value?.services ?? {};
          if (services.isEmpty) {
            return Text(
              'لا توجد خدمات إضافية متاحة',
              style: TextStyle(color: AppColors.grey, fontSize: 13),
            );
          }
          final entries = services.entries.toList();
          return LayoutBuilder(
            builder: (_, cons) {
              final isWide = cons.maxWidth > 500;
              if (isWide) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: entries
                      .map(
                        (e) => SizedBox(
                          width: (cons.maxWidth - 12) / 2,
                          child: _serviceToggle(c, e.key, e.value),
                        ),
                      )
                      .toList(),
                );
              }
              return Column(
                children: entries
                    .map((e) => _serviceToggle(c, e.key, e.value))
                    .toList(),
              );
            },
          );
        }),
      ],
    ),
  );

  Widget _serviceToggle(
    BookingController c,
    String serviceName,
    double price,
  ) => Obx(
    () {
      final selected = c.serviceSelections[serviceName] == true;
      return GestureDetector(
        onTap: () => c.toggleService(serviceName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? WebTheme.primary.withOpacity(0.12)
                : WebTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? WebTheme.primary : WebTheme.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.room_service_outlined,
                size: 20,
                color: selected ? WebTheme.primary : AppColors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  serviceName,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? WebTheme.text : AppColors.grey,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '${price.toInt()} ر.س',
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? AppColors.orange : AppColors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.favoriteGradient : null,
                  color: selected ? null : WebTheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : AppColors.grey.withOpacity(0.4),
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 13,
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _notesSection(BookingController c) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: WebTheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: WebTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.favoriteGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.note_alt_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'booking_notes_label'.tr,
              style: TextStyle(
                color: WebTheme.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: c.notesCtrl,
          maxLines: 4,
          style: TextStyle(fontSize: 13, color: WebTheme.text),
          decoration: InputDecoration(
            hintText: 'booking_notes_hint'.tr,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.grey),
            filled: true,
            fillColor: WebTheme.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: WebTheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    ),
  );

  Widget _costSummary(BookingController c) => Obx(() {
    final booth = c.booth.value;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'booking_cost_summary'.tr,
            style: TextStyle(
              color: WebTheme.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Divider(color: WebTheme.border, height: 20),
          _costRow(
            'booking_base_rent'.tr,
            '${((booth?.price ?? 0) * c.duration.value).toInt()} ر.س',
          ),
          ...c.serviceSelections.entries
              .where((e) => e.value)
              .map((e) {
                final price = c.booth.value?.services[e.key] ?? 0;
                return _costRow(e.key, '${price.toInt()} ر.س');
              }),
          Divider(color: WebTheme.border, height: 20),
          Row(
            children: [
              Text(
                'total_cost'.tr,
                style: TextStyle(
                  color: WebTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${c.total.toInt()} ر.س',
                style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  });

  Widget _costRow(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.grey),
        ),
        const Spacer(),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            color: WebTheme.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _submitButton(BookingController c) => Obx(
    () => GestureDetector(
      onTap: c.isSubmitting.value ? null : c.submitBooking,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: c.isSubmitting.value ? null : AppColors.favoriteGradient,
          color: c.isSubmitting.value ? AppColors.grey.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: c.isSubmitting.value
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'booking_submit'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ),
  );
}
