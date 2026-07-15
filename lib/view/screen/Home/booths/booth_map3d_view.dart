import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/booth_map_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../data/model/map/exhibition_map_model.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';
import '../../../widget/Home/isometric_map_painter.dart';

class BoothMap3dView extends StatelessWidget {
  const BoothMap3dView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BoothMapController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: CustomAppBar(title: 'map_3d_title'.tr),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.darkPrimary),
                const SizedBox(height: 16),
                Text(
                  'map_loading'.tr,
                  style: const TextStyle(color: AppColors.grey),
                ),
              ],
            ),
          );
        }

        final mapModel = ctrl.mapData.value;
        if (mapModel == null) return Center(child: Text('map_load_error'.tr));

        return Column(
          children: [
            _MapHeader(mapModel: mapModel, ctrl: ctrl, isDark: isDark),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final containerSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return Stack(
                    children: [
                      _MapCanvas(
                        ctrl: ctrl,
                        mapModel: mapModel,
                        isDark: isDark,
                      ),
                      Obx(() {
                        final booth = ctrl.selectedBooth.value;
                        final pos = ctrl.selectedBoothPosition.value;
                        if (booth == null || !booth.isBooked || pos == null)
                          return const SizedBox.shrink();
                        return _BoothCompanyDialog(
                          key: ValueKey('dialog_${booth.id}'),
                          ctrl: ctrl,
                          isDark: isDark,
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
              if (booth == null || booth.isBooked)
                return const SizedBox.shrink();
              return _BoothInfoPanel(ctrl: ctrl, isDark: isDark);
            }),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────── Header ──────────────────────────────

class _MapHeader extends StatelessWidget {
  final dynamic mapModel;
  final BoothMapController ctrl;
  final bool isDark;
  const _MapHeader({
    required this.mapModel,
    required this.ctrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mapModel.exhibitionName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.lightPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: ctrl.resetView,
                icon: const Icon(
                  Icons.center_focus_strong_rounded,
                  color: AppColors.darkPrimary,
                  size: 22,
                ),
                tooltip: 'map_reset_view'.tr,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LegendRow(isDark: isDark),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final bool isDark;
  const _LegendRow({required this.isDark});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _item(AppColors.info, 'map_legend_available'.tr, isDark),
      _item(const Color(0xFF3A3650), 'map_legend_booked'.tr, isDark),
      _item(AppColors.darkPrimary, 'map_legend_selected'.tr, isDark),
      _item(const Color(0xFF4CAF50), 'map_legend_entrance'.tr, isDark),
    ],
  );

  Widget _item(Color c, String label, bool isDark) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: isDark ? Colors.white70 : AppColors.grey,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────── Canvas ──────────────────────────────

class _MapCanvas extends StatelessWidget {
  final BoothMapController ctrl;
  final ExhibitionMapModel mapModel;
  final bool isDark;
  const _MapCanvas({
    required this.ctrl,
    required this.mapModel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: InteractiveViewer(
        transformationController: ctrl.transformationController,
        minScale: 0.45,
        maxScale: 3.5,
        boundaryMargin: const EdgeInsets.all(200),
        child: Center(
          child: GestureDetector(
            onTapUp: (details) => _handleTap(details.localPosition),
            child: Obx(
              () => CustomPaint(
                size: const Size(900, 700),
                painter: IsometricMapPainter(
                  mapModel: mapModel,
                  selectedBooth: ctrl.selectedBooth.value,
                  hitAreas: ctrl.hitAreas,
                  isDark: isDark,
                ),
              ),
            ),
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

// ───────────────────────── Company Info Dialog (overlay) ─────────────────────

class _BoothCompanyDialog extends StatelessWidget {
  final BoothMapController ctrl;
  final bool isDark;
  final Offset tapPosition;
  final Size containerSize;

  static const _w = 272.0;
  static const _h = 210.0;

  const _BoothCompanyDialog({
    super.key,
    required this.ctrl,
    required this.isDark,
    required this.tapPosition,
    required this.containerSize,
  });

  @override
  Widget build(BuildContext context) {
    final booth = ctrl.selectedBooth.value;
    if (booth == null) return const SizedBox.shrink();

    final company = ctrl.companyForBooth(booth);
    final accentColor = company?.color ?? AppColors.darkPrimary;

    double left = tapPosition.dx - _w / 2;
    double top = tapPosition.dy - _h - 18;
    if (top < 8) top = tapPosition.dy + 18;
    left = left.clamp(
      8.0,
      (containerSize.width - _w - 8).clamp(8.0, double.infinity),
    );
    top = top.clamp(
      8.0,
      (containerSize.height - _h - 8).clamp(8.0, double.infinity),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutExpo,
      builder: (_, scale, child) => Positioned(
        left: left,
        top: top,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
      child: _DialogCard(
        booth: booth,
        company: company,
        accentColor: accentColor,
        isDark: isDark,
        onClose: ctrl.clearSelection,
      ),
    );
  }
}

class _DialogCard extends StatelessWidget {
  final MapBoothModel booth;
  final BoothCompanyInfo? company;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onClose;

  const _DialogCard({
    required this.booth,
    required this.company,
    required this.accentColor,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final name = company?.name ?? 'شركة محجوزة';
    final email = company?.email ?? '—';
    final initials = company?.initials ?? 'ش';

    return Container(
      width: 272,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1730) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withOpacity(0.45), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.55),
            blurRadius: 22,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: accentColor.withOpacity(0.22),
            blurRadius: 50,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(name, email, initials, accentColor, isDark),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                _chip(
                  Icons.store_mall_directory_rounded,
                  'الجناح ${booth.number}',
                  accentColor,
                ),
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
                Text(
                  'map_booth_booked_by'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    String name,
    String email,
    String initials,
    Color accent,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.18), accent.withOpacity(0.04)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withOpacity(0.65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 11, color: accent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        email,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : AppColors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: accent),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── Available Booth Booking Panel ───────────────────────

class _BoothInfoPanel extends StatelessWidget {
  final BoothMapController ctrl;
  final bool isDark;
  const _BoothInfoPanel({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final booth = ctrl.selectedBooth.value!;
    final hall = ctrl.hallForBooth(booth);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (hall?.color ?? AppColors.darkPrimary).withOpacity(
                    0.15,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.store_mall_directory_rounded,
                    color: hall?.color ?? AppColors.darkPrimary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الجناح ${booth.number}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      booth.hallName,
                      style: TextStyle(
                        fontSize: 12,
                        color: hall?.color ?? AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${booth.price.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ريال',
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'full_exhibition_duration'.tr,
                    style: const TextStyle(color: AppColors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Chip(
                icon: Icons.straighten_rounded,
                label: '${booth.area.toInt()} م²',
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.height_rounded,
                label: 'ارتفاع ${booth.height}م',
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.grid_3x3_rounded,
                label: '${booth.gridWidth}×${booth.gridDepth}',
                isDark: isDark,
              ),
            ],
          ),
          if (booth.amenities.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: booth.amenities
                  .map((a) => _AmenityTag(label: a, isDark: isDark))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: ctrl.clearSelection,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: Text('btn_cancel'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.grey,
                    side: const BorderSide(color: AppColors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomButton(
                  label: 'booth_book_btn'.tr,
                  onTap: ctrl.proceedToBooking,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _Chip({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.darkPrimary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    ),
  );
}

class _AmenityTag extends StatelessWidget {
  final String label;
  final bool isDark;
  const _AmenityTag({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.darkPrimary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.darkPrimary.withOpacity(0.25)),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 10, color: AppColors.darkPrimary),
    ),
  );
}
