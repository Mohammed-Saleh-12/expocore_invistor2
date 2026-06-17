import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import '../../core/constant/routes.dart';
import '../../core/functions/locale_helper.dart';
import '../../core/services/services.dart';

class LanguagePickerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final selected = 'ar'.obs;

  late final AnimationController anim;
  late final Animation<double> fadeAnim;
  late final Animation<Offset>  slideAnim;

  @override
  void onInit() {
    super.onInit();
    anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    fadeAnim  = CurvedAnimation(parent: anim, curve: Curves.easeOut);
    slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
  }

  void pick(String lang) {
    selected.value = lang;
    changeAppLanguage(lang);
  }

  Future<void> proceed() async {
    final svc = Get.find<Services>();
    await svc.setLangChosen();
    if (svc.onboardDone) {
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }

  @override
  void onClose() {
    anim.dispose();
    super.onClose();
  }
}
