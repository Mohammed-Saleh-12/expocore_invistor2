import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/profile_company_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';
import '../../../widget/Home/custom_text_field.dart';
import '../../../widget/Home/profile_avatar.dart';

class ProfileCompanyView extends GetView<ProfileCompanyController> {
  const ProfileCompanyView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'profile_title'.tr,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isEditing.value ? Icons.close : Icons.edit_outlined,
                color: AppColors.darkPrimary,
              ),
              onPressed: controller.toggleEdit,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(context, isDark),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _sectionCard(context, isDark, 'profile_section_about'.tr, [
                    Obx(
                      () => controller.isEditing.value
                          ? AppTextField(
                              controller: controller.bioCtrl,
                              maxLines: 4,
                              label: 'profile_bio_hint'.tr,
                            )
                          : Text(
                              controller.bioCtrl.text,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey,
                                height: 1.7,
                              ),
                            ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _sectionCard(context, isDark, 'profile_section_contact'.tr, [
                    Obx(
                      () => controller.isEditing.value
                          ? Column(
                              children: [
                                AppTextField(
                                  controller: controller.locationCtrl,
                                  prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                  ),
                                  label: 'profile_location_hint'.tr,
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  controller: controller.emailCtrl,
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    size: 18,
                                  ),
                                  label: 'profile_email_hint'.tr,
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  controller: controller.phoneCtrl,
                                  prefixIcon: const Icon(
                                    Icons.phone_outlined,
                                    size: 18,
                                  ),
                                  label: 'profile_phone_hint'.tr,
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  controller: controller.websiteCtrl,
                                  prefixIcon: const Icon(
                                    Icons.language_outlined,
                                    size: 18,
                                  ),
                                  label: 'profile_website_hint'.tr,
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _contactRow(
                                  Icons.location_on_outlined,
                                  controller.locationCtrl.text,
                                ),
                                const SizedBox(height: 8),
                                _contactRow(
                                  Icons.email_outlined,
                                  controller.emailCtrl.text,
                                ),
                                const SizedBox(height: 8),
                                _contactRow(
                                  Icons.phone_outlined,
                                  controller.phoneCtrl.text,
                                ),
                                const SizedBox(height: 8),
                                _contactRow(
                                  Icons.language_outlined,
                                  controller.websiteCtrl.text,
                                ),
                              ],
                            ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _sectionCard(context, isDark, 'profile_section_social'.tr, [
                    Obx(
                      () => controller.isEditing.value
                          ? Column(
                              children: [
                                AppTextField(
                                  controller: controller.linkedinCtrl,
                                  prefixIcon: const Icon(Icons.link, size: 18),
                                  label: 'LinkedIn',
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  controller: controller.twitterCtrl,
                                  prefixIcon: const Icon(
                                    Icons.alternate_email,
                                    size: 18,
                                  ),
                                  label: 'X (Twitter)',
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  controller: controller.instagramCtrl,
                                  prefixIcon: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 18,
                                  ),
                                  label: 'Instagram',
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  controller: controller.facebookCtrl,
                                  prefixIcon: const Icon(
                                    Icons.facebook,
                                    size: 18,
                                  ),
                                  label: 'Facebook',
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (controller.linkedinCtrl.text.isNotEmpty)
                                  _contactRow(
                                    Icons.link,
                                    controller.linkedinCtrl.text,
                                  ),
                                if (controller.twitterCtrl.text.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _contactRow(
                                    Icons.alternate_email,
                                    controller.twitterCtrl.text,
                                  ),
                                ],
                                if (controller
                                    .instagramCtrl
                                    .text
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _contactRow(
                                    Icons.camera_alt_outlined,
                                    controller.instagramCtrl.text,
                                  ),
                                ],
                                if (controller
                                    .facebookCtrl
                                    .text
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _contactRow(
                                    Icons.facebook,
                                    controller.facebookCtrl.text,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Obx(
                    () => controller.isEditing.value
                        ? CustomButton(
                            label: 'profile_save_btn'.tr,
                            onTap: controller.saveChanges,
                            isLoading: controller.isSaving.value,
                          )
                        : const SizedBox(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, bool isDark) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: isDark
          ? const LinearGradient(
              colors: [AppColors.darkBg, AppColors.darkSurface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : null,
      color: isDark ? null : AppColors.lightCard,
    ),
    padding: const EdgeInsets.symmetric(vertical: 30),
    child: Column(
      children: [
        Obx(
          () => ProfileAvatar(
            image: controller.profileImage.value,
            fallbackLetter: controller.nameCtrl.text.isNotEmpty
                ? controller.nameCtrl.text[0]
                : 'ش',
            size: 88,
            editable: controller.isEditing.value,
            onEdit: controller.pickProfileImage,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          controller.nameCtrl.text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'profile_company_type'.tr,
          style: const TextStyle(fontSize: 13, color: AppColors.grey),
        ),
      ],
    ),
  );

  Widget _sectionCard(
    BuildContext context,
    bool isDark,
    String title,
    List<Widget> children,
  ) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: isDark ? AppColors.darkCardGradient : null,
      color: isDark ? null : AppColors.lightCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const Divider(height: 20),
        ...children,
      ],
    ),
  );

  Widget _contactRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.darkPrimary),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 13)),
    ],
  );
}
