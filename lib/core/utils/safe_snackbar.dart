import 'package:flutter/material.dart';
import 'package:get/get.dart';

void safeSnackbar(
  String title,
  String message, {
  SnackPosition snackPosition = SnackPosition.BOTTOM,
  Color? backgroundColor,
  Color? colorText,
  EdgeInsets margin = const EdgeInsets.all(16),
  double borderRadius = 12,
  Duration duration = const Duration(seconds: 3),
}) {
  void show() {
    try {
      Get.snackbar(
        title,
        message,
        snackPosition: snackPosition,
        backgroundColor: backgroundColor,
        colorText: colorText,
        margin: margin,
        borderRadius: borderRadius,
        duration: duration,
      );
    } catch (e) {
      debugPrint('[ExpoCore] safeSnackbar skipped — overlay not ready: $e');
    }
  }

  if (Get.overlayContext != null) {
    show();
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) => show());
  }
}
