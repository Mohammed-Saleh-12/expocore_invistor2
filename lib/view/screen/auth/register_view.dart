import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/register_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../widget/Home/custom_button.dart';
import '../../widget/Home/custom_text_field.dart';
import '../../widget/Home/expocore_logo.dart';

// ════════════════════════════════════════════════════════════
//  RegisterView
// ════════════════════════════════════════════════════════════
class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        _buildHeader(),
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
      ),
    );
  }

  // ── Top bar with back + logo ──────────────────────────────
  Widget _buildTopBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
            ),
            const Spacer(),
            const ExpocoreLogo(size: 30),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2),
                children: [
                  TextSpan(text: 'EXPO', style: TextStyle(color: AppColors.darkSecondary)),
                  TextSpan(text: 'CORE', style: TextStyle(color: AppColors.darkAccent)),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      );

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() => Column(
        children: [
          Text(
            'register_title'.tr,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
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
          color: AppColors.darkCard.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.darkPrimary.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(color: AppColors.darkBg.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('register_company_info'.tr),
            const SizedBox(height: 14),

            // Company name
            CustomTextField(
              controller: controller.companyCtrl,
              hint: 'register_company'.tr,
              prefixIcon: Icons.business_outlined,
              validator: (v) => (v == null || v.isEmpty) ? 'field_required'.tr : null,
            ),
            const SizedBox(height: 12),

            // Trade name
            CustomTextField(
              controller: controller.tradeCtrl,
              hint: 'register_trade'.tr,
              prefixIcon: Icons.category_outlined,
            ),
            const SizedBox(height: 12),

            // Location
            CustomTextField(
              controller: controller.locationCtrl,
              hint: 'register_location'.tr,
              prefixIcon: Icons.location_on_outlined,
              validator: (v) => (v == null || v.isEmpty) ? 'field_required'.tr : null,
            ),
            const SizedBox(height: 12),

            // Activity type dropdown
            Obx(() => _buildDropdown(context)),
            const SizedBox(height: 24),

            _sectionLabel('register_contact_info'.tr),
            const SizedBox(height: 14),

            // Email
            CustomTextField(
              controller: controller.emailCtrl,
              hint: 'login_email'.tr,
              prefixIcon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'field_required'.tr;
                if (!GetUtils.isEmail(v.trim())) return 'login_email_invalid'.tr;
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Phone
            CustomTextField(
              controller: controller.phoneCtrl,
              hint: 'register_phone'.tr,
              prefixIcon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            // Website
            CustomTextField(
              controller: controller.websiteCtrl,
              hint: 'register_website'.tr,
              prefixIcon: Icons.language_outlined,
            ),
            const SizedBox(height: 24),

            _sectionLabel('login_password'.tr),
            const SizedBox(height: 14),

            // Password
            Obx(() => CustomTextField(
              controller: controller.passCtrl,
              hint: 'login_password'.tr,
              prefixIcon: Icons.lock_outline_rounded,
              obscure: controller.obscurePass.value,
              validator: (v) => (v?.length ?? 0) < 6 ? 'register_password_len'.tr : null,
              suffixWidget: GestureDetector(
                onTap: () => controller.obscurePass.toggle(),
                child: Icon(
                  controller.obscurePass.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20, color: AppColors.grey,
                ),
              ),
            )),
            const SizedBox(height: 12),

            // Confirm password
            Obx(() => CustomTextField(
              controller: controller.confirmCtrl,
              hint: 'register_confirm'.tr,
              prefixIcon: Icons.lock_outline_rounded,
              obscure: controller.obscureConf.value,
              validator: (v) => v != controller.passCtrl.text ? 'register_mismatch'.tr : null,
              suffixWidget: GestureDetector(
                onTap: () => controller.obscureConf.toggle(),
                child: Icon(
                  controller.obscureConf.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20, color: AppColors.grey,
                ),
              ),
            )),
            const SizedBox(height: 20),

            // Terms
            Obx(() => GestureDetector(
              onTap: () => controller.termsAccepted.toggle(),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: controller.termsAccepted.value ? AppColors.favoriteGradient : null,
                      border: Border.all(
                        color: controller.termsAccepted.value
                            ? Colors.transparent
                            : AppColors.grey.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: controller.termsAccepted.value
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text('${'register_agree'.tr} ', style: const TextStyle(fontSize: 13, color: AppColors.grey)),
                  Text(
                    'register_terms'.tr,
                    style: const TextStyle(fontSize: 13, color: AppColors.darkPrimary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),

            // Register button
            Obx(() => CustomButton(
              label: 'register_btn'.tr,
              onTap: controller.register,
              isLoading: controller.status.value == StatusRequest.loading,
            )),
          ],
        ),
      );

  // ── Dropdown ──────────────────────────────────────────────
  Widget _buildDropdown(BuildContext context) => DropdownButtonFormField<String>(
        value: controller.activityType.value.isEmpty ? null : controller.activityType.value,
        hint: Text('register_activity'.tr, style: const TextStyle(color: AppColors.grey)),
        dropdownColor: AppColors.darkSurface,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.darkBg.withOpacity(0.5),
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
  Widget _sectionLabel(String text) => Row(
        children: [
          Container(
            width: 4, height: 16,
            decoration: BoxDecoration(
              gradient: AppColors.favoriteGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      );

  // ── Login row ─────────────────────────────────────────────
  Widget _buildLoginRow() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${'register_have_account'.tr} ', style: const TextStyle(fontSize: 13, color: AppColors.grey)),
          GestureDetector(
            onTap: () => Get.offAllNamed(AppRoutes.LOGIN),
            child: Text(
              'login_title'.tr,
              style: const TextStyle(fontSize: 13, color: AppColors.darkPrimary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
}
