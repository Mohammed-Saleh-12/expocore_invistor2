import 'package:flutter/material.dart';
import '../web_theme.dart';
import '../../core/constant/appcolors.dart';

// ════════════════════════════════════════════════════════════
//  WebSectionHeader  —  عنوان صفحة موحّد
// ════════════════════════════════════════════════════════════
class WebSectionHeader extends StatelessWidget {
  final String  title;
  final String? subtitle;
  final Widget? action;

  const WebSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5, height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.favoriteGradient,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(color: WebTheme.text, fontSize: 24, fontWeight: FontWeight.w900)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!,
                    style: TextStyle(color: AppColors.grey.withOpacity(0.85), fontSize: 14)),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
