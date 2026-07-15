import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/forgot_password_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_auth_controller.dart';
import '../../models/web_theme.dart';
import '../widgets/web_fade_in.dart';

class WebForgotPasswordPage extends StatelessWidget {
  const WebForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ForgotPasswordController>();
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
                child: _ForgotBrand(),
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
                    child: Obx(
                      () => c.sent.value ? _SentPanel(c: c) : _ForgotForm(c: c),
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

// ── Brand side ──────────────────────────────────────────────
class _ForgotBrand extends StatelessWidget {
  const _ForgotBrand();

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
          Padding(
            padding: const EdgeInsets.only(right: 200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  WebTheme.isDark.value
                      ? 'assets/images/logo3.png'
                      : 'assets/images/logo2.png',
                  height: 250,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Form panel ───────────────────────────────────────────────
class _ForgotForm extends StatelessWidget {
  final ForgotPasswordController c;
  const _ForgotForm({required this.c});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Icon ──────────────────────────────────────────
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
                  Icons.lock_reset_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ─────────────────────────────────────────
              Text(
                'forgot_title'.tr,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: WebTheme.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'forgot_hint'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey.withOpacity(0.85),
                  height: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('login_email'.tr),
              const SizedBox(height: 8),
              TextFormField(
                controller: c.emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: WebTheme.text),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'login_email_required'.tr;
                  if (!GetUtils.isEmail(v.trim()))
                    return 'login_email_invalid'.tr;
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'name@company.com',
                  // ignore: deprecated_member_use
                  hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.6)),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.grey,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: WebTheme.surfaceAlt,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: WebTheme.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _GradientButton(
                    loading: c.status.value == StatusRequest.loading,
                    onTap: c.sendResetLink,
                    label: 'forgot_btn'.tr,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: WebAuthController.to.goToLogin,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        color: WebTheme.primary,
                        size: 16,
                      ),
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
        ],
      ),

      // ── Email field ───────────────────────────────────
    );
  }

  Widget _label(String t) => Text(
    t,
    style: TextStyle(
      color: WebTheme.text,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );
}

// ── Success confirmation panel ───────────────────────────────
class _SentPanel extends StatelessWidget {
  final ForgotPasswordController c;
  const _SentPanel({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 48,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'forgot_sent_title'.tr,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: WebTheme.text,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'forgot_sent_desc'.tr,
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
              c.reset();
              WebAuthController.to.goToLogin();
            },
            label: 'forgot_back_login'.tr,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: c.reset,
            child: Text(
              'forgot_retry'.tr,
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

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
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
