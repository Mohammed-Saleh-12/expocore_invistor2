import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/booth_map_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/booth/booth_model.dart';
import '../../../data/model/map/exhibition_map_model.dart';
import '../../../view/widget/Home/isometric_map_painter.dart';
import '../../controllers/web_nav_controller.dart';
import '../../models/web_theme.dart';

class WebMapPage extends StatelessWidget {
  const WebMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BoothMapController>();

    return Obx(() {
      if (ctrl.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: WebTheme.primary),
              const SizedBox(height: 16),
              Text('map_loading'.tr, style: const TextStyle(color: AppColors.grey, fontSize: 15)),
            ],
          ),
        );
      }

      final mapModel = ctrl.mapData.value;
      if (mapModel == null) {
        return Center(child: Text('map_load_error'.tr, style: const TextStyle(color: AppColors.grey)));
      }

      return Column(
        children: [
          _WebMapHeader(mapModel: mapModel, ctrl: ctrl),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final containerSize = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  children: [
                    _WebMapCanvas(ctrl: ctrl, mapModel: mapModel),
                    Obx(() {
                      final booth = ctrl.selectedBooth.value;
                      final pos = ctrl.selectedBoothPosition.value;
                      if (booth == null || !booth.isBooked || pos == null) return const SizedBox.shrink();
                      return _WebBoothCompanyDialog(
                        key: ValueKey('dialog_${booth.id}'),
                        ctrl: ctrl,
                        tapPosition: pos,
                        containerSize: containerSize,
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          Obx(() {
            final booth = ctrl.selectedBooth.value;
            if (booth == null || booth.isBooked) return const SizedBox.shrink();
            return _WebBoothInfoPanel(ctrl: ctrl);
          }),
        ],
      );
    });
  }
}

// ─────────────────────────────────── Header ──────────────────────────────────

class _WebMapHeader extends StatelessWidget {
  final ExhibitionMapModel mapModel;
  final BoothMapController ctrl;
  const _WebMapHeader({required this.mapModel, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: WebTheme.surface, border: Border(bottom: BorderSide(color: WebTheme.border))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.map_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mapModel.exhibitionName, style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w800)),
                    Text('map_interaction_hint'.tr, style: TextStyle(color: AppColors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Tooltip(
                message: 'map_reset_view'.tr,
                child: InkWell(
                  onTap: ctrl.resetView,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: WebTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: WebTheme.primary.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.center_focus_strong_rounded, color: WebTheme.primary, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _WebLegendRow(),
        ],
      ),
    );
  }
}

class _WebLegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _item(AppColors.info, 'متاح'),
        const SizedBox(width: 20),
        _item(const Color(0xFF3A3650), 'محجوز'),
        const SizedBox(width: 20),
        _item(WebTheme.primary, 'مختار'),
        const SizedBox(width: 20),
        _item(const Color(0xFF4CAF50), 'مدخل'),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: WebTheme.border, borderRadius: BorderRadius.circular(6)),
          child: Text('map_controls_hint'.tr, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _item(Color c, String label) => Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        ],
      );
}

// ─────────────────────────────────── Canvas ──────────────────────────────────

class _WebMapCanvas extends StatelessWidget {
  final BoothMapController ctrl;
  final ExhibitionMapModel mapModel;
  const _WebMapCanvas({required this.ctrl, required this.mapModel});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: InteractiveViewer(
        transformationController: ctrl.transformationController,
        minScale: 0.35,
        maxScale: 4.0,
        boundaryMargin: const EdgeInsets.all(300),
        child: Center(
          child: GestureDetector(
            onTapUp: (details) => _handleTap(details.localPosition),
            child: Obx(() => CustomPaint(
                  size: const Size(1000, 760),
                  painter: IsometricMapPainter(
                    mapModel: mapModel,
                    selectedBooth: ctrl.selectedBooth.value,
                    hitAreas: ctrl.hitAreas,
                    isDark: true,
                  ),
                )),
          ),
        ),
      ),
    );
  }

  void _handleTap(Offset tapInWidget) {
    final matrix = ctrl.transformationController.value;
    final inverted = Matrix4.inverted(matrix);
    final tapInCanvas = MatrixUtils.transformPoint(inverted, tapInWidget);
    for (final area in ctrl.hitAreas.reversed) {
      if (area.topFacePath.contains(tapInCanvas)) {
        ctrl.onBoothTapped(area.booth, screenPosition: tapInWidget);
        return;
      }
    }
    ctrl.clearSelection();
  }
}

