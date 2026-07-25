import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/booth/booth_model.dart';
import '../../../view/widget/Home/booth_day_picker_dialog.dart';
import '../../controllers/web_nav_controller.dart';

class WebCreateEventPage extends StatelessWidget {
  const WebCreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EventsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: _cardDec(),
                child: Form(
                  key: c.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _title(),
                      const SizedBox(height: 28),

                      // ── المعلومات الأساسية ───────────────
                      _section('event_section_basic'.tr),
                      const SizedBox(height: 14),
                      _field(
                        c.nameCtrl,
                        'event_name_hint'.tr,
                        Icons.event_outlined,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'field_required'.tr
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Obx(
                        () => _dropdown(
                          value: c.selectedType.value,
                          hint: 'event_type_hint'.tr,
                          icon: Icons.category_outlined,
                          items: c.eventTypes,
                          onChanged: (v) => c.selectedType.value = v ?? '',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── المعرض والجناح ───────────────────
                      _section('event_section_exhibition'.tr),
                      const SizedBox(height: 14),
                      Obx(
                        () => _dropdown(
                          value: c.selectedExhibitionName.value,
                          hint: 'event_select_exhibition'.tr,
                          icon: Icons.store_outlined,
                          items: c.myExhibitionNames,
                          onChanged: (v) {
                            c.selectedExhibitionName.value = v ?? '';
                            c.selectedBooth.value = null;
                          },
                        ),
                      ),
                      Obx(() {
                        if (c.selectedExhibitionName.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final booths = c.boothsForSelectedExhibition;
                        return Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: DropdownButtonFormField<BoothModel>(
                            value: c.selectedBooth.value,
                            hint: Text(
                              'event_select_booth'.tr,
                              style: TextStyle(color: AppColors.grey),
                            ),
                            dropdownColor: WebTheme.surfaceAlt,
                            style: TextStyle(color: WebTheme.text),
                            decoration: _dec(Icons.grid_view_rounded),
                            items: booths
                                .map(
                                  (b) => DropdownMenuItem<BoothModel>(
                                    value: b,
                                    child: Text(
                                      'جناح ${b.number} — ${b.location}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => c.selectedBooth.value = v,
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // ── التاريخ والوقت والمدة ────────────
                      _section('event_section_datetime'.tr),
                      const SizedBox(height: 14),
                      // تاريخ البداية / تاريخ النهاية
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _pickerBox(
                                context,
                                'event_start_date_hint'.tr,
                                Icons.calendar_today_outlined,
                                c.selectedDate.value,
                                isDate: true,
                                isEnd: false,
                                c: c,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Obx(
                              () => _pickerBox(
                                context,
                                'event_end_date_hint'.tr,
                                Icons.event_available_outlined,
                                c.selectedEndDate.value,
                                isDate: true,
                                isEnd: true,
                                c: c,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // الوقت
                      Obx(
                        () => _pickerBox(
                          context,
                          'event_time_hint'.tr,
                          Icons.access_time_outlined,
                          c.selectedTime.value,
                          isDate: false,
                          c: c,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── الوصف ────────────────────────────
                      _section('event_section_desc'.tr),
                      const SizedBox(height: 14),
                      _field(
                        c.descCtrl,
                        'event_desc_hint'.tr,
                        Icons.description_outlined,
                        maxLines: 4,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'field_required'.tr
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // ── الصور والفيديو ───────────────────
                      _section('event_section_media'.tr),
                      const SizedBox(height: 14),
                      _mediaPicker(c),
                      const SizedBox(height: 12),
                      _field(
                        c.videoPromoCtrl,
                        'event_video_hint'.tr,
                        Icons.play_circle_outline,
                      ),
                      const SizedBox(height: 24),

                      // ── التذاكر ──────────────────────────
                      _section('event_section_tickets'.tr),
                      const SizedBox(height: 14),
                      _ticketTypeSelector(c),
                      const SizedBox(height: 14),
                      Obx(() => _ticketFields(c)),
                      const SizedBox(height: 28),

                      // ── الأزرار ──────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _cancelBtn(),
                          const SizedBox(width: 14),
                          Obx(
                            () => GestureDetector(
                              onTap: c.isCreating.value
                                  ? null
                                  : () => _submit(c),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 36,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.favoriteGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: c.isCreating.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'event_publish_btn'.tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(EventsController c) async {
    final ok = await c.submitEvent();
    if (ok) WebNavController.to.select(3); // → فعالياتي
  }

  // ── Ticket type selector (general/free_limited/paid) ──────
  Widget _ticketTypeSelector(EventsController c) {
    final opts = [
      (
        'general',
        Icons.people_outline,
        'event_type_general'.tr,
        'event_type_general_sub'.tr,
        WebTheme.primary,
      ),
      (
        'free_limited',
        Icons.confirmation_number_outlined,
        'event_type_free'.tr,
        'event_type_free_sub'.tr,
        WebTheme.secondary,
      ),
      (
        'paid',
        Icons.payments_outlined,
        'event_type_paid'.tr,
        'event_type_paid_sub'.tr,
        WebTheme.accent,
      ),
    ];
    return Obx(
      () => Row(
        children: opts.asMap().entries.map((e) {
          final (type, icon, label, sub, color) = e.value;
          final sel = c.ticketType.value == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => c.ticketType.value = type,
              child: Container(
                margin: EdgeInsets.only(left: 10),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  gradient: sel
                      ? LinearGradient(colors: [color.withOpacity(0.85), color])
                      : null,
                  color: sel ? null : WebTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? Colors.transparent : color.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: sel ? Colors.white : color, size: 24),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: sel ? Colors.white : WebTheme.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: TextStyle(
                        color: sel ? Colors.white : AppColors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _ticketFields(EventsController c) {
    switch (c.ticketType.value) {
      case 'free_limited':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(
              c.freeLimitCtrl,
              'event_free_limit_hint'.tr,
              Icons.groups_outlined,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 8),
            _note(
              Icons.info_outline_rounded,
              'event_free_limit_note'.tr,
              WebTheme.secondary,
            ),
          ],
        );
      case 'paid':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(
              c.seatsCtrl,
              'event_seats_hint'.tr,
              Icons.event_seat_outlined,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _field(
              c.ticketPriceCtrl,
              'event_ticket_price_hint'.tr,
              Icons.payments_outlined,
              keyboard: TextInputType.number,
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(
              c.maxCtrl,
              'event_max_participants_hint'.tr,
              Icons.people_outline,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 8),
            _note(
              Icons.public_rounded,
              'event_general_note'.tr,
              WebTheme.primary,
            ),
          ],
        );
    }
  }

  Widget _mediaPicker(EventsController c) => Obx(() {
    final count = c.pickedImages.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── عداد الصور ──────────────────────────────────────
        Row(
          children: [
            Text(
              '$count/6 صور',
              style: TextStyle(
                color: count > 0 ? WebTheme.primary : AppColors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (count > 0 && count < 6)
              GestureDetector(
                onTap: c.pickImages,
                child: Row(
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 15, color: WebTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'إضافة المزيد',
                      style: TextStyle(fontSize: 12, color: WebTheme.primary),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── شبكة الصور ──────────────────────────────────────
        if (count > 0)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // الصور المختارة — تعرض الصورة الفعلية عبر _XFileImage
              ...c.pickedImages.asMap().entries.map(
                (e) => _WebImageTile(
                  width: 100,
                  height: 80,
                  onRemove: () => c.removeImage(e.key),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _XFileImage(
                        file: e.value, width: 100, height: 80),
                  ),
                ),
              ),
              // زر الإضافة
              if (count < 6) _buildWebAddButton(c),
            ],
          )
        else
          // ── حالة فارغة — منطقة السحب والإفلات ──────────
          GestureDetector(
            onTap: c.pickImages,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: WebTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: WebTheme.primary.withOpacity(0.35),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.favoriteGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: WebTheme.primary.withOpacity(0.3),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'اضغط لرفع الصور',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WebTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'JPG, PNG — حتى 6 صور',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  });

  Widget _buildWebAddButton(EventsController c) => GestureDetector(
        onTap: c.pickImages,
        child: Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            color: WebTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: WebTheme.primary.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  color: WebTheme.primary, size: 26),
              const SizedBox(height: 4),
              Text('إضافة',
                  style: TextStyle(fontSize: 11, color: WebTheme.primary)),
            ],
          ),
        ),
      );

  Widget _title() => Row(
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.favoriteGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
      const SizedBox(width: 14),
      Text(
        'event_create_title'.tr,
        style: TextStyle(
          color: WebTheme.text,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );

  Widget _cancelBtn() => GestureDetector(
    onTap: WebNavController.to.closeDetail,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'btn_cancel'.tr,
        style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w700),
      ),
    ),
  );

  BoxDecoration _cardDec() => BoxDecoration(
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
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _note(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: TextStyle(color: color.withOpacity(0.9), fontSize: 11),
        ),
      ),
    ],
  );

  InputDecoration _dec(IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
    filled: true,
    fillColor: WebTheme.surfaceAlt,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  Widget _field(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: c,
    keyboardType: keyboard,
    maxLines: maxLines,
    validator: validator,
    style: TextStyle(color: WebTheme.text),
    decoration: _dec(icon).copyWith(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.6)),
    ),
  );

  Widget _dropdown({
    required String value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
    value: value.isEmpty ? null : value,
    hint: Text(hint, style: TextStyle(color: AppColors.grey)),
    dropdownColor: WebTheme.surfaceAlt,
    style: TextStyle(color: WebTheme.text),
    isExpanded: true,
    decoration: _dec(icon),
    items: items
        .map(
          (t) => DropdownMenuItem(
            value: t,
            child: Text(t, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );

  Widget _pickerBox(
    BuildContext context,
    String label,
    IconData icon,
    String value, {
    required bool isDate,
    bool isEnd = false,
    required EventsController c,
  }) {
    // احسب رقم اليوم لعرضه (فقط لحقول التاريخ بعد الاختيار)
    String? dayLabel;
    if (isDate && value.isNotEmpty && c.selectedBooth.value != null) {
      final dt = DateTime.tryParse(value);
      if (dt != null) {
        final days = c.boothDayDates;
        final idx = days.indexWhere(
          (d) => d.year == dt.year && d.month == dt.month && d.day == dt.day,
        );
        if (idx >= 0) dayLabel = 'اليوم ${idx + 1}';
      }
    }

    return GestureDetector(
      onTap: () async {
        if (isDate) {
          // استخدام نافذة أيام الجناح المشتركة
          await showBoothDayPicker(context, WebTheme.isDark.value, isEnd: isEnd);
        } else {
          final p = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (p != null) {
            c.selectedTime.value =
                '${p.hour.toString().padLeft(2, '0')}:${p.minute.toString().padLeft(2, '0')}';
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: value.isNotEmpty
              ? WebTheme.primary.withOpacity(0.07)
              : WebTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value.isNotEmpty ? WebTheme.primary : WebTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: value.isNotEmpty ? WebTheme.primary : AppColors.grey,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: value.isEmpty
                  ? Text(
                      label,
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.grey),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dayLabel != null)
                          Text(
                            dayLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: WebTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        Text(
                          value,
                          style: TextStyle(
                            color: WebTheme.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  WIDGET  — web image tile with ✕ remove button (booth style)
// ════════════════════════════════════════════════════════════
class _WebImageTile extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final VoidCallback onRemove;

  const _WebImageTile({
    required this.width,
    required this.height,
    required this.child,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          SizedBox(width: width, height: height, child: child),
          Positioned(
            top: 4,
            left: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  WIDGET  — XFile display via FutureBuilder (booth style)
// ════════════════════════════════════════════════════════════
class _XFileImage extends StatelessWidget {
  final XFile file;
  final double width;
  final double height;

  const _XFileImage({
    required this.file,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (_, snap) {
        if (snap.hasData) {
          return Image.memory(
            snap.data!,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        }
        return Container(
          width: width,
          height: height,
          color: WebTheme.surfaceAlt,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}
