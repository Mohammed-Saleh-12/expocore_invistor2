import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/forgot_password_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../widget/auth/otp_field_row.dart';
import '../../widget/Home/custom_button.dart';

// ════════════════════════════════════════════════════════════
//  _ForgotOtpController  —  عدّاد + OTP (global: false)
// ════════════════════════════════════════════════════════════
class _ForgotOtpController extends GetxController {
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

  Future<void> resend(ForgotPasswordController fpCtrl) async {
    await fpCtrl.resendOtp();
    otp.value = '';
    _startTimer();
  }
}

// ════════════════════════════════════════════════════════════
//  ForgotPasswordOtpScreen  —  الخطوة 2: التحقق من OTP
// ════════════════════════════════════════════════════════════
class ForgotPasswordOtpScreen extends StatelessWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_ForgotOtpController>(
      init: _ForgotOtpController(),
      global: false,
      builder: (ctrl) {
        final fpCtrl = Get.find<ForgotPasswordController>();

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
                        _buildHeader(context, fpCtrl),
                        const SizedBox(height: 16),
                        _StepsIndicator(currentStep: 1),
                        const SizedBox(height: 32),
                        OtpFieldRow(onCompleted: ctrl.updateOtp),
                        const SizedBox(height: 32),
                        _buildResendRow(ctrl, fpCtrl),
                        const SizedBox(height: 32),
                        _buildConfirmButton(ctrl, fpCtrl),
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

  Widget _buildHeader(
          BuildContext context, ForgotPasswordController fpCtrl) =>
      Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.darkPrimary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_clock_outlined,
              size: 40,
              color: AppColors.darkPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'التحقق من الرمز',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.isDarkMode
                  ? Colors.white
                  : const Color(0xFF1D1A39),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'أدخل الرمز المُرسَل إلى',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
                fpCtrl.savedEmail.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkPrimary,
                ),
              )),
        ],
      );

  Widget _buildResendRow(
          _ForgotOtpController ctrl, ForgotPasswordController fpCtrl) =>
      Obx(() => ctrl.seconds.value > 0
          ? Text(
              'إعادة الإرسال بعد ${ctrl.seconds.value} ثانية',
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            )
          : TextButton(
              onPressed: () => ctrl.resend(fpCtrl),
              child: const Text(
                'إعادة إرسال الرمز',
                style: TextStyle(
                  color: AppColors.darkPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ));

  Widget _buildConfirmButton(
          _ForgotOtpController ctrl, ForgotPasswordController fpCtrl) =>
      Obx(() => CustomButton(
            label: 'تأكيد الرمز',
            onTap: ctrl.otp.value.length < 6
                ? null
                : () => fpCtrl.verifyOtp(ctrl.otp.value),
            isLoading: fpCtrl.isLoading.value,
          ));
}

// ════════════════════════════════════════════════════════════
//  _StepsIndicator  —  مؤشر الخطوات الثلاث
// ════════════════════════════════════════════════════════════
class _StepsIndicator extends StatelessWidget {
  final int currentStep; // 0, 1, 2
  const _StepsIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final labels = ['إدخال الإيميل', 'التحقق من الرمز', 'كلمة المرور'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active   = i == currentStep;
        final done     = i < currentStep;
        final inactive = !active && !done;
        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.success
                        : active
                            ? AppColors.darkPrimary
                            : AppColors.grey.withOpacity(0.2),
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: inactive
                                  ? AppColors.grey
                                  : Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: active
                        ? AppColors.darkPrimary
                        : done
                            ? AppColors.success
                            : AppColors.grey,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (i < 2)
              Container(
                width: 40,
                height: 2,
                margin: const EdgeInsets.only(bottom: 16),
                color: done
                    ? AppColors.success
                    : AppColors.grey.withOpacity(0.3),
              ),
          ],
        );
      }),
    );
  }
}
