import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../controller/Home/splash_controller.dart';
import '../../widget/Home/expocore_logo.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SplashController>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: AnimatedBuilder(
        animation: ctrl.bgCtrl,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(AppColors.darkBg, AppColors.darkSurface, ctrl.bgCtrl.value)!,
                Color.lerp(AppColors.darkCard, AppColors.darkBg, ctrl.bgCtrl.value)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              _buildParticles(ctrl, size),
              _buildGlowBlob(top: size.height * 0.06, left: -70, blobSize: 250, color: AppColors.darkPrimary.withOpacity(0.16)),
              _buildGlowBlob(bottom: size.height * 0.06, right: -50, blobSize: 210, color: AppColors.darkSecondary.withOpacity(0.13)),
              _buildGlowBlob(top: size.height * 0.44, right: 10, blobSize: 140, color: AppColors.darkAccent.withOpacity(0.10)),
              Center(child: _buildContent(ctrl)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticles(SplashController ctrl, Size size) => AnimatedBuilder(
        animation: ctrl.particleCtrl,
        builder: (_, __) => CustomPaint(size: size, painter: _ParticlePainter(ctrl.particleCtrl.value)),
      );

  Widget _buildGlowBlob({double? top, double? bottom, double? left, double? right, required double blobSize, required Color color}) =>
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

  Widget _buildContent(SplashController ctrl) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogoWithRing(ctrl),
          const SizedBox(height: 40),
          _buildBrandName(ctrl),
          const SizedBox(height: 10),
          _buildTagline(ctrl),
          const SizedBox(height: 16),
          _buildDividerLine(ctrl),
          const SizedBox(height: 16),
          _buildFeatureIcons(ctrl),
          const SizedBox(height: 56),
          _buildLoader(ctrl),
        ],
      );

  Widget _buildLogoWithRing(SplashController ctrl) => AnimatedBuilder(
        animation: ctrl.logoCtrl,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: ctrl.ringFade,
              child: ScaleTransition(
                scale: ctrl.ringScale,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.darkPrimary.withOpacity(0.6), width: 2),
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: ctrl.logoFade,
              child: ScaleTransition(
                scale: ctrl.logoScale,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(color: AppColors.darkPrimary.withOpacity(0.45), blurRadius: 40, spreadRadius: 6),
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

  Widget _buildBrandName(SplashController ctrl) => SlideTransition(
        position: ctrl.textSlide,
        child: FadeTransition(
          opacity: ctrl.textFade,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 6),
              children: [
                TextSpan(
                  text: 'EXPO',
                  style: TextStyle(
                    foreground: Paint()..shader = AppColors.favoriteGradient.createShader(const Rect.fromLTWH(0, 0, 120, 50)),
                  ),
                ),
                const TextSpan(text: 'CORE', style: TextStyle(color: AppColors.darkAccent)),
              ],
            ),
          ),
        ),
      );

  Widget _buildTagline(SplashController ctrl) => FadeTransition(
        opacity: ctrl.textFade,
        child: const Text(
          'E M P O W E R I N G   E X H I B I T I O N S',
          style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 2),
        ),
      );

  Widget _buildDividerLine(SplashController ctrl) => FadeTransition(
        opacity: ctrl.textFade,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 60, height: 1, color: AppColors.darkPrimary.withOpacity(0.4)),
            Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 6, height: 6,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.darkAccent)),
            Container(width: 60, height: 1, color: AppColors.darkPrimary.withOpacity(0.4)),
          ],
        ),
      );

  Widget _buildFeatureIcons(SplashController ctrl) => FadeTransition(
        opacity: ctrl.textFade,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FeatureIcon(icon: Icons.dashboard_rounded, label: 'MANAGE'),
            _FeatureDivider(),
            _FeatureIcon(icon: Icons.analytics_rounded, label: 'ANALYZE'),
            _FeatureDivider(),
            _FeatureIcon(icon: Icons.campaign_rounded, label: 'PROMOTE'),
            _FeatureDivider(),
            _FeatureIcon(icon: Icons.people_alt_rounded, label: 'CONNECT'),
          ],
        ),
      );

  Widget _buildLoader(SplashController ctrl) => FadeTransition(
        opacity: ctrl.textFade,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) => AnimatedBuilder(
            animation: ctrl.pulsingCtrls[i],
            builder: (_, __) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 9,
              height: 9 + ctrl.pulsingCtrls[i].value * 12,
              decoration: BoxDecoration(
                gradient: AppColors.favoriteGradient,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [BoxShadow(color: AppColors.darkSecondary.withOpacity(0.5), blurRadius: 8)],
              ),
            ),
          )),
        ),
      );
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;
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

class _ParticlePainter extends CustomPainter {
  final double progress;

  static final _rng = Random(99);
  static final _particles = List.generate(22, (_) => [
    _rng.nextDouble(), _rng.nextDouble(), _rng.nextDouble() * 3 + 1.5,
    _rng.nextDouble(), _rng.nextBool() ? 0 : 1,
  ]);

  const _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final x = p[0] * size.width;
      final yBase = p[1] * size.height;
      final yShift = sin((progress + p[3]) * 2 * pi) * 16;
      final radius = p[2] as double;
      final alpha = (0.25 + sin((progress + p[3]) * pi) * 0.25).clamp(0.05, 0.55);
      final color = p[4] == 0 ? AppColors.darkPrimary : AppColors.darkSecondary;
      canvas.drawCircle(
        Offset(x, yBase + yShift), radius,
        Paint()..color = color.withOpacity(alpha)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
