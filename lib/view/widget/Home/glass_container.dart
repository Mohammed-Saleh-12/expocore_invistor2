import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width:  width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.darkPink.withOpacity(0.3), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
