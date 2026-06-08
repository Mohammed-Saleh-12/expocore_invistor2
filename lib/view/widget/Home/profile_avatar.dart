import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constant/appcolors.dart';

// ════════════════════════════════════════════════════════════
//  ProfileAvatar  —  صورة شخصية متعددة المنصات + زر تعديل
//  • تعرض الصورة المختارة (web/mobile) أو الحرف الأول
//  • زر كاميرا للتعديل عند editable = true
// ════════════════════════════════════════════════════════════
class ProfileAvatar extends StatelessWidget {
  final XFile?      image;
  final String      fallbackLetter;
  final double      size;
  final bool        editable;
  final VoidCallback? onEdit;

  const ProfileAvatar({
    super.key,
    required this.image,
    required this.fallbackLetter,
    this.size = 80,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: image == null ? AppColors.darkCTAGradient : null,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.4), blurRadius: 18)],
            ),
            clipBehavior: Clip.antiAlias,
            child: image == null
                ? Center(
                    child: Text(
                      fallbackLetter.isNotEmpty ? fallbackLetter : 'ش',
                      style: TextStyle(color: Colors.white, fontSize: size * 0.4, fontWeight: FontWeight.w800),
                    ),
                  )
                : _buildImage(),
          ),
          if (editable)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                decoration: BoxDecoration(
                  gradient: AppColors.favoriteGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.darkBg, width: 2),
                ),
                child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: size * 0.18),
              ),
            ),
        ],
      ),
    );

    // عند التعديل: كامل الصورة قابلة للنقر لاختيار صورة
    if (!editable) return avatar;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onEdit,
        child: avatar,
      ),
    );
  }

  Widget _buildImage() {
    // على الويب: المسار blob/URL → Image.network
    // على الجوال: ملف محلي → Image.file
    if (kIsWeb) {
      return Image.network(image!.path, fit: BoxFit.cover, width: size, height: size,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white));
    }
    return Image.file(File(image!.path), fit: BoxFit.cover, width: size, height: size,
        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white));
  }
}
