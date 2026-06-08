import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../../core/services/services.dart';
import '../../widget/Home/custom_button.dart';
import '../../widget/Home/expocore_logo.dart';

// ════════════════════════════════════════════════════════════
//  MODEL  – slide data
// ════════════════════════════════════════════════════════════
class _SlideData {
  final IconData icon;
  final String   titleKey;
  final String   descKey;
  final LinearGradient gradient;

  const _SlideData({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.gradient,
  });
}

const _slides = [
  _SlideData(
    icon: Icons.store_rounded,
    titleKey: 'onboard_t1',
    descKey: 'onboard_d1',
    gradient: AppColors.favoriteGradient,
  ),
  _SlideData(
    icon: Icons.analytics_rounded,
    titleKey: 'onboard_t2',
    descKey: 'onboard_d2',
    gradient: LinearGradient(
      colors: [AppColors.darkPrimary, AppColors.darkAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  _SlideData(
    icon: Icons.favorite_rounded,
    titleKey: 'onboard_t3',
    descKey: 'onboard_d3',
    gradient: LinearGradient(
      colors: [AppColors.darkAccent, AppColors.darkSecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
];

// ════════════════════════════════════════════════════════════
//  VIEW
// ════════════════════════════════════════════════════════════
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────
  final _pageCtrl = PageController();
  int _currentPage = 0;

  // ── Animation ────────────────────────────────────────────
  late final AnimationController _slideCtrl;
  late Animation<double>  _iconScale;
  late Animation<double>  _iconFade;
  late Animation<Offset>  _textSlide;
  late Animation<double>  _textFade;

  // ── Lifecycle ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buildAnimations();
    _slideCtrl.forward();
  }

  void _buildAnimations() {
    _iconScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.elasticOut),
    );
    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideCtrl, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideCtrl, curve: const Interval(0.3, 1, curve: Curves.easeOut)),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideCtrl, curve: const Interval(0.3, 1, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────
  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _slideCtrl.forward(from: 0);
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Get.find<Services>().setOnboardDone();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSkipButton(),
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (_, i) => _SlideWidget(
                    data: _slides[i],
                    iconScale: _iconScale,
                    iconFade: _iconFade,
                    textSlide: _textSlide,
                    textFade: _textFade,
                  ),
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // mini logo in header
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
              onPressed: _finish,
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

  Widget _buildBottomSection() => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          children: [
            _buildDots(),
            const SizedBox(height: 28),
            CustomButton(
              label: _currentPage < _slides.length - 1 ? 'onboard_next'.tr : 'onboard_start'.tr,
              onTap: _next,
            ),
          ],
        ),
      );

  Widget _buildDots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_slides.length, (i) {
          final isActive = i == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: isActive ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: isActive ? _slides[i].gradient : null,
              color: isActive ? null : AppColors.grey.withOpacity(0.35),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [BoxShadow(color: AppColors.darkSecondary.withOpacity(0.4), blurRadius: 8)]
                  : null,
            ),
          );
        }),
      );
}

// ════════════════════════════════════════════════════════════
//  WIDGET  – single slide
// ════════════════════════════════════════════════════════════
class _SlideWidget extends StatelessWidget {
  final _SlideData            data;
  final Animation<double>     iconScale;
  final Animation<double>     iconFade;
  final Animation<Offset>     textSlide;
  final Animation<double>     textFade;

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
          _buildIconBox(),
          const SizedBox(height: 44),
          _buildText(),
        ],
      ),
    );
  }

  Widget _buildIconBox() => ScaleTransition(
        scale: iconScale,
        child: FadeTransition(
          opacity: iconFade,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              gradient: data.gradient,
              borderRadius: BorderRadius.circular(48),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkPrimary.withOpacity(0.45),
                  blurRadius: 50,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: AppColors.darkSecondary.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(data.icon, size: 88, color: Colors.white),
          ),
        ),
      );

  Widget _buildText() => SlideTransition(
        position: textSlide,
        child: FadeTransition(
          opacity: textFade,
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => data.gradient.createShader(bounds),
                child: Text(
                  data.titleKey.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.descKey.tr,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
