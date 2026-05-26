import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../../core/services/services.dart';
import '../../widget/Home/custom_button.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});
  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _ctrl = PageController();
  int _page   = 0;

  final _slides = [
    {'icon': Icons.store, 'title': 'تصفح المعارض واحجز جناحك بكل سهولة', 'desc': 'استعرض أفضل المعارض التجارية واحجز جناحك المثالي في خطوات بسيطة مع خريطة 3D تفاعلية.'},
    {'icon': Icons.analytics, 'title': 'حلل أداء جناحك وتابع نموه', 'desc': 'رصد مؤشرات الأداء الرئيسية في الوقت الفعلي: الزوار، التفاعل، الحملات، والتقارير التفصيلية.'},
    {'icon': Icons.favorite, 'title': 'احفظ مفضلاتك وأدر فعالياتك', 'desc': 'أنشئ فعاليات حصرية لجناحك، وأضف المعارض والفعاليات المفضلة لمتابعتها بسهولة.'},
  ];

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Get.find<Services>().setOnboardDone();
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(colors: [AppColors.darkBg, AppColors.darkSurface], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: isDark ? null : AppColors.lightSurface,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () { Get.find<Services>().setOnboardDone(); Get.offAllNamed(AppRoutes.LOGIN); },
                    child: const Text('تخطي', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _slides.length,
                  itemBuilder: (_, i) => _Slide(slide: _slides[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _page == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: _page == i ? AppColors.darkCTAGradient : null,
                          color: _page == i ? null : AppColors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(label: _page < 2 ? 'التالي' : 'ابدأ الآن', onTap: _next),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final Map<String, dynamic> slide;
  const _Slide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              gradient: AppColors.darkCTAGradient,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.4), blurRadius: 40, spreadRadius: 5)],
            ),
            child: Icon(slide['icon'] as IconData, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 40),
          Text(slide['title'] as String, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(slide['desc'] as String, style: const TextStyle(fontSize: 14, color: AppColors.grey, height: 1.7), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
