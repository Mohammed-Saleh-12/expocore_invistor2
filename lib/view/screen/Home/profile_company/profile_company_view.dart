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
        title: 'الملف التعريفي',
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
                  _sectionCard(context, isDark, 'نبذة عن الشركة', [
                    Obx(
                      () => controller.isEditing.value
                          ? CustomTextField(
                              controller: controller.bioCtrl,
                              hint: 'نبذة عن الشركة',
                              maxLines: 4,
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
                  _sectionCard(context, isDark, 'بيانات الاتصال', [
                    Obx(
                      () => controller.isEditing.value
                          ? Column(
                              children: [
                                CustomTextField(
                                  controller: controller.locationCtrl,
                                  hint: 'مقر الشركة ',
                                  prefixIcon: Icons.location_on_outlined,
                                ),
                                const SizedBox(height: 10),
                                CustomTextField(
                                  controller: controller.emailCtrl,
                                  hint: 'البريد الإلكتروني',
                                  prefixIcon: Icons.email_outlined,
                                ),
                                const SizedBox(height: 10),
                                CustomTextField(
                                  controller: controller.phoneCtrl,
                                  hint: 'رقم الجوال',
                                  prefixIcon: Icons.phone_outlined,
                                ),
                                const SizedBox(height: 10),
                                CustomTextField(
                                  controller: controller.websiteCtrl,
                                  hint: 'الموقع الإلكتروني',
                                  prefixIcon: Icons.language_outlined,
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
                  _sectionCard(context, isDark, 'التواصل الاجتماعي', [
                    Obx(() => controller.isEditing.value
                        ? Column(
                            children: [
                              CustomTextField(controller: controller.linkedinCtrl, hint: 'LinkedIn', prefixIcon: Icons.link),
                              const SizedBox(height: 10),
                              CustomTextField(controller: controller.twitterCtrl, hint: 'X (Twitter)', prefixIcon: Icons.alternate_email),
                              const SizedBox(height: 10),
                              CustomTextField(controller: controller.instagramCtrl, hint: 'Instagram', prefixIcon: Icons.camera_alt_outlined),
                              const SizedBox(height: 10),
                              CustomTextField(controller: controller.facebookCtrl, hint: 'Facebook', prefixIcon: Icons.facebook),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (controller.linkedinCtrl.text.isNotEmpty)
                                _contactRow(Icons.link, controller.linkedinCtrl.text),
                              if (controller.twitterCtrl.text.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _contactRow(Icons.alternate_email, controller.twitterCtrl.text),
                              ],
                              if (controller.instagramCtrl.text.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _contactRow(Icons.camera_alt_outlined, controller.instagramCtrl.text),
                              ],
                              if (controller.facebookCtrl.text.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _contactRow(Icons.facebook, controller.facebookCtrl.text),
                              ],
                            ],
                          )),
                  ]),
                  const SizedBox(height: 20),
                  Obx(
                    () => controller.isEditing.value
                        ? CustomButton(
                            label: 'حفظ التغييرات',
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
        Obx(() => ProfileAvatar(
              image: controller.profileImage.value,
              fallbackLetter: controller.nameCtrl.text.isNotEmpty
                  ? controller.nameCtrl.text[0]
                  : 'ش',
              size: 88,
              editable: controller.isEditing.value,
              onEdit: controller.pickProfileImage,
            )),
        const SizedBox(height: 12),
        Text(
          controller.nameCtrl.text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'شركة تقنية رائدة',
          style: TextStyle(fontSize: 13, color: AppColors.grey),
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
