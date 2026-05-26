import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/events_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';
import '../../../widget/Home/custom_text_field.dart';

class CreateEventView extends GetView<EventsController> {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'إنشاء فعالية جديدة'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomTextField(controller: controller.nameCtrl, hint: 'اسم الفعالية', prefixIcon: Icons.event_outlined,
              validator: (v) => v!.isEmpty ? 'مطلوب' : null),
            const SizedBox(height: 14),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedType.value.isEmpty ? null : controller.selectedType.value,
              hint: const Text('نوع الفعالية', style: TextStyle(color: AppColors.grey)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: controller.eventTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => controller.selectedType.value = v ?? '',
            )),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _datePicker(context, 'التاريخ', Icons.calendar_today_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _datePicker(context, 'الوقت', Icons.access_time_outlined)),
            ]),
            const SizedBox(height: 14),
            CustomTextField(controller: controller.maxCtrl, hint: 'الحد الأقصى للمشاركين', keyboard: TextInputType.number, prefixIcon: Icons.people_outline),
            const SizedBox(height: 14),
            CustomTextField(controller: controller.descCtrl, hint: 'وصف الفعالية', maxLines: 4, prefixIcon: Icons.description_outlined),
            const SizedBox(height: 14),
            _registrationType(context),
            const SizedBox(height: 14),
            _coverUpload(context),
            const SizedBox(height: 24),
            Obx(() => CustomButton(label: 'إنشاء الفعالية', onTap: controller.createEvent, isLoading: controller.isCreating.value)),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [Icon(icon, size: 16, color: AppColors.grey), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey))]),
      ),
    );
  }

  Widget _registrationType(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('نوع التسجيل', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.grey)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _typeChip(context, isDark, 'حجز مسبق', Icons.bookmark_outlined)),
        const SizedBox(width: 8),
        Expanded(child: _typeChip(context, isDark, 'تسجيل في المكان', Icons.location_on_outlined)),
      ]),
    ]);
  }

  Widget _typeChip(BuildContext context, bool isDark, String label, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.grey.withOpacity(0.3)),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 16, color: AppColors.grey),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
    ]),
  );

  Widget _coverUpload(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity, height: 90,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3), width: 1.5),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.darkPrimary.withOpacity(0.6)),
          const SizedBox(height: 6),
          const Text('رفع صورة غلاف الفعالية', style: TextStyle(fontSize: 12, color: AppColors.grey)),
        ]),
      ),
    );
  }
}
