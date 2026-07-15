import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../controllers/web_nav_controller.dart';

class WebSponsorEventPage extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  const WebSponsorEventPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EventsController>();
    c.selectedSponsorDuration.value = null;

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

              // ── Event header card ─────────────────────────
              Container(
                padding: const EdgeInsets.all(28),
                decoration: _dec(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: AppColors.favoriteGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                style: TextStyle(
                                  color: WebTheme.text,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.type,
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (event.description.isNotEmpty) ...[
                      Text(
                        event.description,
                        style: TextStyle(
                          color: AppColors.grey.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    _row(
                      Icons.storefront_rounded,
                      'المعرض',
                      event.exhibitionName,
                    ),
                    _row(
                      Icons.calendar_today_outlined,
                      'التاريخ',
                      '${event.date} • ${event.startTime} - ${event.endTime}',
                    ),
                    _row(Icons.location_on_outlined, 'المكان', event.place),
                    _row(
                      Icons.schedule_outlined,
                      'مدة الإدراج',
                      '${event.listingDays} أيام',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Duration options ──────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: _dec(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('اختر مدة الرعاية'),
                    const SizedBox(height: 16),
                    if (event.durationOptions.isEmpty)
                      Text(
                        'لا توجد خيارات رعاية متاحة لهذه الفعالية',
                        style: TextStyle(
                          color: AppColors.grey.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      )
                    else
                      Obx(
                        () => Column(
                          children: event.durationOptions.map((opt) {
                            final sel =
                                c.selectedSponsorDuration.value?.label ==
                                opt.label;
                            return GestureDetector(
                              onTap: () =>
                                  c.selectedSponsorDuration.value = opt,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: sel
                                      ? AppColors.favoriteGradient
                                      : null,
                                  color: sel ? null : WebTheme.surfaceAlt,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: sel
                                        ? Colors.transparent
                                        : WebTheme.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      sel
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: sel
                                          ? WebTheme.text
                                          : AppColors.grey,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            opt.label,
                                            style: TextStyle(
                                              color: WebTheme.text,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            '${opt.days} أيام',
                                            style: TextStyle(
                                              color: sel
                                                  ? WebTheme.text70
                                                  : AppColors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${opt.price.toInt()} ر.س',
                                      style: TextStyle(
                                        color: sel
                                            ? WebTheme.text
                                            : WebTheme.accent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Company data ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: _dec(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('بيانات الشركة'),
                    const SizedBox(height: 16),
                    _field(
                      c.companyNameCtrl,
                      'اسم الشركة',
                      Icons.business_outlined,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      c.companyPhoneCtrl,
                      'رقم الجوال',
                      Icons.phone_outlined,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      c.companyWebCtrl,
                      'الموقع الإلكتروني',
                      Icons.language_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Advertising materials ─────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: _dec(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('المواد الإعلانية'),
                    const SizedBox(height: 6),
                    Text(
                      'يرجى رفع المواد الإعلانية المطلوبة للمشاركة',
                      style: TextStyle(color: AppColors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // 1. Company logo
                    _subLabel('شعار الشركة'),
                    const SizedBox(height: 10),
                    Obx(() {
                      final bytes = c.logoBytes;
                      if (bytes != null) {
                        return Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.memory(
                                    bytes,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -7,
                                  right: -7,
                                  child: GestureDetector(
                                    onTap: c.removeLogo,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: c.pickLogo,
                              child: _uploadChip(
                                Icons.swap_horiz_rounded,
                                'تغيير الشعار',
                              ),
                            ),
                          ],
                        );
                      }
                      return GestureDetector(
                        onTap: c.pickLogo,
                        child: _uploadTile(
                          Icons.image_outlined,
                          'اضغط لرفع شعار الشركة',
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // 2. Ad imagesconst SizedBox(height: 12),
                    _subLabel('المنتجات / الخدمات المعروضة'),
                    const SizedBox(height: 8),
                    _ProductItemsWidget(c: c),
                    const SizedBox(height: 20),

                    // 3. Poster images
                    _subLabel('ملصقات دعائية - بوسترات (حتى 4)'),
                    const SizedBox(height: 10),
                    Obx(() {
                      final bytes = c.posterBytes;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (bytes.isNotEmpty) ...[
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: bytes.asMap().entries.map((e) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        e.value,
                                        width: 90,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: -6,
                                      right: -6,
                                      child: GestureDetector(
                                        onTap: () => c.removePosterFile(e.key),
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
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                          ],
                          GestureDetector(
                            onTap: c.pickPosterImages,
                            child: _uploadTile(
                              Icons.campaign_outlined,
                              bytes.isEmpty
                                  ? 'اضغط لرفع الملصقات الدعائية'
                                  : 'إضافة المزيد من الملصقات',
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Booking summary + submit ───────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: _dec(),
                child: Column(
                  children: [
                    Obx(() {
                      final dur = c.selectedSponsorDuration.value;
                      if (dur == null) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: WebTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: WebTheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              color: WebTheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ملخص الحجز',
                                    style: TextStyle(
                                      color: WebTheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    dur.label,
                                    style: TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${dur.price.toInt()} ر.س',
                              style: TextStyle(
                                color: WebTheme.accent,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: c.isBooking.value ? null : () => _book(c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: AppColors.favoriteGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: c.isBooking.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'تأكيد طلب الرعاية',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _book(EventsController c) async {
    final ok = await c.submitSponsorship(event);
    if (ok) WebNavController.to.select(4);
  }

  Widget _back() => GestureDetector(
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
        Text('رجوع', style: TextStyle(color: AppColors.grey, fontSize: 14)),
      ],
    ),
  );

  BoxDecoration _dec() => BoxDecoration(
    color: WebTheme.surface,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: WebTheme.border),
  );

  Widget _section(String t) => Row(
    children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          gradient: AppColors.favoriteGradient,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        t,
        style: TextStyle(
          color: WebTheme.text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _subLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.grey,
    ),
  );

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Icon(icon, size: 19, color: WebTheme.primary),
        const SizedBox(width: 12),
        Text('$label: ', style: TextStyle(color: AppColors.grey, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: WebTheme.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    style: TextStyle(color: WebTheme.text),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.6)),
      prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
      filled: true,
      fillColor: WebTheme.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WebTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WebTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WebTheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  Widget _uploadTile(IconData icon, String label) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: WebTheme.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: WebTheme.primary.withOpacity(0.35), width: 1.5),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: WebTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: WebTheme.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: AppColors.grey, fontSize: 13),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: WebTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'رفع',
            style: TextStyle(
              color: WebTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _uploadChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: WebTheme.primary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: WebTheme.primary.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: WebTheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: WebTheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ── Product items widget (web) ────────────────────────────────────────────
class _ProductItemsWidget extends StatelessWidget {
  final EventsController c;
  const _ProductItemsWidget({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = c.productItems;
      return Column(
        children: [
          ...items.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: WebTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WebTheme.border),
              ),
              child: Row(
                children: [
                  // Image picker square
                  GestureDetector(
                    onTap: () => c.pickProductImage(idx),
                    child: item.imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              item.imageBytes!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: WebTheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: WebTheme.primary.withOpacity(0.35),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: WebTheme.primary,
                              size: 24,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Name text field
                  Expanded(
                    child: TextField(
                      controller: item.nameCtrl,
                      style: TextStyle(color: WebTheme.text, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'اسم المنتج أو الخدمة',
                        hintStyle: TextStyle(
                          color: AppColors.grey.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: WebTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: WebTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: WebTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: WebTheme.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Remove button
                  GestureDetector(
                    onTap: () => c.removeProductItem(idx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Add product button
          GestureDetector(
            onTap: c.addProductItem,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: WebTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: WebTheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: WebTheme.primary,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'إضافة منتج / خدمة',
                    style: TextStyle(
                      color: WebTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
