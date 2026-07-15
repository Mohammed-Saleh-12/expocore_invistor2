import 'package:expocore_invistor2/core/class/StatusRequest.dart';
import 'package:expocore_invistor2/core/functions/ValidInput.dart';
import 'package:expocore_invistor2/view/widget/Home/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/forgot_password_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../widget/Home/custom_app_bar.dart';
import '../../widget/Home/custom_button.dart';

// ════════════════════════════════════════════════════════════
//  ForgotPasswordView  —  View فقط (MVC)
//  كل المنطق في ForgotPasswordController
// ════════════════════════════════════════════════════════════
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ForgotPasswordController>();
    return Scaffold(
      appBar: CustomAppBar(title: 'forgot_title'.tr),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() => c.sent.value ? _SentView(c: c) : _FormView(c: c)),
      ),
    );
  }
}

// ── Form view ────────────────────────────────────────────────
class _FormView extends StatelessWidget {
  final ForgotPasswordController c;
  const _FormView({required this.c});

  @override
  Widget build(BuildContext context) => Form(
        key: c.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock_reset, size: 64, color: AppColors.darkPrimary),
            const SizedBox(height: 20),
            Text(
              'forgot_hint'.tr,
              style: const TextStyle(fontSize: 14, color: AppColors.grey, height: 1.6),
            ),
            const SizedBox(height: 30),
            AppTextField(
              label: 'البريد الإلكتروني',
                  controller:c.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: ValidInput.email,
                
            ),
            const SizedBox(height: 24),
            Obx(() => CustomButton(
                  label: 'forgot_btn'.tr,
                  onTap: c.sendResetLink,
                  isLoading: c.status.value == StatusRequest.loading,
                )),
          ],
        ),
      );
}

// ── Sent confirmation view ───────────────────────────────────
class _SentView extends StatelessWidget {
  final ForgotPasswordController c;
  const _SentView({required this.c});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 80, color: AppColors.success),
            const SizedBox(height: 20),
            Text(
              'forgot_sent_title'.tr,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'forgot_sent_desc'.tr,
              style: const TextStyle(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: 'forgot_back_login'.tr,
              onTap: () {
                c.reset();
                Get.back();
              },
            ),
          ],
        ),
      );
}
