import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controller/auth/auth_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_auth_controller.dart';
import '../../models/web_theme.dart';
import '../widgets/web_fade_in.dart';

// ════════════════════════════════════════════════════════════
//  WebRegisterOtpPage
//  OTP التحقق من الحساب بعد التسجيل (نسخة الويب)
//  يستخدم AuthController الذي يملك منطق Register→OTP كاملاً
// ════════════════════════════════════════════════════════════
class WebRegisterOtpPage extends StatelessWidget {
  const WebRegisterOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wide      = MediaQuery.of(context).size.width >= 1000;
    final authCtrl  = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: WebTheme.bg,
      body: Row(
        children: [
          if (wide)
            const Expanded(
              flex: 5,
              child: WebFadeIn(
                beginOffset: Offset(-0.08, 0),
                child: _OtpBrand(),
              ),
            ),
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: WebFadeIn(
                    delay: const Duration(milliseconds: 200),
                    scale: true,
                    beginOffset: const Offset(0, 0.15),
                    child: GetBuilder<_WebRegisterOtpController>(
                      init: _WebRegisterOtpController(),
                      global: false,
                      builder: (ctrl) =>
                          _OtpForm(ctrl: ctrl, authCtrl: authCtrl),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Internal timer + OTP controller ─────────────────────────
class _WebRegisterOtpController extends GetxController {
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

// ── OTP Form ─────────────────────────────────────────────────
class _OtpForm extends StatelessWidget {
  final _WebRegisterOtpController ctrl;
  final AuthController authCtrl;
  const _OtpForm({required this.ctrl, required this.authCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Icon ──────────────────────────────────────────────
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            gradient: AppColors.favoriteGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: WebTheme.primary.withOpacity(0.4),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 24),

        // ── Title ─────────────────────────────────────────────
        Text(
          'otp_title'.tr,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: WebTheme.text,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // ── Hint with email ───────────────────────────────────
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey.withOpacity(0.85),
              height: 1.6,
            ),
            children: [
              TextSpan(text: 'otp_hint'.tr),
              const TextSpan(text: ' '),
              TextSpan(
                text: authCtrl.pendingEmail,
                style: TextStyle(
                  color: WebTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // ── OTP Fields ────────────────────────────────────────
        _WebOtpRow(onCompleted: ctrl.updateOtp),
        const SizedBox(height: 32),

        // ── Resend / Timer ────────────────────────────────────
        Obx(() => ctrl.seconds.value > 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppColors.grey.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${'fotp_resend_wait'.tr} ${ctrl.seconds.value} ${'fotp_seconds'.tr}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey.withOpacity(0.7),
                    ),
                  ),
                ],
              )
            : GestureDetector(
                onTap: () => ctrl.resend(authCtrl),
                child: Text(
                  'fotp_resend'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: WebTheme.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: WebTheme.primary,
                  ),
                ),
              )),
        const SizedBox(height: 28),

        // ── Confirm button ────────────────────────────────────
        Obx(() {
          final loading = authCtrl.isLoading.value;
          final ready   = ctrl.otp.value.length == 6;
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: _GradientButton(
              loading: loading,
              disabled: !ready,
              onTap: () => authCtrl.verifyOtp(ctrl.otp.value),
              label: 'fotp_confirm'.tr,
            ),
          );
        }),
        const SizedBox(height: 20),

        // ── Back to register ──────────────────────────────────
        Center(
          child: GestureDetector(
            onTap: () {
              authCtrl.resetWebStep();
              WebAuthController.to.goToRegister();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded, color: WebTheme.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'otp_back_register'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: WebTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Web-styled OTP input row ─────────────────────────────────
class _WebOtpRow extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  const _WebOtpRow({required this.onCompleted});

  @override
  State<_WebOtpRow> createState() => _WebOtpRowState();
}

class _WebOtpRowState extends State<_WebOtpRow> {
  static const _length = 6;
  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes  = List.generate(_length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes)  f.dispose();
    super.dispose();
  }

  void _onChanged(int i, String val) {
    if (val.length == 1 && i < _length - 1) _focusNodes[i + 1].requestFocus();
    if (val.isEmpty   && i > 0)             _focusNodes[i - 1].requestFocus();
    final code = _controllers.map((c) => c.text).join();
    if (code.length == _length) widget.onCompleted(code);
    if (code.length < _length)  widget.onCompleted(code);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_length, (i) => Container(
        width: 52,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: WebTheme.text,
          ),
          onChanged: (val) => _onChanged(i, val),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: WebTheme.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WebTheme.primary.withOpacity(0.25),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: WebTheme.primary, width: 2),
            ),
          ),
        ),
      )),
    );
  }
}

// ── Brand side ───────────────────────────────────────────────
class _OtpBrand extends StatelessWidget {
  const _OtpBrand();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D0A5C), Color(0xFF1A0533), Color(0xFF0D0221)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80, left: -60,
            child: _blob(300, const Color(0xFF7A1FFF).withOpacity(0.25)),
          ),
          Positioned(
            bottom: -60, right: -40,
            child: _blob(240, const Color(0xFFFF1592).withOpacity(0.18)),
          ),
          Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // مؤشر الخطوات: تسجيل (مكتمل) → OTP (نشط)
                Row(
                  children: [
                    _stepDot(done: true),
                    _stepLine(),
                    _stepDot(active: true),
                  ],
                ),
                const SizedBox(height: 48),
                ShaderMask(
                  shaderCallback: (b) => AppColors.favoriteGradient.createShader(b),
                  child: Text(
                    'otp_brand_title'.tr,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'otp_brand_desc'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.9,
                    color: AppColors.grey.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double s, Color c) => Container(
    width: s, height: s,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: c,
      boxShadow: [BoxShadow(color: c, blurRadius: 120, spreadRadius: 40)],
    ),
  );

  Widget _stepDot({bool done = false, bool active = false}) => Container(
    width: 32, height: 32,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: done
          ? AppColors.success.withOpacity(0.2)
          : active
              ? const Color(0xFF7A1FFF).withOpacity(0.35)
              : Colors.white.withOpacity(0.08),
      border: Border.all(
        color: done
            ? AppColors.success
            : active
                ? const Color(0xFF7A1FFF)
                : Colors.white.withOpacity(0.2),
        width: 2,
      ),
    ),
    child: Icon(
      done ? Icons.check : Icons.circle,
      size: done ? 16 : 8,
      color: done
          ? AppColors.success
          : active
              ? const Color(0xFF7A1FFF)
              : Colors.white.withOpacity(0.3),
    ),
  );

  Widget _stepLine() => Expanded(
    child: Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: Colors.white.withOpacity(0.15),
    ),
  );
}

// ── Gradient button ──────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;
  final String label;

  const _GradientButton({
    required this.loading,
    required this.onTap,
    required this.label,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = !loading && !disabled;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedOpacity(
        opacity: active ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.favoriteGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: WebTheme.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
