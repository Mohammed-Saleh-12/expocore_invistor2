import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../../core/services/services.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _tagCtrl;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<Offset> _tagSlide;
  late Animation<double> _tagFade;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _tagCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _logoFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn));
    _logoScale = Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _tagSlide  = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut));
    _tagFade   = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeIn));
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _tagCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    _navigate();
  }

  void _navigate() {
    final svc = Get.find<Services>();
    if (svc.isLoggedIn) {
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } else if (svc.onboardDone) {
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            Positioned(top: -80, left: -80, child: _glowCircle(200, AppColors.darkPrimary.withOpacity(0.3))),
            Positioned(bottom: -60, right: -60, child: _glowCircle(160, AppColors.darkSecondary.withOpacity(0.2))),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          gradient: AppColors.darkCTAGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)],
                        ),
                        child: const Center(
                          child: Text('EC', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _logoFade,
                    child: const Text('EXPOCORE', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 4)),
                  ),
                  const SizedBox(height: 8),
                  SlideTransition(
                    position: _tagSlide,
                    child: FadeTransition(
                      opacity: _tagFade,
                      child: const Text('منصة المستثمر', style: TextStyle(color: AppColors.darkPink, fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 60),
                  FadeTransition(
                    opacity: _tagFade,
                    child: const SizedBox(
                      width: 32, height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowCircle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
