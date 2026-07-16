import 'package:expocore_invistor2/controller/auth/change_password_controller.dart';
import 'package:expocore_invistor2/core/constant/appcolors.dart';
import 'package:expocore_invistor2/core/functions/ValidInput.dart';
import 'package:expocore_invistor2/view/widget/Home/custom_button.dart';
import 'package:expocore_invistor2/view/widget/Home/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChangePasswordController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
   final currentCtrl = TextEditingController();
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تغيير كلمة المرور',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: Get.back,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // ── Icon ──────────────────────────────────────
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: AppColors.favoriteGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'أدخل كلمة مرورك الحالية ثم اختر\nكلمة مرور جديدة قوية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.grey,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 32),

                const _SectionLabel(
                  label: 'كلمة المرور الحالية',
                ),

                const SizedBox(height: 8),

                // ── Current Password ───────────────────────────
                AppTextField(
                  label: 'كلمة المرور الحالية',
                  controller: currentCtrl,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'يرجى إدخال كلمة مرورك الحالية';
                    }
                    if (val.length < 6) {
                      return 'كلمة المرور قصيرة جداً';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ── Divider ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.grey.withValues(alpha: 0.25),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'كلمة المرور الجديدة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: isDark
                              ? AppColors.white
                              : AppColors.lightPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.grey.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── New Password ───────────────────────────────
                AppTextField(
                  label: 'كلمة المرور الجديدة',
                  controller: newPassCtrl,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                  validator: ValidInput.password,
                ),

                const SizedBox(height: 14),

                // ── Confirm Password ───────────────────────────
                AppTextField(
                  label: 'تأكيد كلمة المرور الجديدة',
                  controller: confirmPassCtrl,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'يرجى تأكيد كلمة المرور الجديدة';
                    }
                    if (val != confirmPassCtrl.text) {
                      return 'كلمتا المرور غير متطابقتين';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // ── Submit ─────────────────────────────────────
                Obx(
                  () => AppButtonSeconde(
                    label: 'حفظ كلمة المرور الجديدة',
                    isLoading: ctrl.isLoading.value,
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        ctrl.changePassword(
                          currentPassword: currentPassCtrl.text.trim(),
                          newPassword: newPassCtrl.text.trim(),
                          confirmPassword: confirmPassCtrl.text.trim(),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                const AppButton(label: 'إلغاء'),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.white : AppColors.lightPrimary,
        ),
      ),
    );
  }
}
