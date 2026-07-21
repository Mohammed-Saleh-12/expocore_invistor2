import 'package:expocore_invistor2/core/functions/ValidInput.dart';
import 'package:expocore_invistor2/view/widget/Home/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/register_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../widget/Home/custom_button.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildFormCard(context),
                      const SizedBox(height: 20),
                      _buildLoginRow(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar with back + logo ──────────────────────────────
  Widget _buildTopBar(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Row(
      children: [
        IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: context.isDarkMode ? Colors.white : const Color(0xFF1D1A39),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset(
            context.isDarkMode
                ? 'assets/images/logo1.png'
                : 'assets/images/logo.png',
            height: 38,
            fit: BoxFit.contain,
          ),
        ),
      ],
    ),
  );

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) => Column(
    children: [
      Text(
        'register_title'.tr,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: context.isDarkMode ? Colors.white : const Color(0xFF1D1A39),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'register_subtitle'.tr,
        style: TextStyle(fontSize: 13, color: AppColors.grey.withOpacity(0.9)),
      ),
    ],
  );

  // ── Form card ─────────────────────────────────────────────
  Widget _buildFormCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: context.isDarkMode ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: AppColors.darkPrimary.withOpacity(0.25),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkBg.withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(context, 'register_company_info'.tr),
        const SizedBox(height: 14),

        // Company name
        AppTextField(
          controller: controller.companyCtrl,
          prefixIcon: const Icon(Icons.business_outlined, size: 18),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'field_required'.tr : null,
          label: 'register_company'.tr,
        ),
        const SizedBox(height: 12),

        // Trade name
        AppTextField(
          controller: controller.tradeCtrl,
          prefixIcon: const Icon(Icons.category_outlined, size: 18),
          label: 'register_trade'.tr,
        ),
        const SizedBox(height: 12),

        // Location
        AppTextField(
          controller: controller.locationCtrl,
          prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'field_required'.tr : null,
          label: 'register_location'.tr,
        ),
        const SizedBox(height: 12),

        // Activity type dropdown
        Obx(() => _buildDropdown(context)),
        const SizedBox(height: 24),

        _sectionLabel(context, 'register_contact_info'.tr),
        const SizedBox(height: 14),

        // Email
        AppTextField(
          label: 'البريد الإلكتروني *',
          controller: controller.emailCtrl,
          keyboardType: TextInputType.emailAddress,
          validator: ValidInput.email,
          prefixIcon: const Icon(Icons.email_outlined, size: 18),
        ),
        const SizedBox(height: 12),

        // Phone
        AppTextField(
          label: 'رقم الجوال',
          controller: controller.phoneCtrl,
          keyboardType: TextInputType.phone,
          validator: ValidInput.phone,
          prefixIcon: const Icon(Icons.phone_outlined, size: 18),
        ),

        const SizedBox(height: 12),

        // Website
        AppTextField(
          controller: controller.websiteCtrl,
          prefixIcon: const Icon(Icons.language_outlined, size: 18),
          label: 'register_website'.tr,
        ),
        const SizedBox(height: 24),

        _sectionLabel(context, 'login_password'.tr),
        const SizedBox(height: 14),

        // Password
        AppTextField(
          label: 'كلمة السر *',
          controller: controller.passCtrl,
          isPassword: true,
          validator: ValidInput.password,
          prefixIcon: const Icon(Icons.lock_outline, size: 18),
        ),

        const SizedBox(height: 12),

        // Confirm password
        AppTextField(
          label: 'تأكيد كلمة السر *',
          controller: controller.confirmCtrl,
          isPassword: true,
          validator: (v) {
            if (v != controller.passCtrl.text) {
              return 'كلمتا السر غير متطابقتين';
            }
            return null;
          },
          prefixIcon: const Icon(Icons.lock_outline, size: 18),
        ),

        const SizedBox(height: 20),

        // Terms
        Obx(
          () => GestureDetector(
            onTap: () => controller.termsAccepted.toggle(),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: controller.termsAccepted.value
                        ? AppColors.favoriteGradient
                        : null,
                    border: Border.all(
                      color: controller.termsAccepted.value
                          ? Colors.transparent
                          : AppColors.grey.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: controller.termsAccepted.value
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  '${'register_agree'.tr} ',
                  style: const TextStyle(fontSize: 13, color: AppColors.grey),
                ),
                Text(
                  'register_terms'.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.darkPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Register button
        Obx(
          () => CustomButton(
            label: 'register_btn'.tr,
            onTap: controller.register,
            isLoading: controller.status.value == StatusRequest.loading,
          ),
        ),
      ],
    ),
  );

  // ── Dropdown ──────────────────────────────────────────────
  Widget _buildDropdown(
    BuildContext context,
  ) => DropdownButtonFormField<String>(
    value: controller.activityType.value.isEmpty
        ? null
        : controller.activityType.value,
    hint: Text(
      'register_activity'.tr,
      style: const TextStyle(color: AppColors.grey),
    ),
    dropdownColor: context.isDarkMode ? AppColors.darkBg : Colors.white,
    decoration: InputDecoration(
      filled: true,
      fillColor: context.isDarkMode
          ? AppColors.darkBg.withOpacity(0.5)
          : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkSurface.withOpacity(0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkSurface.withOpacity(0.6)),
      ),
      prefixIcon: const Icon(Icons.business_center_outlined),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    items: controller.activityTypes
        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
        .toList(),
    onChanged: (v) => controller.activityType.value = v ?? '',
  );

  // ── Section label ─────────────────────────────────────────
  Widget _sectionLabel(BuildContext context, String text) => Row(
    children: [
      Container(
        width: 4,
        height: 16,
        decoration: BoxDecoration(
          gradient: AppColors.favoriteGradient,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: context.isDarkMode ? Colors.white : const Color(0xFF1D1A39),
        ),
      ),
    ],
  );

  // ── Login row ─────────────────────────────────────────────
  Widget _buildLoginRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        '${'register_have_account'.tr} ',
        style: const TextStyle(fontSize: 13, color: AppColors.grey),
      ),
      GestureDetector(
        onTap: () => Get.offAllNamed(AppRoutes.LOGIN),
        child: Text(
          'login_title'.tr,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.darkPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
