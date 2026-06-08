import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/campaigns_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';
import '../../../widget/Home/custom_text_field.dart';

class CreateCampaignView extends GetView<CampaignsController> {
  const CreateCampaignView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'إنشاء حملة جديدة'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomTextField(controller: controller.titleCtrl, hint: 'عنوان الحملة', prefixIcon: Icons.title,
              validator: (v) => v!.isEmpty ? 'مطلوب' : null),
            const SizedBox(height: 14),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedType.value.isEmpty ? null : controller.selectedType.value,
              hint: const Text('نوع الحملة', style: TextStyle(color: AppColors.grey)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: controller.campaignTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) => controller.selectedType.value = v ?? '',
            )),
            const SizedBox(height: 14),
            CustomTextField(controller: controller.descCtrl, hint: 'وصف الحملة', maxLines: 3),
            const SizedBox(height: 14),
            const Text('الميزانية (ريال)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.grey)),
            const SizedBox(height: 6),
            CustomTextField(controller: controller.budgetCtrl, hint: '0', keyboard: TextInputType.number, prefixIcon: Icons.monetization_on_outlined),
            const SizedBox(height: 14),
            _dateRange(context),
            const SizedBox(height: 14),
            _mediaUpload(context),
            const SizedBox(height: 24),
            Obx(() => CustomButton(label: 'نشر الحملة', onTap: controller.createCampaign, isLoading: controller.isCreating.value)),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _dateRange(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('تاريخ البدء', style: TextStyle(fontSize: 12, color: AppColors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.grey), const SizedBox(width: 6), const Text('2026-07-15', style: TextStyle(fontSize: 13))]),
        ),
      ])),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('تاريخ الانتهاء', style: TextStyle(fontSize: 12, color: AppColors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.grey), const SizedBox(width: 6), const Text('2026-07-20', style: TextStyle(fontSize: 13))]),
        ),
      ])),
    ]);
  }

  Widget _mediaUpload(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity, height: 100,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.upload_file_outlined, size: 36, color: AppColors.darkPrimary.withOpacity(0.6)),
          const SizedBox(height: 8),
          const Text('رفع الصور والمقاطع', style: TextStyle(fontSize: 13, color: AppColors.grey)),
        ]),
      ),
    );
  }
}
