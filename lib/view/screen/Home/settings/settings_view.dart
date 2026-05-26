import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/settings_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/bottom_nav_custom.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      bottomNavigationBar: const BottomNavCustom(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            _profileSection(context, isDark),
            const SizedBox(height: 8),
            _settingsList(context, isDark),
          ]),
        ),
      ),
    );
  }

  Widget _profileSection(BuildContext context, bool isDark) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
    decoration: BoxDecoration(
      gradient: isDark ? AppColors.darkCardGradient : null,
      color: isDark ? null : AppColors.lightCard,
    ),
    child: Row(children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(gradient: AppColors.darkCTAGradient, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.4), blurRadius: 16)]),
        child: const Center(child: Text('ش', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800))),
      ),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('شركة المستقبل التقنية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        const Text('info@futuretech.sa', style: TextStyle(fontSize: 12, color: AppColors.grey)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
          child: const Text('مستثمر نشط', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ]),
    ]),
  );

  Widget _settingsList(BuildContext context, bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(children: [
      _sectionTitle('الحساب'),
      _settingTile(context, isDark, Icons.person_outline, 'معلومات الحساب', () => Get.toNamed(AppRoutes.PROFILE)),
      _settingTile(context, isDark, Icons.edit_outlined, 'تعديل الملف التعريفي', () => Get.toNamed(AppRoutes.PROFILE)),
      const SizedBox(height: 12),
      _sectionTitle('التفضيلات'),
      _settingTile(context, isDark, Icons.language_outlined, 'اللغة', null, trailing: Obx(() => Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(onTap: () => controller.changeLanguage('ar'), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: controller.currentLang.value == 'ar' ? AppColors.darkPrimary : AppColors.darkSurface.withOpacity(0.5), borderRadius: BorderRadius.circular(6)), child: Text('العربية', style: TextStyle(color: controller.currentLang.value == 'ar' ? Colors.white : AppColors.grey, fontSize: 11)))),
        const SizedBox(width: 4),
        GestureDetector(onTap: () => controller.changeLanguage('en'), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: controller.currentLang.value == 'en' ? AppColors.darkPrimary : AppColors.darkSurface.withOpacity(0.5), borderRadius: BorderRadius.circular(6)), child: Text('English', style: TextStyle(color: controller.currentLang.value == 'en' ? Colors.white : AppColors.grey, fontSize: 11)))),
      ]))),
      _settingTile(context, isDark, Icons.dark_mode_outlined, 'الوضع الداكن', null,
        trailing: Obx(() => Switch(value: controller.isDark.value, onChanged: controller.toggleTheme, activeColor: AppColors.darkPrimary))),
      const SizedBox(height: 12),
      _sectionTitle('الإشعارات'),
      _settingTile(context, isDark, Icons.notifications_outlined, 'الإشعارات', null,
        trailing: Obx(() => Switch(value: controller.notificationsEnabled.value, onChanged: (v) => controller.notificationsEnabled.value = v, activeColor: AppColors.darkPrimary))),
      _settingTile(context, isDark, Icons.favorite_border, 'إشعارات المفضلة', null,
        trailing: Obx(() => Switch(value: controller.favoritesNotify.value, onChanged: (v) => controller.favoritesNotify.value = v, activeColor: AppColors.darkPrimary))),
      _settingTile(context, isDark, Icons.analytics_outlined, 'تنبيهات التقارير', null,
        trailing: Obx(() => Switch(value: controller.reportsNotify.value, onChanged: (v) => controller.reportsNotify.value = v, activeColor: AppColors.darkPrimary))),
      const SizedBox(height: 12),
      _sectionTitle('المزيد'),
      _settingTile(context, isDark, Icons.help_outline, 'مساعدة ودعم', () {}),
      _settingTile(context, isDark, Icons.policy_outlined, 'سياسة الخصوصية', () {}),
      _settingTile(context, isDark, Icons.article_outlined, 'الشروط والأحكام', () {}),
      const SizedBox(height: 8),
      _settingTile(context, isDark, Icons.logout, 'تسجيل الخروج', controller.logout, isDestructive: true),
      const SizedBox(height: 24),
      const Text('ExpoCore v1.0.0 • منصة المستثمر', style: TextStyle(fontSize: 11, color: AppColors.grey)),
      const SizedBox(height: 20),
    ]),
  );

  Widget _sectionTitle(String t) => Align(
    alignment: Alignment.centerRight,
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w600))),
  );

  Widget _settingTile(BuildContext context, bool isDark, IconData icon, String label, VoidCallback? onTap, {Widget? trailing, bool isDestructive = false}) => Container(
    margin: const EdgeInsets.symmetric(vertical: 3),
    decoration: BoxDecoration(
      gradient: isDark ? AppColors.darkCardGradient : null,
      color: isDark ? null : AppColors.lightCard,
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      leading: Icon(icon, size: 22, color: isDestructive ? AppColors.error : AppColors.darkPrimary),
      title: Text(label, style: TextStyle(fontSize: 14, color: isDestructive ? AppColors.error : null, fontWeight: FontWeight.w500)),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey) : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
