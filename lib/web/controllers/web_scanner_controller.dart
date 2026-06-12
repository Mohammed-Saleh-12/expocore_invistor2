import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class WebScannerController extends GetxController {
  final MobileScannerController scanCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final result = RxnString();
  final torch = false.obs;

  void onDetect(BarcodeCapture cap) {
    if (result.value != null) return;
    final code = cap.barcodes.firstOrNull?.rawValue;
    if (code == null) return;
    result.value = code;
    scanCtrl.stop();
  }

  void reset() {
    result.value = null;
    scanCtrl.start();
  }

  void toggleTorch() {
    scanCtrl.toggleTorch();
    torch.value = !torch.value;
  }

  @override
  void onClose() {
    scanCtrl.dispose();
    super.onClose();
  }
}
