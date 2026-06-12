import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';

class OnboardingController extends GetxController with GetTickerProviderStateMixin {
  final pageCtrl = PageController();
  final currentPage = 0.obs;

  late final AnimationController slideCtrl;
  late Animation<double> iconScale;
  late Animation<double> iconFade;
  late Animation<Offset> textSlide;
  late Animation<double> textFade;

  @override
  void onInit() {
    super.onInit();
    slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _buildAnimations();
    slideCtrl.forward();
  }

  void _buildAnimations() {
    iconScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: slideCtrl, curve: Curves.elasticOut),
    );
    iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: slideCtrl, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );
    textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: slideCtrl, curve: const Interval(0.3, 1, curve: Curves.easeOut)),
    );
    textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: slideCtrl, curve: const Interval(0.3, 1, curve: Curves.easeIn)),
    );
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    slideCtrl.forward(from: 0);
  }

  void next(int totalSlides) {
    if (currentPage.value < totalSlides - 1) {
      pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      finish();
    }
  }

  void finish() {
    Get.find<Services>().setOnboardDone();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  @override
  void onClose() {
    pageCtrl.dispose();
    slideCtrl.dispose();
    super.onClose();
  }
}
