import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../../core/functions/locale_helper.dart';
import '../../../core/services/services.dart';
import '../../widget/Home/expocore_logo.dart';

// ════════════════════════════════════════════════════════════
//  LanguagePickerView  —  First-launch language selection
// ════════════════════════════════════════════════════════════
class LanguagePickerView extends StatefulWidget {
  const LanguagePickerView({super.key});

  @override
  State<LanguagePickerView> createState() => _LanguagePickerViewState();
}

class _LanguagePickerViewState extends State<LanguagePickerView>
    with SingleTickerProviderStateMixin {
  String _selected = 'ar';
  late final AnimationController _anim;
  late final Animation<double>    _fadeAnim;
  late final Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _fadeAnim  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _pick(String lang) {
    setState(() => _selected = lang);
    changeAppLanguage(lang);
  }

  Future<void> _continue() async {
    final svc = Get.find<Services>();
    await svc.setLangChosen();
    if (svc.onboardDone) {
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Logo ──────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const ExpocoreLogo(size: 48),
                        const SizedBox(width: 14),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3),
                            children: [
                              TextSpan(text: 'EXPO', style: TextStyle(color: AppColors.darkSecondary)),
                              TextSpan(text: 'CORE', style: TextStyle(color: AppColors.darkAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // ── Title (bilingual, always shown) ───
                    const Text(
                      'اختر لغتك  •  Choose Your Language',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'يمكنك تغيير اللغة لاحقاً من الإعدادات\nYou can change this later in Settings',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 13,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // ── Arabic option ─────────────────────
                    _LangCard(
                      selected: _selected == 'ar',
                      onTap: () => _pick('ar'),
                      flag: '🇸🇦',
                      nativeName: 'العربية',
                      englishName: 'Arabic',
                      direction: 'RTL',
                    ),
                    const SizedBox(height: 16),

                    // ── English option ────────────────────
                    _LangCard(
                      selected: _selected == 'en',
                      onTap: () => _pick('en'),
                      flag: '🇬🇧',
                      nativeName: 'English',
                      englishName: 'English',
                      direction: 'LTR',
                    ),

                    const Spacer(flex: 3),

                    // ── Continue button ───────────────────
                    SizedBox(
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
                          onPressed: _continue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            _selected == 'ar' ? 'متابعة  →' : 'Continue  →',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
    );
  }
}

// ── Language card ────────────────────────────────────────────
class _LangCard extends StatelessWidget {
  final bool     selected;
  final VoidCallback onTap;
  final String   flag;
  final String   nativeName;
  final String   englishName;
  final String   direction;

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
              ? [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))]
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
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white,
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
                  color: selected ? Colors.white : AppColors.grey.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: AppColors.darkAccent)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
