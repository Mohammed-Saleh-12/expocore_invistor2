import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/app_globals.dart';
import '../../../core/functions/locale_helper.dart';

// ════════════════════════════════════════════════════════════
//  LanguageToggle  —  مبدّل اللغة (عربي / English)
// ════════════════════════════════════════════════════════════
class LanguageToggle extends StatelessWidget {
  final bool compact;
  const LanguageToggle({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAr = appLang.value == 'ar';
      return GestureDetector(
        onTap: toggleAppLanguage,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 6 : 8),
          decoration: BoxDecoration(
            color: AppColors.darkPrimary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkPrimary.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, size: 16, color: AppColors.darkPrimary),
              const SizedBox(width: 6),
              Text(
                isAr ? 'English' : 'العربية',
                style: const TextStyle(
                  color: AppColors.darkPink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
