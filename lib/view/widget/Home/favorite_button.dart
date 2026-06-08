import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';

class FavoriteButton extends StatefulWidget {
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
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = Tween<double>(begin: 1, end: 1.35).chain(CurveTween(curve: Curves.elasticOut)).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
          ),
          child: widget.isFavorite
              ? ShaderMask(
                  shaderCallback: (bounds) => AppColors.favoriteGradient.createShader(bounds),
                  child: Icon(Icons.favorite, color: Colors.white, size: widget.size * 0.55),
                )
              : Icon(Icons.favorite_border, color: Colors.white, size: widget.size * 0.55),
        ),
      ),
    );
  }
}
