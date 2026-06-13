import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════════════════
//  safeSnackbar  —  null-overlay-safe wrapper for Get.snackbar
//
//  GetX's snackbar calls overlayState!.insertAll(...).
//  If called before the first frame renders (e.g. from a
//  controller onInit that fires before the GetMaterialApp
//  overlay is mounted), the null assertion crashes the app.
//
//  This wrapper:
//  1. Shows immediately if the overlay is already ready.
//  2. Defers by one frame via addPostFrameCallback if not.
//  3. Catches any remaining exception silently so the app
//     never crashes due to a missing snackbar.
// ════════════════════════════════════════════════════════════
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

  // If the overlay context is available, show immediately.
  if (Get.overlayContext != null) {
    show();
  } else {
    // Defer to the next frame so the overlay has time to mount.
    WidgetsBinding.instance.addPostFrameCallback((_) => show());
  }
}
