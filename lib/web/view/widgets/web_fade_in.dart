import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
//  WebFadeIn  —  أنميشن دخول (تلاشٍ + انزلاق + تكبير) قابل للتأخير
// ════════════════════════════════════════════════════════════
class WebFadeIn extends StatefulWidget {
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
  State<WebFadeIn> createState() => _WebFadeInState();
}

class _WebFadeInState extends State<WebFadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: widget.scale ? 0.9 : 1.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    // تشغيل موثوق بعد أول إطار + التأخير المطلوب
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.scale
            ? ScaleTransition(scale: _scale, child: widget.child)
            : widget.child,
      ),
    );
  }
}
