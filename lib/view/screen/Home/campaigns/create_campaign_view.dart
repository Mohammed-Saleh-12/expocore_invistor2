import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
      appBar: CustomAppBar(title: 'campaign_create_title'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AppTextField(controller: controller.titleCtrl, hint: 'campaign_title_hint'.tr, prefixIcon:const Icon( Icons.title ,size: 18,),
              validator: (v) => v!.isEmpty ? 'required'.tr : null, label: 'campaign_title_hint'.tr,),
            const SizedBox(height: 14),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedType.value.isEmpty ? null : controller.selectedType.value,
              hint: Text('campaign_type_hint'.tr, style: const TextStyle(color: AppColors.grey)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: controller.campaignTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.tr, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) => controller.selectedType.value = v ?? '',
            )),
            const SizedBox(height: 14),
            AppTextField(controller: controller.descCtrl, maxLines: 3, label: 'campaign_desc_hint'.tr,),
            const SizedBox(height: 14),
            Text('campaign_budget_label'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.grey)),
            const SizedBox(height: 6),
            AppTextField(controller: controller.budgetCtrl, keyboardType: TextInputType.number, prefixIcon:const Icon(Icons.monetization_on_outlined ,size: 18,) , label: '0',),
            const SizedBox(height: 14),
            _dateRange(context),
            const SizedBox(height: 14),
            _mediaUpload(context),
            const SizedBox(height: 24),
            Obx(() => CustomButton(label: 'campaign_publish_btn'.tr, onTap: controller.createCampaign, isLoading: controller.isCreating.value)),
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
        Text('campaign_start_date'.tr, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
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
        Text('campaign_end_date'.tr, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
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
    return Obx(() {
      final files = controller.mediaFiles;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── زر الرفع ──────────────────────────────────────
          GestureDetector(
            onTap: controller.pickCampaignMedia,
            child: Container(
              width: double.infinity,
              height: files.isEmpty ? 100 : 60,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.darkPrimary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: files.isEmpty
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.upload_file_outlined,
                          size: 36, color: AppColors.darkPrimary.withOpacity(0.6)),
                      const SizedBox(height: 8),
                      Text('campaign_media_upload'.tr,
                          style: const TextStyle(fontSize: 13, color: AppColors.grey)),
                    ])
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.add_photo_alternate_outlined,
                          size: 20, color: AppColors.darkPrimary),
                      const SizedBox(width: 8),
                      Text('إضافة المزيد',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.darkPrimary)),
                    ]),
            ),
          ),
          // ── معاينة الملفات المختارة ───────────────────────
          if (files.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: files.length,
                itemBuilder: (_, i) => Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _XFileThumbnail(file: files[i]),
                    ),
                    Positioned(
                      top: 2,
                      left: 2,
                      child: GestureDetector(
                        onTap: () => controller.removeCampaignMedia(i),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

/// معاينة صغيرة لـ XFile — تعمل على الويب والجوال
class _XFileThumbnail extends StatelessWidget {
  final XFile file;
  const _XFileThumbnail({required this.file});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (_, snap) {
        if (snap.hasData) {
          return Image.memory(
            snap.data!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );
        }
        return const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
