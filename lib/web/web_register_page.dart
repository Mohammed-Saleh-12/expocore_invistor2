import 'package:flutter/material.dart';
import 'web_theme.dart';
import 'package:get/get.dart';
import '../controller/auth/register_controller.dart';
import '../core/class/StatusRequest.dart';
import '../core/constant/appcolors.dart';
import '../view/widget/Home/expocore_logo.dart';
import 'controllers/web_auth_controller.dart';
import 'widgets/web_fade_in.dart';

// ════════════════════════════════════════════════════════════
//  WebRegisterPage  —  إنشاء حساب (نفس حقول الجوال بالضبط)
// ════════════════════════════════════════════════════════════
class WebRegisterPage extends StatefulWidget {
  const WebRegisterPage({super.key});

  @override
  State<WebRegisterPage> createState() => _WebRegisterPageState();
}

class _WebRegisterPageState extends State<WebRegisterPage> {
  late final RegisterController c;
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    c = Get.find<RegisterController>();
    // عند نجاح التسجيل → عُد لشاشة الدخول
    _worker = ever(c.status, (s) {
      if (s == StatusRequest.success) WebAuthController.to.goToLogin();
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 1000;
    return Scaffold(
      backgroundColor: WebTheme.bg,
      body: Row(
        children: [
          if (wide)
            const Expanded(
              flex: 5,
              child: WebFadeIn(beginOffset: Offset(-0.08, 0), child: _Brand()),
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
                    child: _form(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(BuildContext context) => Form(
        key: c.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('register_title'.tr,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: WebTheme.text)),
            const SizedBox(height: 6),
            Text('register_subtitle'.tr,
                style: TextStyle(fontSize: 14, color: AppColors.grey.withOpacity(0.85))),
            const SizedBox(height: 28),

            // ── معلومات الشركة ─────────────────────────────
            _section('register_company_info'.tr),
            const SizedBox(height: 14),
            _field(c.companyCtrl, 'register_company'.tr, Icons.business_outlined,
                validator: (v) => (v == null || v.isEmpty) ? 'field_required'.tr : null),
            const SizedBox(height: 14),
            _field(c.tradeCtrl, 'register_trade'.tr, Icons.category_outlined),
            const SizedBox(height: 14),
            _field(c.locationCtrl, 'register_location'.tr, Icons.location_on_outlined,
                validator: (v) => (v == null || v.isEmpty) ? 'field_required'.tr : null),
            const SizedBox(height: 14),
            Obx(() => _dropdown()),
            const SizedBox(height: 24),

            // ── بيانات التواصل ─────────────────────────────
            _section('register_contact_info'.tr),
            const SizedBox(height: 14),
            _field(c.emailCtrl, 'login_email'.tr, Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'field_required'.tr;
                  if (!GetUtils.isEmail(v.trim())) return 'login_email_invalid'.tr;
                  return null;
                }),
            const SizedBox(height: 14),
            _field(c.phoneCtrl, 'register_phone'.tr, Icons.phone_outlined, keyboard: TextInputType.phone),
            const SizedBox(height: 14),
            _field(c.websiteCtrl, 'register_website'.tr, Icons.language_outlined),
            const SizedBox(height: 24),

            // ── كلمة المرور ────────────────────────────────
            _section('login_password'.tr),
            const SizedBox(height: 14),
            Obx(() => _field(c.passCtrl, 'login_password'.tr, Icons.lock_outline_rounded,
                  obscure: c.obscurePass.value,
                  validator: (v) => (v?.length ?? 0) < 6 ? 'register_password_len'.tr : null,
                  suffix: IconButton(
                    onPressed: () => c.obscurePass.toggle(),
                    icon: Icon(c.obscurePass.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.grey, size: 20),
                  ),
                )),
            const SizedBox(height: 14),
            Obx(() => _field(c.confirmCtrl, 'register_confirm'.tr, Icons.lock_outline_rounded,
                  obscure: c.obscureConf.value,
                  validator: (v) => v != c.passCtrl.text ? 'register_mismatch'.tr : null,
                  suffix: IconButton(
                    onPressed: () => c.obscureConf.toggle(),
                    icon: Icon(c.obscureConf.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.grey, size: 20),
                  ),
                )),
            const SizedBox(height: 18),

            // ── الشروط ─────────────────────────────────────
            Obx(() => GestureDetector(
                  onTap: () => c.termsAccepted.toggle(),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: c.termsAccepted.value ? AppColors.favoriteGradient : null,
                          border: Border.all(
                            color: c.termsAccepted.value ? Colors.transparent : AppColors.grey.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: c.termsAccepted.value
                            ? Icon(Icons.check_rounded, color: WebTheme.text, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text('أوافق على ', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                      Text('register_terms'.tr,
                          style: TextStyle(fontSize: 13, color: AppColors.darkPrimary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                )),
            const SizedBox(height: 24),

            // ── زر التسجيل ─────────────────────────────────
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: c.status.value == StatusRequest.loading ? null : c.register,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.favoriteGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      alignment: Alignment.center,
                      child: c.status.value == StatusRequest.loading
                          ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('register_btn'.tr, style: TextStyle(color: WebTheme.text, fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                )),
            const SizedBox(height: 18),

            // ── رابط الدخول ────────────────────────────────
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('لديك حساب؟ ', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                  GestureDetector(
                    onTap: WebAuthController.to.goToLogin,
                    child: Text('login_title'.tr,
                        style: TextStyle(fontSize: 13, color: AppColors.darkPrimary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _section(String t) => Row(children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(t, style: TextStyle(color: WebTheme.text, fontSize: 14, fontWeight: FontWeight.w700)),
      ]);

  Widget _dropdown() => DropdownButtonFormField<String>(
        value: c.activityType.value.isEmpty ? null : c.activityType.value,
        hint: Text('register_activity'.tr, style: TextStyle(color: AppColors.grey)),
        dropdownColor: WebTheme.surfaceAlt,
        style: TextStyle(color: WebTheme.text),
        isExpanded: true,
        decoration: _dec(Icons.business_center_outlined),
        items: c.activityTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => c.activityType.value = v ?? '',
      );

  InputDecoration _dec(IconData icon, {Widget? suffix}) => InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: WebTheme.surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
          {TextInputType? keyboard, bool obscure = false, Widget? suffix, String? Function(String?)? validator}) =>
      TextFormField(
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

// ── Brand side ──────────────────────────────────────────────
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D0A5C), Color(0xFF1A0533), Color(0xFF0D0221)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -80, left: -60, child: _blob(300, AppColors.darkPrimary.withOpacity(0.25))),
          Positioned(bottom: -60, right: -40, child: _blob(240, AppColors.darkSecondary.withOpacity(0.2))),
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
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.4), blurRadius: 30)],
                      ),
                      child: const ExpocoreLogo(size: 56),
                    ),
                    const SizedBox(width: 16),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 3),
                        children: [
                          TextSpan(text: 'EXPO', style: TextStyle(color: AppColors.darkSecondary)),
                          TextSpan(text: 'CORE', style: TextStyle(color: AppColors.darkAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ShaderMask(
                  shaderCallback: (b) => AppColors.favoriteGradient.createShader(b),
                  child: Text('ابدأ رحلتك معنا\nوأنشئ حسابك الآن',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, height: 1.3, color: WebTheme.text)),
                ),
                const SizedBox(height: 18),
                Text('register_brand_desc'.tr,
                    style: TextStyle(fontSize: 16, height: 1.9, color: AppColors.grey.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double s, Color col) => Container(
        width: s, height: s,
        decoration: BoxDecoration(shape: BoxShape.circle, color: col,
            boxShadow: [BoxShadow(color: col, blurRadius: 120, spreadRadius: 40)]),
      );
}
