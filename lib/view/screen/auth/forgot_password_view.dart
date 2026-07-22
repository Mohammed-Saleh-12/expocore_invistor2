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
//  ForgotPasswordView  —  الخطوة 0: إدخال الإيميل
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
        child: _FormView(c: c),
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
              style: const TextStyle(
                  fontSize: 14, color: AppColors.grey, height: 1.6),
            ),
            const SizedBox(height: 16),

            // ── بانر الجلسة المعلّقة ───────────────────────
            Obx(() {
              if (!c.hasPendingSession) return const SizedBox.shrink();
              return _PendingSessionBanner(c: c);
            }),

            const SizedBox(height: 16),

            // ── حقل البريد الإلكتروني ─────────────────────
            AppTextField(
              label: 'البريد الإلكتروني',
              controller: c.emailFormCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              validator: ValidInput.email,
            ),
            const SizedBox(height: 24),

            // ── زر إرسال OTP ───────────────────────────────
            Obx(() => CustomButton(
                  label: 'إرسال رمز التحقق',
                  onTap: c.isLoading.value
                      ? null
                      : () {
                          if (c.formKey.currentState?.validate() ?? false) {
                            c.sendOtp(c.emailFormCtrl.text.trim());
                          }
                        },
                  isLoading: c.status.value == StatusRequest.loading,
                )),
          ],
        ),
      );
}

// ── بانر الجلسة المعلّقة ─────────────────────────────────────
class _PendingSessionBanner extends StatelessWidget {
  final ForgotPasswordController c;
  const _PendingSessionBanner({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.darkPrimary.withOpacity(0.35), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.darkPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يوجد طلب استعادة سابق لـ ${c.savedEmail.value}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.darkPrimary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: c.resumePendingSession,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.darkPrimary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('استكمال',
                        style: TextStyle(
                            color: AppColors.darkPrimary,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: c.discardSession,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.grey.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('تجاهل',
                        style: TextStyle(color: AppColors.grey)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
