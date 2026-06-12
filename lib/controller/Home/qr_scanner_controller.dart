import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerController extends GetxController with GetSingleTickerProviderStateMixin {
  final MobileScannerController scanCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final scanned = false.obs;
  final torchOn = false.obs;
  final scannedValue = RxnString();

  late final AnimationController lineCtrl;
  late final Animation<double> scanLine;

  @override
  void onInit() {
    super.onInit();
    lineCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    scanLine = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: lineCtrl, curve: Curves.easeInOut),
    );
  }

  void onDetect(BarcodeCapture capture) {
    if (scanned.value) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    scanned.value = true;
    scannedValue.value = barcode.rawValue;
    scanCtrl.stop();
  }

  void toggleTorch() {
    scanCtrl.toggleTorch();
    torchOn.value = !torchOn.value;
  }

  void reset() {
    scanned.value = false;
    scannedValue.value = null;
    scanCtrl.start();
  }

  @override
  void onClose() {
    lineCtrl.dispose();
    scanCtrl.dispose();
    super.onClose();
  }
}
