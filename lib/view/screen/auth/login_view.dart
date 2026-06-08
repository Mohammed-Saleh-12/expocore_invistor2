import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/login_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../widget/Home/custom_button.dart';
import '../../widget/Home/custom_text_field.dart';
import '../../widget/Home/expocore_logo.dart';
import '../../widget/Home/language_toggle.dart';

// ════════════════════════════════════════════════════════════
//  LoginView
// ════════════════════════════════════════════════════════════
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: LanguageToggle(),
                  ),
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 36),
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
      ),
    );
  }

  // ── Header: logo + title ──────────────────────────────────
  Widget _buildHeader() => Column(
        children: [
          // logo with glow background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: AppColors.darkPrimary.withOpacity(0.4), blurRadius: 30, spreadRadius: 4),
              ],
            ),
            child: const ExpocoreLogo(size: 72),
          ),
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3),
              children: [
                TextSpan(text: 'EXPO', style: TextStyle(color: AppColors.darkSecondary)),
                TextSpan(text: 'CORE', style: TextStyle(color: AppColors.darkAccent)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'login_subtitle'.tr,
            style: const TextStyle(color: AppColors.darkPink, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      );

  // ── Glass form card ───────────────────────────────────────
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
            Text(
              'login_title'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'login_enter_data'.tr,
              style: TextStyle(fontSize: 12, color: AppColors.grey.withOpacity(0.8)),
            ),
            const SizedBox(height: 24),

            // Email field
            CustomTextField(
              controller: controller.emailCtrl,
              hint: 'login_email'.tr,
              prefixIcon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'login_email_required'.tr;
                if (!GetUtils.isEmail(v.trim())) return 'login_email_invalid'.tr;
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password field
            Obx(() => CustomTextField(
              controller: controller.passwordCtrl,
              hint: 'login_password'.tr,
              prefixIcon: Icons.lock_outline_rounded,
              obscure: controller.obscure.value,
              validator: (v) => (v == null || v.isEmpty) ? 'login_password_required'.tr : null,
              suffixWidget: GestureDetector(
                onTap: controller.toggleObscure,
                child: Icon(
                  controller.obscure.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20, color: AppColors.grey,
                ),
              ),
            )),
            const SizedBox(height: 10),

            // Remember me + forgot password
            Row(
              children: [
                Obx(() => Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: controller.rememberMe.value,
                    onChanged: (_) => controller.toggleRemember(),
                    activeColor: AppColors.darkPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(color: AppColors.grey.withOpacity(0.5)),
                  ),
                )),
                Text('login_remember'.tr, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
                const Spacer(),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.FORGOT_PW),
                  child: Text(
                    'login_forgot'.tr,
                    style: const TextStyle(color: AppColors.darkPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Login button
            Obx(() => CustomButton(
              label: 'login_btn'.tr,
              onTap: controller.login,
              isLoading: controller.status.value == StatusRequest.loading,
            )),

            const SizedBox(height: 20),

            // divider
            Row(children: [
              Expanded(child: Divider(color: AppColors.grey.withOpacity(0.25))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('login_or'.tr, style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 13)),
              ),
              Expanded(child: Divider(color: AppColors.grey.withOpacity(0.25))),
            ]),
            const SizedBox(height: 20),

            // Social buttons
            Row(
              children: [
                Expanded(child: _SocialBtn(icon: Icons.g_mobiledata_rounded, label: 'Google')),
                const SizedBox(width: 10),
                Expanded(child: _SocialBtn(icon: Icons.apple_rounded, label: 'Apple')),
                const SizedBox(width: 10),
                Expanded(child: _SocialBtn(icon: Icons.facebook_rounded, label: 'Facebook')),
              ],
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
              colors: [AppColors.darkPrimary.withOpacity(0.2), AppColors.darkSecondary.withOpacity(0.15)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.darkPrimary.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline_rounded, color: AppColors.darkPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                'login_demo'.tr,
                style: const TextStyle(color: AppColors.darkPink, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );

  // ── Register row ──────────────────────────────────────────
  Widget _buildRegisterRow() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${'login_no_account'.tr} ', style: const TextStyle(fontSize: 13, color: AppColors.grey)),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.REGISTER),
            child: Text(
              'register_title'.tr,
              style: const TextStyle(fontSize: 13, color: AppColors.darkPrimary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
}

// ── Social button widget ──────────────────────────────────
class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _SocialBtn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.darkSurface.withOpacity(0.8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 11),
          backgroundColor: AppColors.darkBg.withOpacity(0.4),
        ),
        icon: Icon(icon, size: 18, color: AppColors.grey),
        label: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
      );
}
