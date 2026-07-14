import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/login_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_auth_controller.dart';
import '../../models/web_theme.dart';
import '../widgets/web_fade_in.dart';

class WebLoginPage extends StatelessWidget {
  const WebLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LoginController>();
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
                child: _LoginBrand(),
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
                    child: _LoginForm(c: c),
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
class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

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
            padding: const EdgeInsets.only(right: 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  WebTheme.isDark.value
                      ? 'assets/images/logo3.png'
                      : 'assets/images/logo2.png',
                  height: 250,
                ),

                const SizedBox(height: 50),
                ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.favoriteGradient.createShader(b),
                  child: Text(
                    'login_brand_title'.tr,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                      color: WebTheme.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Form side ───────────────────────────────────────────────
class _LoginForm extends StatelessWidget {
  final LoginController c;
  const _LoginForm({required this.c});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'login_title'.tr,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: WebTheme.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'login_enter_data'.tr,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 32),

          _label('login_email'.tr),
          const SizedBox(height: 8),
          _field(
            controller: c.emailCtrl,
            hint: 'name@company.com',
            icon: Icons.email_outlined,
            validator: (v) {
              if (v == null || v.isEmpty) return 'login_email_required'.tr;
              if (!GetUtils.isEmail(v.trim())) return 'login_email_invalid'.tr;
              return null;
            },
          ),
          const SizedBox(height: 18),

          _label('login_password'.tr),
          const SizedBox(height: 8),
          Obx(
            () => _field(
              controller: c.passwordCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscure: c.obscure.value,
              suffix: IconButton(
                onPressed: c.toggleObscure,
                icon: Icon(
                  c.obscure.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.grey,
                  size: 20,
                ),
              ),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'login_password_required'.tr
                  : null,
            ),
          ),
          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: WebAuthController.to.goToForgotPassword,
              child: Text(
                'login_forgot'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: WebTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: _GradientButton(
                loading: c.status.value == StatusRequest.loading,
                onTap: c.login,
                label: 'login_btn'.tr,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton.icon(
              onPressed: c.fillDemo,
              icon: Icon(
                Icons.play_circle_outline_rounded,
                color: WebTheme.primary,
                size: 18,
              ),
              label: Text(
                'login_demo'.tr,
                style: TextStyle(
                  color: WebTheme.pink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${'login_no_account'.tr} ',
                  style: const TextStyle(fontSize: 13, color: AppColors.grey),
                ),
                GestureDetector(
                  onTap: WebAuthController.to.goToRegister,
                  child: Text(
                    'register_title'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      color: WebTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) => TextFormField(
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
    ),
  );
}

// ── Gradient button ─────────────────────────────────────────
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
                  color: WebTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
