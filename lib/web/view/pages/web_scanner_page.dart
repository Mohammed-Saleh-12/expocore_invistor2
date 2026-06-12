import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_nav_controller.dart';

// ════════════════════════════════════════════════════════════
//  WebScannerPage  —  مسح QR / باركود (يعمل على الويب)
// ════════════════════════════════════════════════════════════
class WebScannerPage extends StatefulWidget {
  const WebScannerPage({super.key});

  @override
  State<WebScannerPage> createState() => _WebScannerPageState();
}

class _WebScannerPageState extends State<WebScannerPage> {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  String? _result;
  bool _torch = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture cap) {
    if (_result != null) return;
    final code = cap.barcodes.firstOrNull?.rawValue;
    if (code == null) return;
    setState(() => _result = code);
    _ctrl.stop();
  }

  void _reset() {
    setState(() => _result = null);
    _ctrl.start();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              GestureDetector(
                onTap: WebNavController.to.closeDetail,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: WebTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: WebTheme.border),
                    ),
                    child: Icon(Icons.arrow_forward_rounded, color: WebTheme.text, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text('رجوع', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                ]),
              ),
              const SizedBox(height: 20),
              Text('مسح QR / باركود',
                  style: TextStyle(color: WebTheme.text, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('وجّه الكاميرا نحو الرمز للمسح',
                  style: TextStyle(color: AppColors.grey, fontSize: 14)),
              const SizedBox(height: 20),

              // Scanner viewport
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _ctrl,
                        onDetect: _onDetect,
                        errorBuilder: (context, error, child) => Container(
                          color: WebTheme.surface,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.videocam_off_rounded, color: AppColors.grey, size: 44),
                                SizedBox(height: 12),
                                Text('تعذّر الوصول للكاميرا',
                                    style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
                                SizedBox(height: 6),
                                Text('تأكد من السماح بالوصول للكاميرا في المتصفح',
                                    style: TextStyle(color: AppColors.grey, fontSize: 12), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // frame overlay
                      Center(
                        child: Container(
                          width: 220, height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.darkPrimary, width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      // torch
                      Positioned(
                        top: 12, right: 12,
                        child: GestureDetector(
                          onTap: () { _ctrl.toggleTorch(); setState(() => _torch = !_torch); },
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: _torch ? AppColors.darkAccent : Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_torch ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: WebTheme.text, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Result
              if (_result != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: WebTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.success.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                        const SizedBox(width: 8),
                        Text('تم المسح بنجاح', style: TextStyle(color: WebTheme.text, fontSize: 16, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 12),
                      SelectableText(_result!, style: TextStyle(color: AppColors.darkPink, fontSize: 14)),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _reset,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(12)),
                          child: Text('مسح آخر', style: TextStyle(color: WebTheme.text, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
