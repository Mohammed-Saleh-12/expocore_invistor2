import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final bool obscure;
  final TextInputType keyboard;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffixWidget,
    this.obscure = false,
    this.keyboard = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:  controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator:   validator,
      maxLines:    obscure ? 1 : maxLines,
      readOnly:    readOnly,
      onTap:       onTap,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText:    hint,
        hintStyle:   TextStyle(color: AppColors.grey.withOpacity(0.7)),
        prefixIcon:  prefixIcon != null ? Icon(prefixIcon) : null,
        suffix:      suffixWidget,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
