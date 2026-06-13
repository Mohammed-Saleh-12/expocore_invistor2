import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constant/appcolors.dart';
import '../../../controller/Home/qr_scanner_controller.dart';

class QrScannerView extends StatelessWidget {
  const QrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QrScannerController>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: ctrl.scanCtrl, onDetect: ctrl.onDetect),
          CustomPaint(painter: _OverlayPainter(), child: const SizedBox.expand()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Obx(() => Row(
                children: [
                  _CircleBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: Get.back),
                  const Spacer(),
                  Text('qr_title'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  _CircleBtn(
                    icon: ctrl.torchOn.value ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    onTap: ctrl.toggleTorch,
                    active: ctrl.torchOn.value,
                  ),
                ],
              )),
            ),
          ),
          Center(child: _ViewfinderFrame(ctrl: ctrl)),
          Align(
            alignment: const Alignment(0, 0.75),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Text('qr_instruction'.tr, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _TypeChip(label: 'QR Code', icon: Icons.qr_code_2_rounded),
                    const SizedBox(width: 8),
                    const _TypeChip(label: 'Barcode', icon: Icons.barcode_reader),
                    const SizedBox(width: 8),
                    _TypeChip(label: 'qr_ticket_label'.tr, icon: Icons.confirmation_number_outlined),
                  ],
                ),
              ],
            ),
          ),
          Obx(() {
            final val = ctrl.scannedValue.value;
            if (val == null) return const SizedBox.shrink();
            return _ResultOverlay(value: val, ctrl: ctrl);
          }),
        ],
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  final String value;
  final QrScannerController ctrl;
  const _ResultOverlay({required this.value, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _ResultSheet(
          value: value,
          onScanAgain: () { ctrl.reset(); },
          onClose: () => Get.back(),
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const boxSize = 260.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: boxSize, height: boxSize);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.65));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ViewfinderFrame extends StatelessWidget {
  final QrScannerController ctrl;
  const _ViewfinderFrame({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    const size = 260.0;
    const corner = 22.0;
    const thick = 4.0;
    const cLen = 28.0;
    return SizedBox(
      width: size, height: size,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _Corner(r: corner, thick: thick, len: cLen, top: true, left: true)),
          Positioned(top: 0, right: 0, child: _Corner(r: corner, thick: thick, len: cLen, top: true, left: false)),
          Positioned(bottom: 0, left: 0, child: _Corner(r: corner, thick: thick, len: cLen, top: false, left: true)),
          Positioned(bottom: 0, right: 0, child: _Corner(r: corner, thick: thick, len: cLen, top: false, left: false)),
          AnimatedBuilder(
            animation: ctrl.scanLine,
            builder: (_, __) => Positioned(
              left: 16, right: 16,
              top: 16 + (size - 32) * ctrl.scanLine.value,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    AppColors.darkPrimary.withOpacity(0.9),
                    AppColors.darkSecondary.withOpacity(0.9),
                    Colors.transparent,
                  ]),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final double r, thick, len;
  final bool top, left;
  const _Corner({required this.r, required this.thick, required this.len, required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: len + r, height: len + r,
      child: CustomPaint(painter: _CornerPainter(r: r, thick: thick, len: len, top: top, left: left)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double r, thick, len;
  final bool top, left;
  const _CornerPainter({required this.r, required this.thick, required this.len, required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(colors: [AppColors.darkPrimary, AppColors.darkSecondary])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = thick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    if (top && left) {
      path.moveTo(0, len); path.lineTo(0, r);
      path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
      path.lineTo(len, 0);
    } else if (top && !left) {
      path.moveTo(size.width, len); path.lineTo(size.width, r);
      path.arcToPoint(Offset(size.width - r, 0), radius: Radius.circular(r), clockwise: false);
      path.lineTo(size.width - len, 0);
    } else if (!top && left) {
      path.moveTo(0, size.height - len); path.lineTo(0, size.height - r);
      path.arcToPoint(Offset(r, size.height), radius: Radius.circular(r), clockwise: false);
      path.lineTo(len, size.height);
    } else {
      path.moveTo(size.width, size.height - len); path.lineTo(size.width, size.height - r);
      path.arcToPoint(Offset(size.width - r, size.height), radius: Radius.circular(r));
      path.lineTo(size.width - len, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ResultSheet extends StatelessWidget {
  final String value;
  final VoidCallback onScanAgain;
  final VoidCallback onClose;
  const _ResultSheet({required this.value, required this.onScanAgain, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(gradient: AppColors.favoriteGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.4), blurRadius: 20)]),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text('qr_scan_success'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.darkBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3))),
            child: SelectableText(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.darkPink, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onScanAgain,
                  style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.darkPrimary.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: Text('qr_scan_again'.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: AppColors.darkPrimary, foregroundColor: Colors.white),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text('close'.tr),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _CircleBtn({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.darkAccent.withOpacity(0.85) : Colors.black45),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _TypeChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppColors.darkCard.withOpacity(0.8), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.darkPrimary.withOpacity(0.35))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.darkPrimary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      );
}