// ───────────────────── Company Info Dialog (booked booth) ────────────────────

class _WebBoothCompanyDialog extends StatelessWidget {
  final BoothMapController ctrl;
  final Offset tapPosition;
  final Size containerSize;

  static const _w = 280.0;
  static const _h = 210.0;

  const _WebBoothCompanyDialog({super.key, required this.ctrl, required this.tapPosition, required this.containerSize});

  @override
  Widget build(BuildContext context) {
    final booth = ctrl.selectedBooth.value;
    if (booth == null) return const SizedBox.shrink();
    final company = ctrl.companyForBooth(booth);
    final accentColor = company?.color ?? WebTheme.primary;

    double left = tapPosition.dx - _w / 2;
    double top = tapPosition.dy - _h - 18;
    if (top < 8) top = tapPosition.dy + 18;
    left = left.clamp(8.0, (containerSize.width - _w - 8).clamp(8.0, double.infinity));
    top = top.clamp(8.0, (containerSize.height - _h - 8).clamp(8.0, double.infinity));

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutExpo,
      builder: (_, scale, child) => Positioned(
        left: left, top: top,
        child: Transform.scale(scale: scale, alignment: Alignment.bottomCenter, child: child),
      ),
      child: _CompanyCard(booth: booth, company: company, accentColor: accentColor, onClose: ctrl.clearSelection),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final MapBoothModel booth;
  final BoothCompanyInfo? company;
  final Color accentColor;
  final VoidCallback onClose;

  const _CompanyCard({required this.booth, required this.company, required this.accentColor, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final name = company?.name ?? 'شركة محجوزة';
    final email = company?.email ?? '—';
    final initials = company?.initials ?? 'ش';

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1730),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.45), width: 1.6),
        boxShadow: [
          BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
          BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 48, spreadRadius: 6),
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [accentColor.withOpacity(0.18), accentColor.withOpacity(0.04)], begin: Alignment.topRight, end: Alignment.bottomLeft),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.65)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 11, color: accentColor),
                          const SizedBox(width: 4),
                          Flexible(child: Text(email, style: const TextStyle(fontSize: 11, color: Colors.white60), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(onTap: onClose, child: const Icon(Icons.close_rounded, size: 18, color: Colors.white38)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                _chip(Icons.store_mall_directory_rounded, 'الجناح ${booth.number}', accentColor),
                const SizedBox(width: 8),
                _chip(Icons.meeting_room_rounded, booth.hallName, accentColor),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withOpacity(0.28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_rounded, size: 13, color: accentColor),
                const SizedBox(width: 5),
                Text('map_booth_booked_by'.tr, style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: accent.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: accent),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Available Booth Info Panel (bottom) ─────────────────────

class _WebBoothInfoPanel extends StatelessWidget {
  final BoothMapController ctrl;
  const _WebBoothInfoPanel({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final booth = ctrl.selectedBooth.value!;
    final hall = ctrl.hallForBooth(booth);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: WebTheme.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: (hall?.color ?? WebTheme.primary).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.store_mall_directory_rounded, color: hall?.color ?? WebTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('الجناح ${booth.number}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: WebTheme.text)),
                Text(booth.hallName, style: TextStyle(fontSize: 12, color: hall?.color ?? AppColors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _chip(Icons.straighten_rounded, '${booth.area.toInt()} م²'),
                    const SizedBox(width: 10),
                    _chip(Icons.height_rounded, 'ارتفاع ${booth.height}م'),
                    const SizedBox(width: 10),
                    _chip(Icons.power_outlined, booth.amenities.contains('كهرباء') ? 'كهرباء ✓' : 'بدون كهرباء'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${booth.price.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ريال',
                style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Text('full_exhibition_duration'.tr, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  final boothModel = BoothModel(
                    id: booth.id, number: booth.number, exhibitionName: booth.hallName,
                    imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
                    area: booth.area, status: 'pending', price: booth.price, endDate: '2026-07-20',
                    location: '${booth.hallName} - صف ${booth.row + 1}', amenities: booth.amenities, isFavorite: false,
                  );
                  WebNavController.to.openBookingRequest(boothModel);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(10)),
                  child: Text('booth_book_btn'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: WebTheme.border, borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
          ],
        ),
      );
}
