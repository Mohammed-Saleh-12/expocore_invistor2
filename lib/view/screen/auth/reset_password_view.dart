import 'package:expocore_invistor2/core/functions/ValidInput.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/reset_password_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../widget/Home/custom_app_bar.dart';
import '../../widget/Home/custom_button.dart';
import '../../widget/Home/custom_text_field.dart';


class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ResetPasswordController>();
    return Scaffold(
      appBar: CustomAppBar(title: 'reset_title'.tr),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() => c.done.value ? _DoneView(c: c) : _FormView(c: c)),
      ),
    );
  }
}

// ── Form view ────────────────────────────────────────────────
class _FormView extends StatelessWidget {
  final ResetPasswordController c;
  const _FormView({required this.c});

  @override
  Widget build(BuildContext context) => Form(
        key: c.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock_open_rounded, size: 64, color: AppColors.darkPrimary),
            const SizedBox(height: 20),
            Text(
              'reset_hint'.tr,
              style: const TextStyle(fontSize: 14, color: AppColors.grey, height: 1.6),
            ),
            const SizedBox(height: 30),

            // ── New password ──────────────────────────────
            Obx(() => AppTextField(
                  label: 'كلمة المرور الجديدة',
                  controller:c.passwordCtrl,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: ValidInput.password,
                )),
            const SizedBox(height: 16),

            // ── Confirm password ──────────────────────────
            Obx(() => AppTextField(
                    label: 'تأكيد كلمة المرور',
                  controller: c.confirmCtrl,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'يرجى تأكيد كلمة المرور';
                    }
                    if (val !=c.passwordCtrl.text) {
                      return 'كلمتا المرور غير متطابقتين';
                    }
                    return null;
                  },
                )),
            const SizedBox(height: 28),

            Obx(() => CustomButton(
                  label: 'reset_btn'.tr,
                  onTap: c.resetPassword,
                  isLoading: c.status.value == StatusRequest.loading,
                )),
          ],
        ),
      );
}

// ── Success view ─────────────────────────────────────────────
class _DoneView extends StatelessWidget {
  final ResetPasswordController c;
  const _DoneView({required this.c});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 80, color: AppColors.success),
            const SizedBox(height: 20),
            Text(
              'reset_done_title'.tr,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'reset_done_desc'.tr,
              style: const TextStyle(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: 'forgot_back_login'.tr,
              onTap: c.goToLoginMobile,
            ),
          ],
        ),
      );
}
