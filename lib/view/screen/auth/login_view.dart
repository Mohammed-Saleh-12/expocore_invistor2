import 'package:expocore_invistor2/core/functions/ValidInput.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/login_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../widget/Home/custom_button.dart';
import '../../widget/Home/custom_text_field.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  context.isDarkMode
                      ? 'assets/images/logo3.png'
                      : 'assets/images/logo2.png',
                  height: 180,
                ),
                const SizedBox(height: 50),
                _buildFormCard(context),
                const SizedBox(height: 20),
                _buildDemoChip(),
                const SizedBox(height: 20),
                _buildRegisterRow(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Glass form card ───────────────────────────────────────
  Widget _buildFormCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: context.isDarkMode ? AppColors.darkCard : Colors.white,
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
        Text(
          'login_title'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.isDarkMode ? Colors.white : const Color(0xFF1D1A39),
          ),
        ),

        const SizedBox(height: 24),

        // Email field
        AppTextField(
          label: 'البريد الإلكتروني',
          controller: controller.emailCtrl,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined, size: 20),
          validator: ValidInput.email,
        ),
        const SizedBox(height: 14),

        // Password field
        AppTextField(
          label: 'كلمة السر',
          controller: controller.passwordCtrl,
          isPassword: true,
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          validator: ValidInput.password,
        ),

        const SizedBox(height: 10),

        // Remember me + forgot password
        Row(
          children: [
            Obx(
              () => Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: controller.rememberMe.value,
                  onChanged: (_) => controller.toggleRemember(),
                  activeColor: AppColors.darkPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(color: AppColors.grey.withOpacity(0.5)),
                ),
              ),
            ),
            Text(
              'login_remember'.tr,
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.FORGOT_PW),
              child: Text(
                'login_forgot'.tr,
                style: const TextStyle(
                  color: AppColors.darkPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Login button
        Obx(
          () => CustomButton(
            label: 'login_btn'.tr,
            onTap: controller.login,
            isLoading: controller.status.value == StatusRequest.loading,
          ),
        ),
      ],
    ),
  );

  // ── Demo chip ─────────────────────────────────────────────
  Widget _buildDemoChip() => GestureDetector(
    onTap: controller.fillDemo,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkPrimary.withOpacity(0.2),
            AppColors.darkSecondary.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkPrimary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_outline_rounded,
            color: AppColors.darkPrimary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'login_demo'.tr,
            style: const TextStyle(
              color: AppColors.darkPink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  // ── Register row ──────────────────────────────────────────
  Widget _buildRegisterRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        '${'login_no_account'.tr} ',
        style: const TextStyle(fontSize: 13, color: AppColors.grey),
      ),
      GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.REGISTER),
        child: Text(
          'register_title'.tr,
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
