import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../controller/Home/onboarding_controller.dart';
import '../../widget/Home/custom_button.dart';
import '../../widget/Home/expocore_logo.dart';

class _SlideData {
  final IconData icon;
  final String titleKey;
  final String descKey;
  final LinearGradient gradient;
  const _SlideData({required this.icon, required this.titleKey, required this.descKey, required this.gradient});
}

const _slides = [
  _SlideData(icon: Icons.store_rounded, titleKey: 'onboard_t1', descKey: 'onboard_d1', gradient: AppColors.favoriteGradient),
  _SlideData(
    icon: Icons.analytics_rounded, titleKey: 'onboard_t2', descKey: 'onboard_d2',
    gradient: LinearGradient(colors: [AppColors.darkPrimary, AppColors.darkAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
  ),
  _SlideData(
    icon: Icons.favorite_rounded, titleKey: 'onboard_t3', descKey: 'onboard_d3',
    gradient: LinearGradient(colors: [AppColors.darkAccent, AppColors.darkSecondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
  ),
];

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OnboardingController>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildSkipButton(ctrl),
              Expanded(
                child: PageView.builder(
                  controller: ctrl.pageCtrl,
                  onPageChanged: ctrl.onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (_, i) => _SlideWidget(
                    data: _slides[i],
                    iconScale: ctrl.iconScale,
                    iconFade: ctrl.iconFade,
                    textSlide: ctrl.textSlide,
                    textFade: ctrl.textFade,
                  ),
                ),
              ),
              _buildBottomSection(ctrl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(OnboardingController ctrl) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const ExpocoreLogo(size: 32),
                const SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2),
                    children: [
                      TextSpan(text: 'EXPO', style: TextStyle(color: AppColors.darkSecondary)),
                      TextSpan(text: 'CORE', style: TextStyle(color: AppColors.darkAccent)),
                    ],
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: ctrl.finish,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                ),
              ),
              child: Text('onboard_skip'.tr, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
            ),
          ],
        ),
      );

  Widget _buildBottomSection(OnboardingController ctrl) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          children: [
            _buildDots(ctrl),
            const SizedBox(height: 28),
            Obx(() => CustomButton(
              label: ctrl.currentPage.value < _slides.length - 1 ? 'onboard_next'.tr : 'onboard_start'.tr,
              onTap: () => ctrl.next(_slides.length),
            )),
          ],
        ),
      );

  Widget _buildDots(OnboardingController ctrl) => Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_slides.length, (i) {
          final isActive = i == ctrl.currentPage.value;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: isActive ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: isActive ? _slides[i].gradient : null,
              color: isActive ? null : AppColors.grey.withOpacity(0.35),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive ? [BoxShadow(color: AppColors.darkSecondary.withOpacity(0.4), blurRadius: 8)] : null,
            ),
          );
        }),
      ));
}

class _SlideWidget extends StatelessWidget {
  final _SlideData data;
  final Animation<double> iconScale;
  final Animation<double> iconFade;
  final Animation<Offset> textSlide;
  final Animation<double> textFade;

  const _SlideWidget({
    required this.data,
    required this.iconScale,
    required this.iconFade,
    required this.textSlide,
    required this.textFade,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: iconScale,
            child: FadeTransition(
              opacity: iconFade,
              child: Container(
                width: 190, height: 190,
                decoration: BoxDecoration(
                  gradient: data.gradient,
                  borderRadius: BorderRadius.circular(48),
                  boxShadow: [
                    BoxShadow(color: AppColors.darkPrimary.withOpacity(0.45), blurRadius: 50, spreadRadius: 6),
                    BoxShadow(color: AppColors.darkSecondary.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: Icon(data.icon, size: 88, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 44),
          SlideTransition(
            position: textSlide,
            child: FadeTransition(
              opacity: textFade,
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => data.gradient.createShader(bounds),
                    child: Text(data.titleKey.tr, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.4), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                  Text(data.descKey.tr, style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.8), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
