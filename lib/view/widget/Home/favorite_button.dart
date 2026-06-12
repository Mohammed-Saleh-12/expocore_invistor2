import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final scale = 1.0.obs;
    return Obx(() => GestureDetector(
          onTap: () async {
            scale.value = 1.35;
            onTap();
            await Future.delayed(const Duration(milliseconds: 180));
            scale.value = 1.0;
          },
          child: AnimatedScale(
            scale: scale.value,
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
              child: isFavorite
                  ? ShaderMask(
                      shaderCallback: (b) => AppColors.favoriteGradient.createShader(b),
                      child: Icon(Icons.favorite, color: Colors.white, size: size * 0.55),
                    )
                  : Icon(Icons.favorite_border, color: Colors.white, size: size * 0.55),
            ),
          ),
        ));
  }
}
