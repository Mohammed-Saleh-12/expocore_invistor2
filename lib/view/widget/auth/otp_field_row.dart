import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════════════════
//  _OtpFieldRowController  —  controller داخلي (global: false)
// ════════════════════════════════════════════════════════════
class _OtpFieldRowController extends GetxController {
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  final int length;

  _OtpFieldRowController(this.length);

  @override
  void onInit() {
    super.onInit();
    controllers = List.generate(length, (_) => TextEditingController());
    focusNodes  = List.generate(length, (_) => FocusNode());
  }

  @override
  void onClose() {
    for (final c in controllers) c.dispose();
    for (final f in focusNodes) f.dispose();
    super.onClose();
  }

  void onChanged(int i, String val, ValueChanged<String> onCompleted) {
    if (val.length == 1 && i < length - 1) focusNodes[i + 1].requestFocus();
    if (val.isEmpty && i > 0) focusNodes[i - 1].requestFocus();
    final code = controllers.map((c) => c.text).join();
    if (code.length == length) onCompleted(code);
  }

  void clear() {
    for (final c in controllers) {
      c.clear();
    }
    if (focusNodes.isNotEmpty) focusNodes[0].requestFocus();
  }
}

// ════════════════════════════════════════════════════════════
//  OtpFieldRow  —  widget مشترك لإدخال OTP
// ════════════════════════════════════════════════════════════
class OtpFieldRow extends StatelessWidget {
  final int length;
  final ValueChanged<String> onCompleted;

  const OtpFieldRow({
    super.key,
    this.length = 6,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_OtpFieldRowController>(
      init: _OtpFieldRowController(length),
      global: false, // ← منع تعارض instances متعددة
      builder: (ctrl) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          ctrl.length,
          (i) => Container(
            width: 48,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextFormField(
              controller: ctrl.controllers[i],
              focusNode: ctrl.focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              onChanged: (val) => ctrl.onChanged(i, val, onCompleted),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: context.isDarkMode
                    ? const Color(0xFF2A2A3D)
                    : const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF7A1FFF).withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF7A1FFF), width: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
