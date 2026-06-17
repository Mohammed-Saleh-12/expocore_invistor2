import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/reset_password_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../../view/widget/Home/expocore_logo.dart';
import '../../controllers/web_auth_controller.dart';
import '../../models/web_theme.dart';
import '../widgets/web_fade_in.dart';

// ════════════════════════════════════════════════════════════
//  WebResetPasswordPage  —  View فقط (MVC)
//  يُعرض عندما يفتح المستخدم رابط الاستعادة من البريد الإلكتروني
//  Token مُحقَّن مسبقاً في ResetPasswordController بواسطة WebAuthController
// ════════════════════════════════════════════════════════════
class WebResetPasswordPage extends StatelessWidget {
  const WebResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c    = Get.find<ResetPasswordController>();
    final wide = MediaQuery.of(context).size.width >= 1000;

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
                    child: Obx(() => c.done.value
                        ? _DonePanel(c: c)
                        : _ResetForm(c: c)),
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

// ── Brand side ──────────────────────────────────────────────
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
          Positioned(top: -80, left: -60, child: _blob(300, WebTheme.primary.withOpacity(0.25))),
          Positioned(bottom: -60, right: -40, child: _blob(240, WebTheme.secondary.withOpacity(0.2))),
          Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: WebTheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: WebTheme.primary.withOpacity(0.4), blurRadius: 30)],
                      ),
                      child: const ExpocoreLogo(size: 56),
                    ),
                    const SizedBox(width: 16),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 3),
                        children: [
                          TextSpan(text: 'EXPO', style: TextStyle(color: WebTheme.secondary)),
                          TextSpan(text: 'CORE', style: TextStyle(color: WebTheme.accent)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ShaderMask(
                  shaderCallback: (b) => AppColors.favoriteGradient.createShader(b),
                  child: Text(
                    'reset_brand_title'.tr,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                      color: WebTheme.text,
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
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c,
          boxShadow: [BoxShadow(color: c, blurRadius: 120, spreadRadius: 40)],
        ),
      );
}

// ── Form panel ───────────────────────────────────────────────
class _ResetForm extends StatelessWidget {
  final ResetPasswordController c;
  const _ResetForm({required this.c});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon ──────────────────────────────────────────
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.favoriteGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: WebTheme.primary.withOpacity(0.4), blurRadius: 20)],
            ),
            child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 20),

          // ── Title & hint ──────────────────────────────────
          Text(
            'reset_title'.tr,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: WebTheme.text),
          ),
          const SizedBox(height: 6),
          Text(
            'reset_hint'.tr,
            style: TextStyle(fontSize: 14, color: AppColors.grey.withOpacity(0.85), height: 1.6),
          ),
          const SizedBox(height: 32),

          // ── Invalid / missing token warning ───────────────
          Obx(() {
            if (c.hasToken) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'reset_invalid_link'.tr,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── New password ──────────────────────────────────
          _label('reset_new_password'.tr),
          const SizedBox(height: 8),
          Obx(() => _field(
                controller: c.passwordCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: c.obscurePass.value,
                suffix: _eyeBtn(c.obscurePass.value, c.togglePass),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'field_required'.tr;
                  if (v.length < 8) return 'reset_password_min'.tr;
                  return null;
                },
              )),
          const SizedBox(height: 18),

          // ── Confirm password ──────────────────────────────
          _label('reset_confirm_label'.tr),
          const SizedBox(height: 8),
          Obx(() => _field(
                controller: c.confirmCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: c.obscureConf.value,
                suffix: _eyeBtn(c.obscureConf.value, c.toggleConf),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'field_required'.tr;
                  if (v != c.passwordCtrl.text) return 'register_mismatch'.tr;
                  return null;
                },
              )),
          const SizedBox(height: 28),

          // ── Submit ────────────────────────────────────────
          Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: _GradientButton(
                  loading: c.status.value == StatusRequest.loading,
                  onTap: c.resetPassword,
                  label: 'reset_btn'.tr,
                ),
              )),
          const SizedBox(height: 20),

          // ── Back to login ─────────────────────────────────
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

// ── Success panel ────────────────────────────────────────────
class _DonePanel extends StatelessWidget {
  final ResetPasswordController c;
  const _DonePanel({required this.c});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.success),
          ),
          const SizedBox(height: 24),
          Text(
            'reset_done_title'.tr,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: WebTheme.text),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'reset_done_desc'.tr,
            style: TextStyle(fontSize: 14, color: AppColors.grey.withOpacity(0.85), height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: _GradientButton(
              loading: false,
              onTap: () {
                c.clear();
                WebAuthController.to.goToLogin();
              },
              label: 'forgot_back_login'.tr,
            ),
          ),
        ],
      );
}

// ── Gradient button ──────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  final String label;
  const _GradientButton({required this.loading, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.favoriteGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: WebTheme.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(label, style: TextStyle(color: WebTheme.text, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
