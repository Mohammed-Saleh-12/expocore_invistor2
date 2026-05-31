import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/register_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../widget/Home/custom_button.dart';
import '../../widget/Home/custom_text_field.dart';
import '../../widget/Home/custom_app_bar.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'إنشاء حساب مستثمر'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              CustomTextField(controller: controller.companyCtrl, hint: 'اسم الشركة', prefixIcon: Icons.business_outlined,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 14),
              CustomTextField(controller: controller.tradeCtrl, hint: 'المجال التجاري', prefixIcon: Icons.category_outlined),
              const SizedBox(height: 14),
              CustomTextField(controller: controller.emailCtrl, hint: 'البريد الإلكتروني', prefixIcon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
                const SizedBox(height: 14),
              CustomTextField(controller: controller.emailCtrl, hint: 'مقر الشركة', prefixIcon: Icons.location_on_outlined,
                keyboard: TextInputType.text, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 14),
              CustomTextField(controller: controller.phoneCtrl, hint: 'رقم الجوال', prefixIcon: Icons.phone_outlined,
                keyboard: TextInputType.phone),
              const SizedBox(height: 14),
              CustomTextField(controller: controller.websiteCtrl, hint: 'الموقع الإلكتروني (اختياري)', prefixIcon: Icons.language_outlined),
              const SizedBox(height: 14),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.activityType.value.isEmpty ? null : controller.activityType.value,
                hint: const Text('نوع النشاط', style: TextStyle(color: AppColors.grey)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: controller.activityTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => controller.activityType.value = v ?? '',
              )),
              const SizedBox(height: 14),
              Obx(() => CustomTextField(
                controller: controller.passCtrl, hint: 'كلمة المرور', prefixIcon: Icons.lock_outline,
                obscure: controller.obscurePass.value,
                validator: (v) => (v?.length ?? 0) < 6 ? 'يجب أن تكون 6 أحرف على الأقل' : null,
                suffixWidget: GestureDetector(onTap: () => controller.obscurePass.toggle(),
                  child: Icon(controller.obscurePass.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.grey)),
              )),
              const SizedBox(height: 14),
              Obx(() => CustomTextField(
                controller: controller.confirmCtrl, hint: 'تأكيد كلمة المرور', prefixIcon: Icons.lock_outline,
                obscure: controller.obscureConf.value,
                validator: (v) => v != controller.passCtrl.text ? 'كلمتا المرور غير متطابقتين' : null,
                suffixWidget: GestureDetector(onTap: () => controller.obscureConf.toggle(),
                  child: Icon(controller.obscureConf.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.grey)),
              )),
              const SizedBox(height: 16),
              Obx(() => Row(children: [
                Checkbox(
                  value: controller.termsAccepted.value,
                  onChanged: (_) => controller.termsAccepted.toggle(),
                  activeColor: AppColors.darkPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                const Text('أوافق على ', style: TextStyle(fontSize: 13)),
                const Text('الشروط والأحكام', style: TextStyle(fontSize: 13, color: AppColors.darkPrimary, fontWeight: FontWeight.w600)),
              ])),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                label: 'إنشاء حساب',
                onTap: controller.register,
                isLoading: controller.status.value == StatusRequest.loading,
              )),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
