import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../widget/Home/custom_app_bar.dart';
import '../../widget/Home/custom_button.dart';
import '../../widget/Home/custom_text_field.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});
  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailCtrl = TextEditingController();
  bool _loading    = false;
  bool _sent       = false;

  Future<void> _send() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _loading = false; _sent = true; });
  }

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'استعادة كلمة المرور'),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: _sent ? _sentView() : _formView(),
    ),
  );

  Widget _formView() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      const Icon(Icons.lock_reset, size: 64, color: AppColors.darkPrimary),
      const SizedBox(height: 20),
      const Text('أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور.', style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.6)),
      const SizedBox(height: 30),
      CustomTextField(controller: _emailCtrl, hint: 'البريد الإلكتروني', prefixIcon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
      const SizedBox(height: 24),
      CustomButton(label: 'إرسال رابط الاستعادة', onTap: _send, isLoading: _loading),
    ],
  );

  Widget _sentView() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.mark_email_read_outlined, size: 80, color: AppColors.success),
      const SizedBox(height: 20),
      const Text('تم الإرسال!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      const Text('تحقق من بريدك الإلكتروني لإعادة تعيين كلمة المرور.', style: TextStyle(color: AppColors.grey), textAlign: TextAlign.center),
      const SizedBox(height: 30),
      CustomButton(label: 'العودة لتسجيل الدخول', onTap: () => Get.back()),
    ]),
  );
}
