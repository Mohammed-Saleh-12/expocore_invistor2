import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/forgot_password_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_auth_controller.dart';
import '../../models/web_theme.dart';
import '../widgets/web_fade_in.dart';

// ════════════════════════════════════════════════════════════
//  WebForgotPasswordResetPage
//  الخطوة 3: إدخال كلمة المرور الجديدة (OTP-based reset)
//  يستخدم ForgotPasswordController.resetPassword(email, otp, pass, confirm)
// ════════════════════════════════════════════════════════════
class WebForgotPasswordResetPage extends StatelessWidget {
  const WebForgotPasswordResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wide   = MediaQuery.of(context).size.width >= 1000;
    final fpCtrl = Get.find<ForgotPasswordController>();

    return Scaffold(
      backgroundColor: WebTheme.bg,
      body: Row(
        children: [
          if (wide)
            const Expanded(
              flex: 5,
              child: WebFadeIn(
                beginOffset: Offset(-0.08, 0),
                child: _ResetBrand(),
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
                    child: GetBuilder<_FpResetFormController>(
                      init: _FpResetFormController(),
                      global: false,
                      builder: (local) => Obx(() => local.done.value
                          ? _DonePanel(fpCtrl: fpCtrl)
                          : _ResetForm(local: local, fpCtrl: fpCtrl)),
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

// ── Local form controller ────────────────────────────────────
class _FpResetFormController extends GetxController {
  final formKey     = GlobalKey<FormState>();
  final passwordCtrl = TextEditingController();
  final confirmCtrl  = TextEditingController();
  final obscurePass = true.obs;
  final obscureConf = true.obs;
  final done        = false.obs;

  void togglePass() => obscurePass.value = !obscurePass.value;
  void toggleConf() => obscureConf.value = !obscureConf.value;

  Future<void> submit(ForgotPasswordController fpCtrl) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    await fpCtrl.resetPassword(
      passwordCtrl.text.trim(),
      confirmCtrl.text.trim(),
    );
    // webStep = 3 → WebAuthController navigates to login
    // But we also show local success panel briefly
    if (fpCtrl.status.value == StatusRequest.success) {
      done.value = true;
    }
  }

  @override
  void onClose() {
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}

// ── Reset Form ───────────────────────────────────────────────
class _ResetForm extends StatelessWidget {
  final _FpResetFormController local;
  final ForgotPasswordController fpCtrl;
  const _ResetForm({required this.local, required this.fpCtrl});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: local.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 24),

          // ── Title & hint ──────────────────────────────────────
          Text(
            'reset_title'.tr,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: WebTheme.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'reset_hint'.tr,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey.withOpacity(0.85),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),

          // ── New password ──────────────────────────────────────
          _label('reset_new_password'.tr),
          const SizedBox(height: 8),
          Obx(() => _field(
                controller: local.passwordCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: local.obscurePass.value,
                suffix: _eyeBtn(local.obscurePass.value, local.togglePass),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'field_required'.tr;
                  if (v.length < 8) return 'reset_password_min'.tr;
                  return null;
                },
              )),
          const SizedBox(height: 16),

          // ── Password requirements (live) ──────────────────────
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: local.passwordCtrl,
            builder: (_, value, __) {
              final p = value.text;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _reqRow('fotp_req_length'.tr, p.length >= 8),
                    const SizedBox(height: 4),
                    _reqRow('fotp_req_upper'.tr, p.contains(RegExp(r'[A-Z]'))),
                    const SizedBox(height: 4),
                    _reqRow('fotp_req_number'.tr, p.contains(RegExp(r'[0-9]'))),
                  ],
                ),
              );
            },
          ),

          // ── Confirm password ──────────────────────────────────
          _label('reset_confirm_label'.tr),
          const SizedBox(height: 8),
          Obx(() => _field(
                controller: local.confirmCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: local.obscureConf.value,
                suffix: _eyeBtn(local.obscureConf.value, local.toggleConf),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'field_required'.tr;
                  if (v != local.passwordCtrl.text) return 'register_mismatch'.tr;
                  return null;
                },
              )),
          const SizedBox(height: 28),

          // ── Submit ────────────────────────────────────────────
          Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: _GradientButton(
                  loading: fpCtrl.status.value == StatusRequest.loading,
                  onTap: () => local.submit(fpCtrl),
                  label: 'reset_btn'.tr,
                ),
              )),
          const SizedBox(height: 20),

          // ── Back to forgot password ───────────────────────────
          Center(
            child: GestureDetector(
              onTap: WebAuthController.to.goToLogin,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, color: WebTheme.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'forgot_back_login'.tr,
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
      ),
    );
  }

  Widget _label(String t) => Text(
    t,
    style: TextStyle(color: WebTheme.text, fontSize: 13, fontWeight: FontWeight.w600),
  );

  Widget _eyeBtn(bool obscured, VoidCallback onTap) => IconButton(
    onPressed: onTap,
    icon: Icon(
      obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      color: AppColors.grey,
      size: 20,
    ),
  );

  Widget _reqRow(String text, bool met) => Row(
    children: [
      Icon(
        met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        size: 14,
        color: met ? AppColors.success : AppColors.grey.withOpacity(0.5),
      ),
      const SizedBox(width: 6),
      Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: met ? AppColors.success : AppColors.grey.withOpacity(0.6),
        ),
      ),
    ],
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: TextStyle(color: WebTheme.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
          suffixIcon: suffix,
          filled: true,
          fillColor: WebTheme.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: WebTheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error.withOpacity(0.6), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),
      );
}

// ── Success panel ─────────────────────────────────────────────
class _DonePanel extends StatelessWidget {
  final ForgotPasswordController fpCtrl;
  const _DonePanel({required this.fpCtrl});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(height: 20),
      Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_outline_rounded,
          size: 48,
          color: AppColors.success,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'reset_done_title'.tr,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: WebTheme.text,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Text(
        'reset_done_desc'.tr,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.grey.withOpacity(0.85),
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 36),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: _GradientButton(
          loading: false,
          onTap: () {
            fpCtrl.reset();
            WebAuthController.to.goToLogin();
          },
          label: 'forgot_back_login'.tr,
        ),
      ),
    ],
  );
}

// ── Brand side ────────────────────────────────────────────────
class _ResetBrand extends StatelessWidget {
  const _ResetBrand();

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
                // Step indicator
                Row(
                  children: [
                    _stepDot(done: true),
                    _stepLine(),
                    _stepDot(done: true),
                    _stepLine(),
                    _stepDot(active: true),
                  ],
                ),
                const SizedBox(height: 48),
                ShaderMask(
                  shaderCallback: (b) => AppColors.favoriteGradient.createShader(b),
                  child: Text(
                    'reset_brand_title'.tr,
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
                  'reset_brand_desc'.tr,
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

// ── Gradient button ───────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  final String label;
  const _GradientButton({
    required this.loading,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.favoriteGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: WebTheme.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: TextStyle(
                  color: WebTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
