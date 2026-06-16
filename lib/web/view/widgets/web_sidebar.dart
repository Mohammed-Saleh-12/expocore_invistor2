import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/web_theme.dart';
import '../../../core/constant/appcolors.dart';
import '../../../view/widget/Home/expocore_logo.dart';
import '../../models/web_section.dart';

class WebSidebar extends StatelessWidget {
  final List<WebSection> sections;
  final int              selected;
  final void Function(int) onSelect;
  final VoidCallback     onLogout;

  const WebSidebar({
    super.key,
    required this.sections,
    required this.selected,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: WebTheme.surface,
        border: isRtl
            ? Border(left: BorderSide(color: WebTheme.border))
            : Border(right: BorderSide(color: WebTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Row(
              children: [
                const ExpocoreLogo(size: 40),
                const SizedBox(width: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2),
                    children: [
                      TextSpan(text: 'EXPO', style: TextStyle(color: AppColors.darkSecondary)),
                      TextSpan(text: 'CORE', style: TextStyle(color: AppColors.darkAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: WebTheme.border, height: 1),
          const SizedBox(height: 12),

          // ── Nav items ───────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: sections.length,
              itemBuilder: (_, i) => _NavItem(
                section: sections[i],
                active: i == selected,
                onTap: () => onSelect(i),
              ),
            ),
          ),

          // ── Logout ──────────────────────────────────────
          Divider(color: WebTheme.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.error.withOpacity(0.9), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'settings_logout'.tr,
                      style: TextStyle(color: AppColors.error.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav item ────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final WebSection section;
  final bool       active;
  final VoidCallback onTap;
  const _NavItem({required this.section, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: active ? AppColors.favoriteGradient : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 4))]
                : null,
          ),
          child: Row(
            children: [
              Icon(section.icon,
                  color: active ? WebTheme.onGradient : AppColors.grey, size: 21),
              const SizedBox(width: 13),
              Text(
                section.label.tr,
                style: TextStyle(
                  color: active ? WebTheme.onGradient : AppColors.grey,
                  fontSize: 14.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
