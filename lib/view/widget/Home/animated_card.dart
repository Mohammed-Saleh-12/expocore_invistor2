import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  const AnimatedCard({super.key, required this.child, this.onTap, this.margin});

  @override
  Widget build(BuildContext context) {
    final pressed = false.obs;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() => GestureDetector(
          onTapDown: (_) => pressed.value = true,
          onTapUp: (_) {
            pressed.value = false;
            onTap?.call();
          },
          onTapCancel: () => pressed.value = false,
          child: AnimatedScale(
            scale: pressed.value ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            child: Container(
              margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.darkCardGradient : null,
                color: isDark ? null : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: child,
            ),
          ),
        ));
  }
}
