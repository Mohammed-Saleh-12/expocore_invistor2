import 'package:expocore_invistor2/core/constant/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Controller ─────────────────────────────────────────────
class _AppTextFieldController extends GetxController {
  bool obscure = true;
  void toggle() {
    obscure = !obscure;
    update();
  }
}

// ── Widget ─────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.controller,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_AppTextFieldController>(
      init: _AppTextFieldController(),
      global: false,
      builder: (ctrl) => TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword && ctrl.obscure,
        keyboardType: keyboardType,
        maxLines: isPassword ? 1 : maxLines,
        maxLength: maxLength,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    ctrl.obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.grey,
                    size: 20,
                  ),
                  onPressed: ctrl.toggle,
                )
              : suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              // Use theme's primary so the border updates when the theme changes.
              color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}
