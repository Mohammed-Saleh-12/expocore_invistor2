import 'package:flutter/material.dart';
import '../web_theme.dart';
import 'package:get/get.dart';
import '../../controller/Home/profile_company_controller.dart';
import '../../controller/Home/settings_controller.dart';
import '../../core/constant/appcolors.dart';
import '../controllers/web_auth_controller.dart';
import '../widgets/web_section_header.dart';
import '../../view/widget/Home/profile_avatar.dart';

// ════════════════════════════════════════════════════════════
//  WebSettingsPage  —  الإعدادات + المعلومات الشخصية
// ════════════════════════════════════════════════════════════
class WebSettingsPage extends StatelessWidget {
  const WebSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    final p = Get.find<ProfileCompanyController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WebSectionHeader(title: 'الإعدادات', subtitle: 'معلوماتك الشخصية وتفضيلاتك'),
              const SizedBox(height: 24),

              // ── Personal info ──────────────────────────────
              _PersonalInfoCard(p: p),
              const SizedBox(height: 18),

              // ── Appearance ─────────────────────────────────
              _card('المظهر', [
                Obx(() => _switchTile(
                      icon: Icons.dark_mode_rounded,
                      title: 'الوضع الداكن',
                      value: WebTheme.isDark.value,
                      onChanged: WebTheme.setDark,
                    )),
              ]),
              const SizedBox(height: 18),

              // ── Notifications ──────────────────────────────
              _card('الإشعارات', [
                Obx(() => _switchTile(
                      icon: Icons.notifications_rounded,
                      title: 'تفعيل الإشعارات',
                      value: c.notificationsEnabled.value,
                      onChanged: (v) => c.notificationsEnabled.value = v,
                    )),
                Obx(() => _switchTile(
                      icon: Icons.favorite_rounded,
                      title: 'إشعارات المفضلة',
                      value: c.favoritesNotify.value,
                      onChanged: (v) => c.favoritesNotify.value = v,
                    )),
                Obx(() => _switchTile(
                      icon: Icons.bar_chart_rounded,
                      title: 'إشعارات التقارير',
                      value: c.reportsNotify.value,
                      onChanged: (v) => c.reportsNotify.value = v,
                    )),
              ]),
              const SizedBox(height: 18),

              // ── Language ───────────────────────────────────
              _card('اللغة', [
                Obx(() => Row(
                      children: [
                        _langBtn(c, 'ar', 'العربية'),
                        const SizedBox(width: 12),
                        _langBtn(c, 'en', 'English'),
                      ],
                    )),
              ]),
              const SizedBox(height: 18),

              // ── Logout ─────────────────────────────────────
              GestureDetector(
                onTap: () => _confirmLogout(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.error.withOpacity(0.9), size: 20),
                      const SizedBox(width: 8),
                      Text('تسجيل الخروج',
                          style: TextStyle(color: AppColors.error.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
              Text('تسجيل الخروج',
                  style: TextStyle(color: WebTheme.text, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                  style: TextStyle(color: AppColors.grey, fontSize: 14), textAlign: TextAlign.center),
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
                          border: Border.all(color: AppColors.grey.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('إلغاء', style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () { Get.back(); WebAuthController.to.logout(); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                        child: Text('خروج', style: TextStyle(color: WebTheme.text, fontWeight: FontWeight.w700)),
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

  // ── Reusable card ─────────────────────────────────────────
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
            Text(title, style: TextStyle(color: WebTheme.text, fontSize: 16, fontWeight: FontWeight.w800)),
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
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkPrimary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(color: WebTheme.text, fontSize: 14))),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.darkSecondary,
              activeTrackColor: AppColors.darkPrimary.withOpacity(0.5),
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
          child: Text(label,
              style: TextStyle(
                color: active ? WebTheme.text : AppColors.grey,
                fontSize: 14, fontWeight: FontWeight.w700,
              )),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  _PersonalInfoCard  —  المعلومات الشخصية (عرض / تعديل / حفظ)
// ════════════════════════════════════════════════════════════
class _PersonalInfoCard extends StatelessWidget {
  final ProfileCompanyController p;
  const _PersonalInfoCard({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WebTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar
          Row(
            children: [
              Obx(() {
                p.isLoading.value; p.isEditing.value; p.profileImage.value;
                return ProfileAvatar(
                  image: p.profileImage.value,
                  fallbackLetter: p.nameCtrl.text.isNotEmpty ? p.nameCtrl.text[0] : 'ش',
                  size: 72,
                  editable: p.isEditing.value,
                  onEdit: p.pickProfileImage,
                );
              }),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      p.isLoading.value; p.isEditing.value;
                      return Text(
                        p.nameCtrl.text.isEmpty ? 'المعلومات الشخصية' : p.nameCtrl.text,
                        style: TextStyle(color: WebTheme.text, fontSize: 18, fontWeight: FontWeight.w800),
                      );
                    }),
                    const SizedBox(height: 4),
                    Text('بيانات الحساب والشركة',
                        style: TextStyle(color: AppColors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Obx(() => GestureDetector(
                    onTap: p.toggleEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: p.isEditing.value ? null : AppColors.favoriteGradient,
                        color: p.isEditing.value ? WebTheme.surfaceAlt : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(p.isEditing.value ? Icons.close_rounded : Icons.edit_outlined,
                              color: WebTheme.text, size: 16),
                          const SizedBox(width: 6),
                          Text(p.isEditing.value ? 'إلغاء' : 'تعديل',
                              style: TextStyle(color: WebTheme.text, fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 24),

          // Fields
          Obx(() {
            final editing = p.isEditing.value;
            return Column(
              children: [
                _field('اسم الشركة', p.nameCtrl, Icons.business_outlined, editing),
                _field('البريد الإلكتروني', p.emailCtrl, Icons.email_outlined, editing),
                _field('رقم الجوال', p.phoneCtrl, Icons.phone_outlined, editing),
                _field('الموقع', p.locationCtrl, Icons.location_on_outlined, editing),
                _field('الموقع الإلكتروني', p.websiteCtrl, Icons.language_outlined, editing),
                _field('نبذة', p.bioCtrl, Icons.description_outlined, editing, maxLines: 3),

                // ── التواصل الاجتماعي ──────────────────────
                const SizedBox(height: 4),
                Row(children: [
                  Container(width: 4, height: 14, decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Text('التواصل الاجتماعي', style: TextStyle(color: WebTheme.text, fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 12),
                _field('LinkedIn', p.linkedinCtrl, Icons.link, editing),
                _field('X (Twitter)', p.twitterCtrl, Icons.alternate_email, editing),
                _field('Instagram', p.instagramCtrl, Icons.camera_alt_outlined, editing),
                _field('Facebook', p.facebookCtrl, Icons.facebook, editing),

                if (editing) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: p.saveChanges,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(12)),
                        child: p.isSaving.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('حفظ التغييرات', style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, IconData icon, bool editing, {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              enabled: editing,
              maxLines: maxLines,
              style: TextStyle(color: WebTheme.text, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.grey, size: 19),
                filled: true,
                fillColor: editing ? WebTheme.surfaceAlt : WebTheme.topbar,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              ),
            ),
          ],
        ),
      );
}
