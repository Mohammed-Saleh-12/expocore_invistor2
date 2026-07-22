import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/auth_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../widget/auth/otp_field_row.dart';
import '../../widget/Home/custom_button.dart';

// ════════════════════════════════════════════════════════════
//  _OtpScreenController  —  عدّاد العد التنازلي + OTP المُدخَل
//  (global: false — controller داخلي للشاشة فقط)
// ════════════════════════════════════════════════════════════
class _OtpScreenController extends GetxController {
  final otp     = ''.obs;
  final seconds = 60.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    seconds.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds.value == 0) {
        t.cancel();
        return;
      }
      seconds.value--;
    });
  }

  void updateOtp(String val) => otp.value = val;

  Future<void> resend(AuthController authCtrl) async {
    await authCtrl.resendOtp();
    otp.value = '';
    _startTimer();
  }
}

// ════════════════════════════════════════════════════════════
//  OtpScreen  —  شاشة OTP بعد التسجيل
// ════════════════════════════════════════════════════════════
class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_OtpScreenController>(
      init: _OtpScreenController(),
      global: false,
      builder: (ctrl) {
        final authCtrl = Get.find<AuthController>();

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      children: [
                        _buildHeader(context, authCtrl),
                        const SizedBox(height: 40),
                        OtpFieldRow(onCompleted: ctrl.updateOtp),
                        const SizedBox(height: 32),
                        _buildResendRow(ctrl, authCtrl),
                        const SizedBox(height: 32),
                        _buildConfirmButton(ctrl, authCtrl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: Get.back,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: context.isDarkMode
                    ? Colors.white
                    : const Color(0xFF1D1A39),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Image.asset(
                context.isDarkMode
                    ? 'assets/images/logo1.png'
                    : 'assets/images/logo.png',
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      );

  Widget _buildHeader(BuildContext context, AuthController authCtrl) => Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.darkPrimary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 40,
              color: AppColors.darkPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'التحقق من البريد الإلكتروني',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.isDarkMode
                  ? Colors.white
                  : const Color(0xFF1D1A39),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أدخل الرمز المُرسَل إلى',
            style: const TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            authCtrl.pendingEmail,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkPrimary,
            ),
          ),
        ],
      );

  Widget _buildResendRow(
          _OtpScreenController ctrl, AuthController authCtrl) =>
      Obx(() => ctrl.seconds.value > 0
          ? Text(
              'إعادة الإرسال بعد ${ctrl.seconds.value} ثانية',
              style:
                  const TextStyle(fontSize: 13, color: AppColors.grey),
            )
          : TextButton(
              onPressed: () => ctrl.resend(authCtrl),
              child: const Text(
                'إعادة إرسال الرمز',
                style: TextStyle(
                  color: AppColors.darkPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ));

  Widget _buildConfirmButton(
          _OtpScreenController ctrl, AuthController authCtrl) =>
      Obx(() => CustomButton(
            label: 'تأكيد الرمز',
            onTap: ctrl.otp.value.length < 6
                ? null
                : () => authCtrl.verifyOtp(ctrl.otp.value),
            isLoading: authCtrl.isLoading.value,
          ));
}
