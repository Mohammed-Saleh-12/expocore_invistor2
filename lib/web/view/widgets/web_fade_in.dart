import 'package:flutter/material.dart';

class WebFadeIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Offset beginOffset;
  final Duration duration;
  final bool scale;

  const WebFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, 0.18),
    this.duration = const Duration(milliseconds: 700),
    this.scale = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (_, value, __) {
        final offset = Offset(
          beginOffset.dx * (1.0 - value),
          beginOffset.dy * (1.0 - value),
        );
        final scaleVal = scale ? (0.9 + 0.1 * value) : 1.0;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(offset.dx * 100, offset.dy * 100),
            child: Transform.scale(scale: scaleVal, child: child),
          ),
        );
      },
    );
  }
}
