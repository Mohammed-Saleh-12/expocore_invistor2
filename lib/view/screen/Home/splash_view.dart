import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/constant/routes.dart';
import '../../../core/services/services.dart';
import '../../widget/Home/expocore_logo.dart';

// ════════════════════════════════════════════════════════════
//  SplashView
// ════════════════════════════════════════════════════════════
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {

  // ── Controllers ──────────────────────────────────────────
  late final AnimationController _bgCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _particleCtrl;

  // ── Animations ───────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringFade;
  late final Animation<double> _textFade;
  late final Animation<Offset>  _textSlide;

  // ── Lifecycle ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _startSequence();
  }

  void _initControllers() {
    _bgCtrl       = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _logoCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
    _textCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  void _initAnimations() {
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.55, curve: Curves.easeIn)),
    );

    _logoScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.14).chain(CurveTween(curve: Curves.easeOut)), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.14, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),  weight: 35),
    ]).animate(_logoCtrl);

    _ringScale = Tween<double>(begin: 0.5, end: 1.7).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );

    _ringFade = Tween<double>(begin: 0.8, end: 0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    _navigate();
  }

  void _navigate() {
    final svc = Get.find<Services>();
    if (svc.isSessionValid) {
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } else if (svc.onboardDone) {
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(AppColors.darkBg, AppColors.darkSurface, _bgCtrl.value)!,
                Color.lerp(AppColors.darkCard, AppColors.darkBg, _bgCtrl.value)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              _buildParticles(size),
              _buildGlowBlob(top: size.height * 0.06, left: -70,  blobSize: 250, color: AppColors.darkPrimary.withOpacity(0.16)),
              _buildGlowBlob(bottom: size.height * 0.06, right: -50, blobSize: 210, color: AppColors.darkSecondary.withOpacity(0.13)),
              _buildGlowBlob(top: size.height * 0.44, right: 10,  blobSize: 140, color: AppColors.darkAccent.withOpacity(0.10)),
              Center(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sections ─────────────────────────────────────────────
  Widget _buildParticles(Size size) => AnimatedBuilder(
        animation: _particleCtrl,
        builder: (_, __) => CustomPaint(
          size: size,
          painter: _ParticlePainter(_particleCtrl.value),
        ),
      );

  Widget _buildGlowBlob({
    double? top, double? bottom, double? left, double? right,
    required double blobSize, required Color color,
  }) =>
      Positioned(
        top: top, bottom: bottom, left: left, right: right,
        child: Container(
          width: blobSize, height: blobSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: color,
            boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)],
          ),
        ),
      );

  Widget _buildContent() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogoWithRing(),
          const SizedBox(height: 40),
          _buildBrandName(),
          const SizedBox(height: 10),
          _buildTagline(),
          const SizedBox(height: 16),
          _buildDividerLine(),
          const SizedBox(height: 16),
          _buildFeatureIcons(),
          const SizedBox(height: 56),
          _buildLoader(),
        ],
      );

  Widget _buildLogoWithRing() => AnimatedBuilder(
        animation: _logoCtrl,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            // pulse ring
            FadeTransition(
              opacity: _ringFade,
              child: ScaleTransition(
                scale: _ringScale,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.darkPrimary.withOpacity(0.6), width: 2),
                  ),
                ),
              ),
            ),
            // logo
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(color: AppColors.darkPrimary.withOpacity(0.45),  blurRadius: 40, spreadRadius: 6),
                      BoxShadow(color: AppColors.darkSecondary.withOpacity(0.25), blurRadius: 60, spreadRadius: 2),
                    ],
                  ),
                  child: const ExpocoreLogo(size: 110),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildBrandName() => SlideTransition(
        position: _textSlide,
        child: FadeTransition(
          opacity: _textFade,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 6),
              children: [
                TextSpan(
                  text: 'EXPO',
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = AppColors.favoriteGradient.createShader(
                          const Rect.fromLTWH(0, 0, 120, 50)),
                  ),
                ),
                const TextSpan(
                  text: 'CORE',
                  style: TextStyle(color: AppColors.darkAccent),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTagline() => FadeTransition(
        opacity: _textFade,
        child: const Text(
          'E M P O W E R I N G   E X H I B I T I O N S',
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
      );

  Widget _buildDividerLine() => FadeTransition(
        opacity: _textFade,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 60, height: 1, color: AppColors.darkPrimary.withOpacity(0.4)),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 6, height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkAccent,
              ),
            ),
            Container(width: 60, height: 1, color: AppColors.darkPrimary.withOpacity(0.4)),
          ],
        ),
      );

  Widget _buildFeatureIcons() => FadeTransition(
        opacity: _textFade,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _FeatureIcon(icon: Icons.dashboard_rounded,    label: 'MANAGE'),
            _FeatureDivider(),
            _FeatureIcon(icon: Icons.analytics_rounded,    label: 'ANALYZE'),
            _FeatureDivider(),
            _FeatureIcon(icon: Icons.campaign_rounded,     label: 'PROMOTE'),
            _FeatureDivider(),
            _FeatureIcon(icon: Icons.people_alt_rounded,   label: 'CONNECT'),
          ],
        ),
      );

  Widget _buildLoader() => FadeTransition(
        opacity: _textFade,
        child: const _PulsingLoader(),
      );
}

// ── Small feature icon ────────────────────────────────────
class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _FeatureIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: AppColors.darkSecondary, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 9, letterSpacing: 1.5)),
        ],
      );
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 1, height: 30,
        color: AppColors.darkPrimary.withOpacity(0.3),
      );
}

// ── Pulsing dots loader ───────────────────────────────────
class _PulsingLoader extends StatefulWidget {
  const _PulsingLoader();

  @override
  State<_PulsingLoader> createState() => _PulsingLoaderState();
}

class _PulsingLoaderState extends State<_PulsingLoader> with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) {
      final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 550))
        ..repeat(reverse: true);
      Future.delayed(Duration(milliseconds: i * 160), () { if (mounted) c.forward(); });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) => AnimatedBuilder(
          animation: _ctrls[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 9,
            height: 9 + _ctrls[i].value * 12,
            decoration: BoxDecoration(
              gradient: AppColors.favoriteGradient,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [BoxShadow(color: AppColors.darkSecondary.withOpacity(0.5), blurRadius: 8)],
            ),
          ),
        )),
      );
}

// ── Floating particles ────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;

  static final _rng = Random(99);
  static final _particles = List.generate(22, (_) => [
    _rng.nextDouble(), _rng.nextDouble(),
    _rng.nextDouble() * 3 + 1.5,
    _rng.nextDouble(),
    _rng.nextBool() ? 0 : 1,
  ]);

  const _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final x      = p[0] * size.width;
      final yBase  = p[1] * size.height;
      final yShift = sin((progress + p[3]) * 2 * pi) * 16;
      final radius = p[2] as double;
      final alpha  = (0.25 + sin((progress + p[3]) * pi) * 0.25).clamp(0.05, 0.55);
      final color  = p[4] == 0 ? AppColors.darkPrimary : AppColors.darkSecondary;

      canvas.drawCircle(
        Offset(x, yBase + yShift), radius,
        Paint()
          ..color = color.withOpacity(alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
