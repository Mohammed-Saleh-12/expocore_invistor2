import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  late final AnimationController bgCtrl;
  late final AnimationController logoCtrl;
  late final AnimationController textCtrl;
  late final AnimationController particleCtrl;
  late final List<AnimationController> pulsingCtrls;

  late final Animation<double> logoScale;
  late final Animation<double> logoFade;
  late final Animation<double> ringScale;
  late final Animation<double> ringFade;
  late final Animation<double> textFade;
  late final Animation<Offset> textSlide;

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    _initAnimations();
    _startSequence();
  }

  void _initControllers() {
    bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
    logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
    textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    pulsingCtrls = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      )..repeat(reverse: true);
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (!isClosed) c.forward();
      });
      return c;
    });
  }

  void _initAnimations() {
    logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: logoCtrl, curve: const Interval(0, 0.55, curve: Curves.easeIn)),
    );
    logoScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.14).chain(CurveTween(curve: Curves.easeOut)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.14, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
    ]).animate(logoCtrl);
    ringScale = Tween<double>(begin: 0.5, end: 1.7)
        .animate(CurvedAnimation(parent: logoCtrl, curve: Curves.easeOut));
    ringFade = Tween<double>(begin: 0.8, end: 0)
        .animate(CurvedAnimation(parent: logoCtrl, curve: Curves.easeOut));
    textFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: textCtrl, curve: Curves.easeIn));
    textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: textCtrl, curve: Curves.easeOut));
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (isClosed) return;
    logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    if (isClosed) return;
    textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (isClosed) return;
    navigate();
  }

  void navigate() {
    final svc = Get.find<Services>();
    if (!svc.langChosen) {
      Get.offAllNamed(AppRoutes.LANGUAGE_PICKER);
    } else if (svc.isSessionValid) {
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } else if (svc.onboardDone) {
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }

  double particleShift(double xFrac, double yFrac, double speedFrac, double phase, double progress) {
    return sin((progress + phase) * 2 * pi) * 16;
  }

  @override
  void onClose() {
    bgCtrl.dispose();
    logoCtrl.dispose();
    textCtrl.dispose();
    particleCtrl.dispose();
    for (final c in pulsingCtrls) {
      c.dispose();
    }
    super.onClose();
  }
}
