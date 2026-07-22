import 'package:expocore_invistor2/core/functions/ValidInput.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/forgot_password_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../widget/Home/custom_app_bar.dart';
import '../../widget/Home/custom_button.dart';
import '../../widget/Home/custom_text_field.dart';

// ════════════════════════════════════════════════════════════
//  ResetPasswordView  —  الخطوة 3: كلمة المرور الجديدة
//  يستخدم ForgotPasswordController (savedEmail + savedOtp محفوظان)
// ════════════════════════════════════════════════════════════
class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ForgotPasswordController>();
    final passwordCtrl = TextEditingController();
    final confirmCtrl  = TextEditingController();
    final formKey      = GlobalKey<FormState>();

    return Scaffold(
      appBar: CustomAppBar(title: 'reset_title'.tr),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _FormView(
          c: c,
          passwordCtrl: passwordCtrl,
          confirmCtrl: confirmCtrl,
          formKey: formKey,
        ),
      ),
    );
  }
}

// ── Form view ────────────────────────────────────────────────
class _FormView extends StatelessWidget {
  final ForgotPasswordController c;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final GlobalKey<FormState> formKey;

  const _FormView({
    required this.c,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.lock_open_rounded,
                  size: 64, color: AppColors.darkPrimary),
              const SizedBox(height: 20),
              Text(
                'reset_hint'.tr,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.grey, height: 1.6),
              ),
              const SizedBox(height: 30),

              // ── كلمة المرور الجديدة ───────────────────────
              AppTextField(
                label: 'كلمة المرور الجديدة',
                controller: passwordCtrl,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                validator: ValidInput.password,
              ),
              const SizedBox(height: 16),

              // ── تأكيد كلمة المرور ─────────────────────────
              AppTextField(
                label: 'تأكيد كلمة المرور',
                controller: confirmCtrl,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'يرجى تأكيد كلمة المرور';
                  }
                  if (val != passwordCtrl.text) {
                    return 'كلمتا المرور غير متطابقتين';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── متطلبات كلمة المرور (live feedback) ───────
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: passwordCtrl,
                builder: (_, value, __) {
                  final p = value.text;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RequirementRow(
                          '8 أحرف على الأقل', p.length >= 8),
                      _RequirementRow(
                          'حرف كبير واحد على الأقل',
                          p.contains(RegExp(r'[A-Z]'))),
                      _RequirementRow(
                          'رقم واحد على الأقل',
                          p.contains(RegExp(r'[0-9]'))),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // ── زر الحفظ ──────────────────────────────────
              Obx(() => CustomButton(
                    label: 'reset_btn'.tr,
                    onTap: c.isLoading.value
                        ? null
                        : () {
                            if (formKey.currentState?.validate() ?? false) {
                              c.resetPassword(
                                passwordCtrl.text.trim(),
                                confirmCtrl.text.trim(),
                              );
                            }
                          },
                    isLoading: c.status.value == StatusRequest.loading,
                  )),
            ],
          ),
        ),
      );
}

// ── صف متطلب واحد ────────────────────────────────────────────
class _RequirementRow extends StatelessWidget {
  final String text;
  final bool met;
  const _RequirementRow(this.text, this.met);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(
              met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              size: 16,
              color: met ? AppColors.success : AppColors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: met ? AppColors.success : AppColors.grey,
              ),
            ),
          ],
        ),
      );
}
