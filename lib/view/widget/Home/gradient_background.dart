import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const GradientBackground({super.key, required this.child, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.splashGradient
            : const LinearGradient(
                colors: [AppColors.lightBg, AppColors.lightSurface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
      child: child,
    );
  }
}
