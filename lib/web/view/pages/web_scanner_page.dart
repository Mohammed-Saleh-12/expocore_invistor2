import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/web_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_nav_controller.dart';
import '../../controllers/web_scanner_controller.dart';

class WebScannerPage extends StatelessWidget {
  const WebScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(WebScannerController(), tag: 'web_scanner');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: WebNavController.to.closeDetail,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: WebTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: WebTheme.border),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: WebTheme.text,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'btn_back'.tr,
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'qr_title'.tr,
                style: TextStyle(
                  color: WebTheme.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'qr_instruction'.tr,
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: ctrl.scanCtrl,
                        onDetect: ctrl.onDetect,
                        errorBuilder: (context, error, child) => Container(
                          color: WebTheme.surface,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.videocam_off_rounded,
                                  color: AppColors.grey,
                                  size: 44,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'scanner_camera_error'.tr,
                                  style: TextStyle(
                                    color: WebTheme.text,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'scanner_camera_error_hint'.tr,
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.darkPrimary,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Obx(
                          () => GestureDetector(
                            onTap: ctrl.toggleTorch,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: ctrl.torch.value
                                    ? AppColors.darkAccent
                                    : Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                ctrl.torch.value
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                color: WebTheme.text,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                final result = ctrl.result.value;
                if (result == null) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: WebTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'qr_scan_success'.tr,
                            style: TextStyle(
                              color: WebTheme.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        result,
                        style: const TextStyle(
                          color: AppColors.darkPink,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: ctrl.reset,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.favoriteGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'qr_scan_again'.tr,
                            style: TextStyle(
                              color: WebTheme.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
