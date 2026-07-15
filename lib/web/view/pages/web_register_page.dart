import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/register_controller.dart';
import '../../../core/class/StatusRequest.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_auth_controller.dart';
import '../../models/web_theme.dart';
import '../widgets/web_fade_in.dart';

class WebRegisterPage extends StatelessWidget {
  const WebRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RegisterController>();
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
                child: _RegisterBrand(),
              ),
            ),
          Expanded(
            flex: 5,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: WebFadeIn(
                    delay: const Duration(milliseconds: 200),
                    scale: true,
                    beginOffset: const Offset(0, 0.15),
                    child: _RegisterForm(c: c),
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
class _RegisterBrand extends StatelessWidget {
  const _RegisterBrand();

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
            padding: const EdgeInsets.all(60),
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
                    'ابدأ رحلتك معنا وأنشئ حسابك الآن',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                      color: Colors.white,
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
class _RegisterForm extends StatelessWidget {
  final RegisterController c;
  const _RegisterForm({required this.c});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'register_title'.tr,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: WebTheme.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'register_subtitle'.tr,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 28),

          // ── معلومات الشركة ──────────────────────────────
          _section('register_company_info'.tr),
          const SizedBox(height: 14),
          _field(
            c.companyCtrl,
            'register_company'.tr,
            Icons.business_outlined,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'field_required'.tr : null,
          ),
          const SizedBox(height: 14),
          _field(c.tradeCtrl, 'register_trade'.tr, Icons.category_outlined),
          const SizedBox(height: 14),
          _field(
            c.locationCtrl,
            'register_location'.tr,
            Icons.location_on_outlined,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'field_required'.tr : null,
          ),
          const SizedBox(height: 14),
          Obx(() => _dropdown()),
          const SizedBox(height: 24),

          // ── بيانات التواصل ──────────────────────────────
          _section('register_contact_info'.tr),
          const SizedBox(height: 14),
          _field(
            c.emailCtrl,
            'login_email'.tr,
            Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'field_required'.tr;
              if (!GetUtils.isEmail(v.trim())) return 'login_email_invalid'.tr;
              return null;
            },
          ),
          const SizedBox(height: 14),
          _field(
            c.phoneCtrl,
            'register_phone'.tr,
            Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _field(c.websiteCtrl, 'register_website'.tr, Icons.language_outlined),
          const SizedBox(height: 24),

          // ── كلمة المرور ─────────────────────────────────
          _section('login_password'.tr),
          const SizedBox(height: 14),
          Obx(
            () => _field(
              c.passCtrl,
              'login_password'.tr,
              Icons.lock_outline_rounded,
              obscure: c.obscurePass.value,
              validator: (v) =>
                  (v?.length ?? 0) < 6 ? 'register_password_len'.tr : null,
              suffix: IconButton(
                onPressed: () => c.obscurePass.toggle(),
                icon: Icon(
                  c.obscurePass.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Obx(
            () => _field(
              c.confirmCtrl,
              'register_confirm'.tr,
              Icons.lock_outline_rounded,
              obscure: c.obscureConf.value,
              validator: (v) =>
                  v != c.passCtrl.text ? 'register_mismatch'.tr : null,
              suffix: IconButton(
                onPressed: () => c.obscureConf.toggle(),
                icon: Icon(
                  c.obscureConf.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── الشروط ──────────────────────────────────────
          Obx(
            () => GestureDetector(
              onTap: () => c.termsAccepted.toggle(),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: c.termsAccepted.value
                          ? AppColors.favoriteGradient
                          : null,
                      border: Border.all(
                        color: c.termsAccepted.value
                            ? Colors.transparent
                            : AppColors.grey.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: c.termsAccepted.value
                        ? Icon(
                            Icons.check_rounded,
                            color: WebTheme.text,
                            size: 14,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'أوافق على ',
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                  Text(
                    'register_terms'.tr,
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
          const SizedBox(height: 24),

          // ── زر التسجيل ──────────────────────────────────
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: GestureDetector(
                onTap: c.status.value == StatusRequest.loading
                    ? null
                    : c.register,
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
                  child: c.status.value == StatusRequest.loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'register_btn'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── رابط الدخول ─────────────────────────────────
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'لديك حساب؟ ',
                  style: TextStyle(fontSize: 13, color: AppColors.grey),
                ),
                GestureDetector(
                  onTap: WebAuthController.to.goToLogin,
                  child: Text(
                    'login_title'.tr,
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

  Widget _section(String t) => Row(
    children: [
      Container(
        width: 4,
        height: 16,
        decoration: BoxDecoration(
          gradient: AppColors.favoriteGradient,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        t,
        style: TextStyle(
          color: WebTheme.text,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _dropdown() => DropdownButtonFormField<String>(
    value: c.activityType.value.isEmpty ? null : c.activityType.value,
    hint: Text('register_activity'.tr, style: TextStyle(color: AppColors.grey)),
    dropdownColor: WebTheme.surfaceAlt,
    style: TextStyle(color: WebTheme.text),
    isExpanded: true,
    decoration: _dec(Icons.business_center_outlined),
    items: c.activityTypes
        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
        .toList(),
    onChanged: (v) => c.activityType.value = v ?? '',
  );

  InputDecoration _dec(IconData icon, {Widget? suffix}) => InputDecoration(
    prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: WebTheme.surfaceAlt,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: WebTheme.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? keyboard,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: keyboard,
    obscureText: obscure,
    validator: validator,
    style: TextStyle(color: WebTheme.text),
    decoration: _dec(icon, suffix: suffix).copyWith(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.6)),
    ),
  );
}
