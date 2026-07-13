import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';

class SponsorshipBottomSheet extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  const SponsorshipBottomSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EventsController>();
    ctrl.stepIndex.value = 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Obx(() {
          final step = ctrl.stepIndex.value;
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              _StepIndicator(currentStep: step),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (step == 0)
                      _StepDetails(event: event, ctrl: ctrl, isDark: isDark),
                    if (step == 1)
                      _StepBookingForm(
                        event: event,
                        ctrl: ctrl,
                        isDark: isDark,
                      ),
                  ],
                ),
              ),
              _BottomBar(
                step: step,
                ctrl: ctrl,
                event: event,
                isDark: isDark,
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Step 1: Event details ─────────────────────────────────────────────────
class _StepDetails extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  final EventsController ctrl;
  final bool isDark;
  const _StepDetails({
    required this.event,
    required this.ctrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          event.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        _detailRow(Icons.category_outlined, 'النوع', event.type),
        _detailRow(Icons.store_outlined, 'المعرض', event.exhibitionName),
        _detailRow(Icons.calendar_today_outlined, 'التاريخ', event.date),
        _detailRow(Icons.location_on_outlined, 'المكان', event.place),
        _detailRow(
          Icons.access_time_outlined,
          'الوقت',
          '${event.startTime} — ${event.endTime}',
        ),
        _detailRow(
          Icons.schedule_outlined,
          'مدة الإدراج',
          '${event.listingDays} أيام',
        ),
        const SizedBox(height: 16),
        const Text(
          'عن الفعالية',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          event.description,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.grey,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'خيارات المشاركة الإعلانية',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Column(
            children: event.durationOptions.map((opt) {
              final isSelected =
                  ctrl.selectedSponsorDuration.value == opt;
              return GestureDetector(
                onTap: () => ctrl.selectedSponsorDuration.value = opt,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              AppColors.darkPrimary,
                              AppColors.darkSecondary,
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.white : AppColors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color:
                                    isSelected ? Colors.white : null,
                              ),
                            ),
                            Text(
                              '${opt.days} ${opt.days == 1 ? 'يوم' : 'أيام'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white70
                                    : AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${opt.price.toStringAsFixed(0)} ﷼',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.darkPrimary),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}

// ── Step 2: Booking form ──────────────────────────────────────────────────
class _StepBookingForm extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  final EventsController ctrl;
  final bool isDark;
  const _StepBookingForm({
    required this.event,
    required this.ctrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // ── Auto-filled company info ──────────────────────
        _sectionTitle('معلومات الشركة (تُعبأ تلقائياً)'),
        _autoFilledField(
          isDark,
          'اسم الشركة',
          ctrl.companyNameCtrl.text,
          Icons.business_outlined,
        ),
        const SizedBox(height: 10),
        _autoFilledField(
          isDark,
          'الموقع الإلكتروني',
          ctrl.companyWebCtrl.text,
          Icons.language_outlined,
        ),
        const SizedBox(height: 10),
        _autoFilledField(
          isDark,
          'رقم التواصل',
          ctrl.companyPhoneCtrl.text,
          Icons.phone_outlined,
        ),
        const SizedBox(height: 24),

        // ── Advertising materials ─────────────────────────
        _sectionTitle('المواد الإعلانية'),
        const SizedBox(height: 4),

        // 1. Company logo
        _subLabel('شعار الشركة'),
        const SizedBox(height: 8),
        Obx(() {
          final bytes = ctrl.logoBytes;
          if (bytes != null) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    bytes,
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: ctrl.removeLogo,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return GestureDetector(
            onTap: ctrl.pickLogo,
            child: _uploadTile(
              isDark,
              Icons.image_outlined,
              'اضغط لرفع شعار الشركة',
            ),
          );
        }),
        const SizedBox(height: 18),

        // 2. Product names
        _subLabel('أبرز المنتجات / الخدمات'),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl.productNamesCtrl,
          maxLines: 3,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'مثال: منتج A, منتج B, خدمة C',
            hintStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
            prefixIcon: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.darkPrimary,
              size: 20,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.darkSurface
                : AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.darkPrimary.withOpacity(0.25),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.darkPrimary.withOpacity(0.25),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.darkPrimary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // 3. Ad images
        _subLabel('صور ومواد إعلانية (حتى 6 صور)'),
        const SizedBox(height: 8),
        Obx(() {
          final bytes = ctrl.adBytes;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bytes.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: bytes.asMap().entries.map((e) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            e.value,
                            width: 74,
                            height: 74,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: GestureDetector(
                            onTap: () => ctrl.removeAdFile(e.key),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: ctrl.pickAdImages,
                child: _uploadTile(
                  isDark,
                  Icons.collections_outlined,
                  bytes.isEmpty
                      ? 'اضغط لرفع صور ومواد إعلانية'
                      : 'إضافة المزيد من الصور',
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 18),

        // 4. Poster images
        _subLabel('ملصقات دعائية - بوسترات (حتى 4)'),
        const SizedBox(height: 8),
        Obx(() {
          final bytes = ctrl.posterBytes;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bytes.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: bytes.asMap().entries.map((e) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            e.value,
                            width: 74,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: GestureDetector(
                            onTap: () => ctrl.removePosterFile(e.key),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: ctrl.pickPosterImages,
                child: _uploadTile(
                  isDark,
                  Icons.campaign_outlined,
                  bytes.isEmpty
                      ? 'اضغط لرفع الملصقات الدعائية'
                      : 'إضافة المزيد من الملصقات',
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 24),

        // ── Booking summary ───────────────────────────────
        Obx(() {
          final dur = ctrl.selectedSponsorDuration.value;
          if (dur == null) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.darkPrimary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_outlined,
                  color: AppColors.darkPrimary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملخص الحجز',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkPrimary,
                        ),
                      ),
                      Text(
                        dur.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${dur.price.toStringAsFixed(0)} ﷼',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkPrimary,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      );

  Widget _subLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
        ),
      );

  Widget _autoFilledField(
    bool isDark,
    String label,
    String value,
    IconData icon,
  ) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.success),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.check_circle,
              size: 16,
              color: AppColors.success,
            ),
          ],
        ),
      );

  Widget _uploadTile(bool isDark, IconData icon, String label) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.darkPrimary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.darkPrimary.withOpacity(0.8),
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            const Spacer(),
            const Icon(
              Icons.add_circle_outline,
              color: AppColors.darkPrimary,
              size: 20,
            ),
          ],
        ),
      );
}

// ── Bottom action bar ─────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int step;
  final EventsController ctrl;
  final ExhibitionSponsorEvent event;
  final bool isDark;
  const _BottomBar({
    required this.step,
    required this.ctrl,
    required this.event,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (step > 0) ...[
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: () => ctrl.stepIndex.value--,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'السابق',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 3,
            child: Obx(
              () => ElevatedButton(
                onPressed: () {
                  if (ctrl.stepIndex.value == 0) {
                    if (ctrl.selectedSponsorDuration.value == null) {
                      Get.snackbar(
                        'تنبيه',
                        'يرجى اختيار مدة المشاركة',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.darkAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    ctrl.stepIndex.value = 1;
                  } else {
                    ctrl.bookSponsorship(event);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.darkPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: ctrl.isBooking.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        ctrl.stepIndex.value == 0
                            ? 'التالي: بيانات الشركة'
                            : 'إرسال طلب الرعاية',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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

// ── Step indicator ────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _dot(0, 'التفاصيل'),
            Expanded(
              child: Container(
                height: 2,
                color: currentStep >= 1
                    ? AppColors.darkPrimary
                    : AppColors.grey.withOpacity(0.3),
              ),
            ),
            _dot(1, 'بيانات الشركة'),
          ],
        ),
      );

  Widget _dot(int step, String label) {
    final active = currentStep >= step;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [AppColors.darkPrimary, AppColors.darkSecondary],
                  )
                : null,
            color: active ? null : AppColors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: active ? Colors.white : AppColors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: active ? AppColors.darkPrimary : AppColors.grey,
          ),
        ),
      ],
    );
  }
}
