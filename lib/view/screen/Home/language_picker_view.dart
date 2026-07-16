import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/language_picker_controller.dart';
import '../../../core/constant/appcolors.dart';

class LanguagePickerView extends StatelessWidget {
  const LanguagePickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguagePickerController>(
      init: LanguagePickerController(),
      builder: (c) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: SafeArea(
            child: FadeTransition(
              opacity: c.fadeAnim,
              child: SlideTransition(
                position: c.slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // ── Logo ──────────────────────────────
                      const SizedBox(height: 26),
                      Image.asset(
                        context.isDarkMode
                            ? 'assets/images/logo3.png'
                            : 'assets/images/logo2.png',
                        height: 150,
                      ),
                      const SizedBox(height: 48),

                      // ── Title (bilingual, always shown) ───
                      Obx(
                        () => Text(
                          c.selected.value == 'ar'
                              ? 'اختر لغتك'
                              : ' Choose Your Language',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Arabic option ─────────────────────
                      Obx(
                        () => _LangCard(
                          selected: c.selected.value == 'ar',
                          onTap: () => c.pick('ar'),
                          flag: '🇸🇦',
                          nativeName: 'العربية',
                          englishName: 'Arabic',
                          direction: 'RTL',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── English option ────────────────────
                      Obx(
                        () => _LangCard(
                          selected: c.selected.value == 'en',
                          onTap: () => c.pick('en'),
                          flag: '🇬🇧',
                          nativeName: 'English',
                          englishName: 'English',
                          direction: 'LTR',
                        ),
                      ),

                      const Spacer(flex: 3),

                      // ── Continue button ───────────────────
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppColors.favoriteGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkPrimary.withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: c.proceed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                c.selected.value == 'ar'
                                    ? 'متابعة'
                                    : 'Continue',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Language card ────────────────────────────────────────────
class _LangCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String flag;
  final String nativeName;
  final String englishName;
  final String direction;

  const _LangCard({
    required this.selected,
    required this.onTap,
    required this.flag,
    required this.nativeName,
    required this.englishName,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.favoriteGradient : null,
          color: selected ? null : AppColors.darkPrimary.withOpacity(0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.darkSecondary.withOpacity(0.8)
                : AppColors.grey.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.darkPrimary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nativeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$englishName  •  $direction',
                  style: TextStyle(
                    color: selected ? Colors.white70 : AppColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? Colors.white
                      : AppColors.grey.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 13,
                      color: AppColors.darkAccent,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
