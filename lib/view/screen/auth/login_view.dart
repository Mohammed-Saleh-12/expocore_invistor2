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
    Get.put(LoginController());
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.darkCTAGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'EC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'مرحباً بعودتك',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'سجّل الدخول لإدارة معارضك وأجنحتك',
                style: TextStyle(fontSize: 13, color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              CustomTextField(
                controller: controller.emailCtrl,
                hint: 'البريد الإلكتروني',
                prefixIcon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'أدخل البريد الإلكتروني' : null,
              ),
              const SizedBox(height: 14),
              Obx(
                () => CustomTextField(
                  controller: controller.passwordCtrl,
                  hint: 'كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscure: controller.obscure.value,
                  validator: (v) => v!.isEmpty ? 'أدخل كلمة المرور' : null,
                  suffixWidget: GestureDetector(
                    onTap: controller.toggleObscure,
                    child: Icon(
                      controller.obscure.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: (_) => controller.toggleRemember(),
                      activeColor: AppColors.darkPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Text('تذكرني', style: TextStyle(fontSize: 13)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.FORGOT_PW),
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        color: AppColors.darkPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(
                () => CustomButton(
                  label: 'تسجيل الدخول',
                  onTap: controller.login,
                  isLoading: controller.status.value == StatusRequest.loading,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'أو',
                      style: TextStyle(color: AppColors.grey.withOpacity(0.7)),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialBtn(icon: Icons.g_mobiledata, label: 'Google'),
                  const SizedBox(width: 12),
                  _SocialBtn(icon: Icons.apple, label: 'Apple'),
                  const SizedBox(width: 12),
                  _SocialBtn(icon: Icons.facebook, label: 'Facebook'),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ليس لديك حساب؟ ',
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.REGISTER),
                    child: const Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SocialBtn({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () {},
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: AppColors.darkSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
    icon: Icon(icon, size: 20),
    label: Text(label, style: const TextStyle(fontSize: 12)),
  );
}
