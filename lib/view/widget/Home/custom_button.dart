import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final Color? gradient;

  const CustomButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 52,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      );
    }

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: AppColors.favoriteGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
