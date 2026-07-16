import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/profile_company_controller.dart';
import '../../../controller/Home/settings_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_auth_controller.dart';
import '../widgets/web_section_header.dart';
import '../../../view/widget/Home/profile_avatar.dart';
import '../../controllers/web_nav_controller.dart';

class WebSettingsPage extends StatelessWidget {
  const WebSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    final p = Get.find<ProfileCompanyController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: WebTheme.bg,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: const WebSectionHeader(
                title: 'الإعدادات',
                subtitle: 'معلوماتك الشخصية وتفضيلاتك',
              ),
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileSummaryCard(p: p),
                    const SizedBox(height: 18),

                    _card('المظهر', [
                      Obx(
                        () => _switchTile(
                          icon: Icons.dark_mode_rounded,
                          title: 'الوضع الداكن',
                          value: WebTheme.isDark.value,
                          onChanged: WebTheme.setDark,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 18),

                    _card('الإشعارات', [
                      Obx(
                        () => _switchTile(
                          icon: Icons.notifications_rounded,
                          title: 'تفعيل الإشعارات',
                          value: c.notificationsEnabled.value,
                          onChanged: (v) => c.notificationsEnabled.value = v,
                        ),
                      ),
                      Obx(
                        () => _switchTile(
                          icon: Icons.favorite_rounded,
                          title: 'إشعارات المفضلة',
                          value: c.favoritesNotify.value,
                          onChanged: (v) => c.favoritesNotify.value = v,
                        ),
                      ),
                      Obx(
                        () => _switchTile(
                          icon: Icons.bar_chart_rounded,
                          title: 'إشعارات التقارير',
                          value: c.reportsNotify.value,
                          onChanged: (v) => c.reportsNotify.value = v,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 18),

                    _card('اللغة', [
                      Obx(
                        () => Row(
                          children: [
                            _langBtn(c, 'ar', 'العربية'),
                            const SizedBox(width: 12),
                            _langBtn(c, 'en', 'English'),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 18),

                    GestureDetector(
                      onTap: () => _confirmLogout(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: AppColors.error.withOpacity(0.9),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تسجيل الخروج',
                              style: TextStyle(
                                color: AppColors.error.withOpacity(0.9),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLogout() {
    Get.dialog(
      Dialog(
        backgroundColor: WebTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error, size: 44),
              const SizedBox(height: 16),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: WebTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                style: TextStyle(color: AppColors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.grey.withOpacity(0.4),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        WebAuthController.to.logout();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'خروج',
                          style: TextStyle(
                            color: WebTheme.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable card ──────────────────────────────────────────
  Widget _card(String title, List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: WebTheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: WebTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: WebTheme.text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: WebTheme.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: WebTheme.text, fontSize: 14),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: WebTheme.primary,
          activeTrackColor: WebTheme.primary.withOpacity(0.5),
        ),
      ],
    ),
  );

  Widget _langBtn(SettingsController c, String code, String label) {
    final active = c.currentLang.value == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.changeLanguage(code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: active ? AppColors.favoriteGradient : null,
            color: active ? null : WebTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Compact profile summary card ─────────────────────────────
class _ProfileSummaryCard extends StatelessWidget {
  final ProfileCompanyController p;
  const _ProfileSummaryCard({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WebTheme.border),
      ),
      child: Obx(() {
        p.isLoading.value;
        p.profileImage.value;
        return Row(
          children: [
            // ── Avatar ──
            ProfileAvatar(
              image: p.profileImage.value,
              fallbackLetter: p.nameCtrl.text.isNotEmpty
                  ? p.nameCtrl.text[0]
                  : 'ش',
              size: 56,
              editable: false,
            ),
            const SizedBox(width: 16),
            // ── Name + Email ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nameCtrl.text.isEmpty ? 'اسم الشركة' : p.nameCtrl.text,
                    style: TextStyle(
                      color: WebTheme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.emailCtrl.text.isEmpty ? '—' : p.emailCtrl.text,
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            // ── View details button ──
            GestureDetector(
              onTap: WebNavController.to.openAccountDetail,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.favoriteGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.manage_accounts_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'تفاصيل الحساب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
