import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/events_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../data/model/booth/booth_model.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';
import '../../../widget/Home/custom_text_field.dart';

class CreateEventView extends GetView<EventsController> {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(title: 'create_event_title'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Basic info ─────────────────────────────────────────
              _sectionHeader('event_section_basic'.tr),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.nameCtrl,
                prefixIcon: const Icon(Icons.event_outlined, size: 18),
                validator: (v) => v!.isEmpty ? 'required'.tr : null,
                label: 'event_name_hint'.tr,
              ),
              const SizedBox(height: 12),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedType.value.isEmpty
                      ? null
                      : controller.selectedType.value,
                  hint: Text(
                    'event_type_hint'.tr,
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkCard
                        : AppColors.lightCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: controller.eventTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.tr)))
                      .toList(),
                  onChanged: (v) => controller.selectedType.value = v ?? '',
                ),
              ),
              const SizedBox(height: 20),

              // ── Exhibition & Booth selection ────────────────────────
              _sectionHeader('event_section_exhibition'.tr),
              const SizedBox(height: 12),
              // Step 1: pick exhibition
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedExhibitionName.value.isEmpty
                      ? null
                      : controller.selectedExhibitionName.value,
                  hint: Text(
                    'event_select_exhibition'.tr,
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkCard
                        : AppColors.lightCard,
                    prefixIcon: const Icon(
                      Icons.store_outlined,
                      color: AppColors.darkPrimary,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: controller.myExhibitionNames
                      .map(
                        (name) =>
                            DropdownMenuItem(value: name, child: Text(name)),
                      )
                      .toList(),
                  onChanged: (v) {
                    controller.selectedExhibitionName.value = v ?? '';
                    controller.selectedBooth.value = null;
                  },
                ),
              ),
              // Step 2: pick booth (shown once exhibition is chosen)
              Obx(() {
                if (controller.selectedExhibitionName.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                final booths = controller.boothsForSelectedExhibition;
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    DropdownButtonFormField<BoothModel>(
                      value: controller.selectedBooth.value,
                      hint: Text(
                        'event_select_booth'.tr,
                        style: const TextStyle(color: AppColors.grey),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        prefixIcon: const Icon(
                          Icons.grid_view,
                          color: AppColors.darkSecondary,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: booths
                          .map(
                            (b) => DropdownMenuItem<BoothModel>(
                              value: b,
                              child: Text(
                                '${'event_booth_prefix'.tr} ${b.number} — ${b.location}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => controller.selectedBooth.value = v,
                    ),
                  ],
                );
              }),
              // Confirmation chip when booth is chosen
              Obx(() {
                final booth = controller.selectedBooth.value;
                if (booth == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSecondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.darkSecondary.withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.darkSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'event_selected_location'.tr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey,
                                ),
                              ),
                              Text(
                                '${'event_booth_prefix'.tr} ${booth.number} — ${controller.selectedExhibitionName.value}',
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
                          color: AppColors.darkSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // ── Date & time ────────────────────────────────────────
              _sectionHeader('event_section_datetime'.tr),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _datePicker(
                      context,
                      isDark,
                      'event_date_label'.tr,
                      Icons.calendar_today_outlined,
                      isDate: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _datePicker(
                      context,
                      isDark,
                      'event_time_label'.tr,
                      Icons.access_time_outlined,
                      isDate: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Description ────────────────────────────────────────
              _sectionHeader('event_section_about'.tr),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.descCtrl,
                maxLines: 4,
                prefixIcon: const Icon(Icons.description_outlined, size: 18),
                validator: (v) => v!.isEmpty ? 'required'.tr : null,
                label: 'event_desc_hint'.tr,
              ),
              const SizedBox(height: 20),

              // ── Media ──────────────────────────────────────────────
              _sectionHeader('event_section_media'.tr),
              const SizedBox(height: 12),
              _buildImagePicker(isDark),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.videoPromoCtrl,
                prefixIcon: const Icon(Icons.play_circle_outline, size: 18),
                label: 'event_video_hint'.tr,
              ),
              const SizedBox(height: 20),

              // ── Seats / Registration ────────────────────────────────
              _sectionHeader('event_section_tickets'.tr),
              const SizedBox(height: 14),
              _ticketTypeSelector(isDark),
              const SizedBox(height: 14),
              Obx(() => _ticketTypeFields(isDark)),
              const SizedBox(height: 28),

              Obx(
                () => CustomButton(
                  label: 'event_publish_btn'.tr,
                  onTap: controller.createEvent,
                  isLoading: controller.isCreating.value,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Row(
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
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ],
  );

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.grey,
    ),
  );

  Widget _datePicker(
    BuildContext context,
    bool isDark,
    String label,
    IconData icon, {
    required bool isDate,
  }) {
    return GestureDetector(
      onTap: () async {
        if (isDate) {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2026, 7, 16),
            firstDate: DateTime(2026, 1, 1),
            lastDate: DateTime(2027, 12, 31),
          );
          if (picked != null) {
            Get.find<EventsController>().selectedDate.value =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        } else {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            Get.find<EventsController>().selectedTime.value =
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          }
        }
      },
      child: Obx(() {
        final ctrl = Get.find<EventsController>();
        final value = isDate
            ? ctrl.selectedDate.value
            : ctrl.selectedTime.value;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : label,
                  style: TextStyle(
                    fontSize: 13,
                    color: value.isNotEmpty ? null : AppColors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Ticket type — 3 options ───────────────────────────────
  Widget _ticketTypeSelector(bool isDark) {
    final options = [
      _TicketOption(
        type: 'general',
        icon: Icons.people_outline,
        label: 'event_ticket_general'.tr,
        sublabel: 'event_ticket_general_sub'.tr,
        color: AppColors.darkPrimary,
      ),
      _TicketOption(
        type: 'free_limited',
        icon: Icons.confirmation_number_outlined,
        label: 'event_ticket_free_limited'.tr,
        sublabel: 'event_ticket_free_limited_sub'.tr,
        color: AppColors.darkSecondary,
      ),
      _TicketOption(
        type: 'paid',
        icon: Icons.payments_outlined,
        label: 'event_ticket_paid'.tr,
        sublabel: 'event_ticket_paid_sub'.tr,
        color: AppColors.darkAccent,
      ),
    ];

    return Obx(
      () => Row(
        children: options.asMap().entries.map((entry) {
          final opt = entry.value;
          final sel = controller.ticketType.value == opt.type;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.ticketType.value = opt.type,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  gradient: sel
                      ? LinearGradient(
                          colors: [opt.color.withOpacity(0.85), opt.color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: sel
                      ? null
                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel
                        ? Colors.transparent
                        : opt.color.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: opt.color.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      opt.icon,
                      size: 22,
                      color: sel ? Colors.white : opt.color,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      opt.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      opt.sublabel,
                      style: TextStyle(
                        fontSize: 9,
                        color: sel ? Colors.white70 : AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
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

  // ── Conditional fields based on ticket type ───────────────
  Widget _ticketTypeFields(bool isDark) {
    switch (controller.ticketType.value) {
      // ── Free limited ────────────────────────────────────────
      case 'free_limited':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            _fieldLabel('event_max_registrants_label'.tr),
            const SizedBox(height: 8),
            AppTextField(
              controller: controller.freeLimitCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.groups_outlined, size: 18),
              validator: (v) {
                if (v == null || v.isEmpty) return 'event_enter_count'.tr;
                final n = int.tryParse(v);
                if (n == null || n < 1) return 'event_invalid_count'.tr;
                return null;
              },
              label: 'event_ticket_limit_hint'.tr,
            ),
            const SizedBox(height: 10),
            _fieldNote(
              Icons.info_outline_rounded,
              'event_auto_close_note'.tr,
              AppColors.darkSecondary,
            ),
          ],
        );

      // ── Paid ────────────────────────────────────────────────
      case 'paid':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: controller.seatsCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.event_seat_outlined, size: 18),
              validator: (v) => (v == null || v.isEmpty) ? 'required'.tr : null,
              label: 'event_total_seats_hint'.tr,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: controller.ticketPriceCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.payments_outlined, size: 18),
              validator: (v) => (v == null || v.isEmpty) ? 'required'.tr : null,
              label: 'event_ticket_price_hint'.tr,
            ),
            const SizedBox(height: 10),
            _fieldNote(
              Icons.lock_outline_rounded,
              'event_paid_note'.tr,
              AppColors.darkAccent,
            ),
          ],
        );

      // ── General (default) ───────────────────────────────────
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: controller.maxCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.people_outline, size: 18),
              label: 'event_max_optional_hint'.tr,
            ),
            const SizedBox(height: 10),
            _fieldNote(
              Icons.public_rounded,
              'event_open_note'.tr,
              AppColors.darkPrimary,
            ),
          ],
        );
    }
  }

  // ── Field note ────────────────────────────────────────────
  Widget _fieldNote(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 11, color: color.withOpacity(0.85)),
        ),
      ),
    ],
  );
  // ── Image picker grid ─────────────────────────────────────
  Widget _buildImagePicker(bool isDark) => Obx(() {
    final images = controller.pickedImages;
    final hasImages = images.isNotEmpty;
    final canAdd = images.length < 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Counter + hint ──────────────────────────────
        Row(
          children: [
            Text(
              '${images.length}/6 صور',
              style: TextStyle(
                fontSize: 12,
                color: images.isNotEmpty
                    ? AppColors.darkPrimary
                    : AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (hasImages)
              GestureDetector(
                onTap: controller.pickImages,
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 16,
                      color: AppColors.darkPrimary,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'إضافة المزيد',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Grid of picked images + add button ──────────
        if (hasImages)
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images
                ...images.asMap().entries.map(
                  (e) =>
                      _ImageThumb(file: e.value, index: e.key, isDark: isDark),
                ),
                // Add more cell
                if (canAdd)
                  _AddMoreCell(isDark: isDark, onTap: controller.pickImages),
              ],
            ),
          )
        else
          // ── Empty drop zone ─────────────────────────
          GestureDetector(
            onTap: controller.pickImages,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkPrimary.withOpacity(0.3),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignOutside,
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
                          color: AppColors.darkPrimary.withOpacity(0.3),
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
                  const Text(
                    'اضغط لرفع الصور',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkPrimary,
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
}

// ════════════════════════════════════════════════════════════
//  WIDGET  — image thumbnail with remove button
// ════════════════════════════════════════════════════════════
class _ImageThumb extends StatelessWidget {
  final File file;
  final int index;
  final bool isDark;
  const _ImageThumb({
    required this.file,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
          ),
          // Remove button
          Positioned(
            top: 4,
            left: 4,
            child: GestureDetector(
              onTap: () => Get.find<EventsController>().removeImage(index),
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 14,
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
//  WIDGET  — "add more" cell
// ════════════════════════════════════════════════════════════
class _AddMoreCell extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _AddMoreCell({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.darkPrimary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: AppColors.darkPrimary.withOpacity(0.7),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'إضافة',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.darkPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  MODEL  — ticket option data
// ════════════════════════════════════════════════════════════
class _TicketOption {
  final String type;
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _TicketOption({
    required this.type,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });
}
