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
      appBar: const CustomAppBar(title: 'نشر فعالية جديدة في الجناح'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Basic info ─────────────────────────────────────────
              _sectionHeader('المعلومات الأساسية'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.nameCtrl,
                hint: 'اسم الفعالية',
                prefixIcon: Icons.event_outlined,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedType.value.isEmpty
                        ? null
                        : controller.selectedType.value,
                    hint: const Text('نوع الفعالية',
                        style: TextStyle(color: AppColors.grey)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkCard
                          : AppColors.lightCard,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    items: controller.eventTypes
                        .map((t) => DropdownMenuItem(
                            value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) =>
                        controller.selectedType.value = v ?? '',
                  )),
              const SizedBox(height: 20),

              // ── Exhibition & Booth selection ────────────────────────
              _sectionHeader('اختيار المعرض والجناح'),
              const SizedBox(height: 12),
              // Step 1: pick exhibition
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedExhibitionName.value.isEmpty
                        ? null
                        : controller.selectedExhibitionName.value,
                    hint: const Text('اختر المعرض',
                        style: TextStyle(color: AppColors.grey)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkCard
                          : AppColors.lightCard,
                      prefixIcon: const Icon(Icons.store_outlined,
                          color: AppColors.darkPrimary, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    items: controller.myExhibitionNames
                        .map((name) => DropdownMenuItem(
                            value: name, child: Text(name)))
                        .toList(),
                    onChanged: (v) {
                      controller.selectedExhibitionName.value = v ?? '';
                      controller.selectedBooth.value = null;
                    },
                  )),
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
                      hint: const Text('اختر الجناح',
                          style: TextStyle(color: AppColors.grey)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        prefixIcon: const Icon(Icons.grid_view,
                            color: AppColors.darkSecondary, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      items: booths
                          .map((b) => DropdownMenuItem<BoothModel>(
                                value: b,
                                child: Text(
                                  'جناح ${b.number} — ${b.location}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedBooth.value = v,
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
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.success.withOpacity(0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.success, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('الموقع المختار',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grey)),
                              Text(
                                'جناح ${booth.number} — ${controller.selectedExhibitionName.value}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle,
                            size: 16, color: AppColors.success),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // ── Date & time ────────────────────────────────────────
              _sectionHeader('التاريخ والوقت'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _datePicker(context, isDark, 'التاريخ',
                        Icons.calendar_today_outlined,
                        isDate: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _datePicker(context, isDark, 'الوقت',
                        Icons.access_time_outlined,
                        isDate: false)),
              ]),
              const SizedBox(height: 12),
              // Duration chips
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('مدة الفعالية (أيام)'),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (i) {
                          final val = i + 1;
                          final selected =
                              controller.selectedDuration.value == val;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  controller.selectedDuration.value =
                                      val,
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                margin:
                                    EdgeInsets.only(left: i > 0 ? 6 : 0),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? const LinearGradient(colors: [
                                          AppColors.darkPrimary,
                                          AppColors.darkSecondary,
                                        ])
                                      : null,
                                  color: selected
                                      ? null
                                      : (isDark
                                          ? AppColors.darkCard
                                          : AppColors.lightCard),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: selected
                                          ? Colors.transparent
                                          : AppColors.grey
                                              .withOpacity(0.2)),
                                ),
                                child: Center(
                                  child: Text(
                                    '$val',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? Colors.white
                                            : null),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  )),
              const SizedBox(height: 20),

              // ── Description ────────────────────────────────────────
              _sectionHeader('نبذة عن الفعالية'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.descCtrl,
                hint: 'وصف تفصيلي للفعالية وأهدافها',
                maxLines: 4,
                prefixIcon: Icons.description_outlined,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 20),

              // ── Media ──────────────────────────────────────────────
              _sectionHeader('الصور والفيديو'),
              const SizedBox(height: 12),
              _uploadBox(isDark, Icons.collections_outlined,
                  'صور الشركة والمنتجات والاحتفالية'),
              const SizedBox(height: 10),
              CustomTextField(
                controller: controller.videoPromoCtrl,
                hint: 'رابط الفيديو الترويجي (اختياري)',
                prefixIcon: Icons.play_circle_outline,
              ),
              const SizedBox(height: 20),

              // ── Seats / Registration ────────────────────────────────
              _sectionHeader('التسجيل والتذاكر'),
              const SizedBox(height: 12),
              _registrationToggle(isDark),
              const SizedBox(height: 12),
              Obx(() {
                if (!controller.hasBookableSeats.value) {
                  return _inviteTypeSelector(isDark);
                }
                return Column(
                  children: [
                    CustomTextField(
                      controller: controller.seatsCtrl,
                      hint: 'عدد المقاعد المتاحة',
                      keyboard: TextInputType.number,
                      prefixIcon: Icons.event_seat_outlined,
                      validator: (v) =>
                          controller.hasBookableSeats.value &&
                                  v!.isEmpty
                              ? 'مطلوب'
                              : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: controller.ticketPriceCtrl,
                      hint: 'سعر التذكرة بالريال (0 = مجاني)',
                      keyboard: TextInputType.number,
                      prefixIcon: Icons.payments_outlined,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),

              // Participants limit
              _fieldLabel('الحد الأقصى للمشاركين'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: controller.maxCtrl,
                hint: 'مثال: 100',
                keyboard: TextInputType.number,
                prefixIcon: Icons.people_outline,
              ),
              const SizedBox(height: 28),

              Obx(() => CustomButton(
                    label: 'نشر الفعالية',
                    onTap: controller.createEvent,
                    isLoading: controller.isCreating.value,
                  )),
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
              gradient: const LinearGradient(
                colors: [AppColors.darkPrimary, AppColors.darkSecondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      );

  Widget _fieldLabel(String label) => Text(label,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.grey));

  Widget _datePicker(BuildContext context, bool isDark, String label,
      IconData icon, {required bool isDate}) {
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
        final value =
            isDate ? ctrl.selectedDate.value : ctrl.selectedTime.value;
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
                      color: value.isNotEmpty ? null : AppColors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _registrationToggle(bool isDark) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('هل تتضمن الفعالية حجز مقاعد؟'),
          const SizedBox(height: 8),
          Row(
            children: [
              _toggleOption(isDark, false, Icons.people_outline,
                  'لا — دعوة عامة'),
              const SizedBox(width: 10),
              _toggleOption(isDark, true, Icons.event_seat_outlined,
                  'نعم — مقاعد محدودة'),
            ],
          ),
        ],
      );

  Widget _toggleOption(
      bool isDark, bool value, IconData icon, String label) {
    return Expanded(
      child: Obx(() {
        final selected = controller.hasBookableSeats.value == value;
        return GestureDetector(
          onTap: () => controller.hasBookableSeats.value = value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(colors: [
                      AppColors.darkPrimary,
                      AppColors.darkSecondary,
                    ])
                  : null,
              color: selected
                  ? null
                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : AppColors.grey.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 16,
                    color: selected ? Colors.white : AppColors.grey),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : AppColors.grey,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _inviteTypeSelector(bool isDark) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
        ],
      );
  Widget _uploadBox(bool isDark, IconData icon, String label) =>
      GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.darkPrimary.withOpacity(0.25),
                width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: AppColors.darkPrimary.withOpacity(0.7),
                  size: 24),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.grey)),
              const Spacer(),
              const Icon(Icons.add_circle_outline,
                  color: AppColors.darkPrimary, size: 20),
            ],
          ),
        ),
      );
}