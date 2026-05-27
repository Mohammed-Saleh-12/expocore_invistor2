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
    final ctrl   = Get.find<BoothMapController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: const CustomAppBar(title: 'خريطة المعرض 3D'),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.darkPrimary),
                SizedBox(height: 16),
                Text('جارٍ تحميل خريطة المعرض...', style: TextStyle(color: AppColors.grey)),
              ],
            ),
          );
        }

        final mapModel = ctrl.mapData.value;
        if (mapModel == null) {
          return const Center(child: Text('تعذّر تحميل الخريطة'));
        }

        return Column(
          children: [
            _MapHeader(mapModel: mapModel, ctrl: ctrl, isDark: isDark),
            Expanded(child: _MapCanvas(ctrl: ctrl, mapModel: mapModel, isDark: isDark)),
            Obx(() => ctrl.selectedBooth.value != null
                ? _BoothInfoPanel(ctrl: ctrl, isDark: isDark)
                : const SizedBox.shrink()),
          ],
        );
      }),
    );
  }
}

class _MapHeader extends StatelessWidget {
  final dynamic mapModel;
  final BoothMapController ctrl;
  final bool isDark;

  const _MapHeader({required this.mapModel, required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
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
                icon: Icon(Icons.center_focus_strong_rounded,
                    color: AppColors.darkPrimary, size: 22),
                tooltip: 'إعادة ضبط العرض',
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(AppColors.info,        'متاح',  isDark),
        _legendItem(AppColors.grey.withOpacity(0.5), 'محجوز', isDark),
        _legendItem(AppColors.darkPrimary,  'مختار', isDark),
        _legendItem(const Color(0xFF4CAF50), 'مدخل', isDark),
      ],
    );
  }

  Widget _legendItem(Color c, String label, bool isDark) => Row(
    children: [
      Container(
        width: 12, height: 12,
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.grey)),
    ],
  );
}

class _MapCanvas extends StatefulWidget {
  final BoothMapController ctrl;
  final ExhibitionMapModel mapModel;
  final bool isDark;

  const _MapCanvas({required this.ctrl, required this.mapModel, required this.isDark});

  @override
  State<_MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<_MapCanvas> {
  final List<BoothHitArea> _hitAreas = [];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: InteractiveViewer(
        transformationController: widget.ctrl.transformationController,
        minScale: 0.45,
        maxScale: 3.5,
        boundaryMargin: const EdgeInsets.all(200),
        child: Center(
          child: GestureDetector(
            onTapUp: (details) => _handleTap(details.localPosition),
            child: Obx(() => CustomPaint(
              size: const Size(900, 700),
              painter: IsometricMapPainter(
                mapModel:      widget.mapModel,
                selectedBooth: widget.ctrl.selectedBooth.value,
                hitAreas:      _hitAreas,
                isDark:        widget.isDark,
              ),
            )),
          ),
        ),
      ),
    );
  }

  void _handleTap(Offset tapInWidget) {
    final matrix = widget.ctrl.transformationController.value;
    final inverted = Matrix4.inverted(matrix);
    final tapInCanvas = MatrixUtils.transformPoint(inverted, tapInWidget);

    for (final area in _hitAreas.reversed) {
      if (area.topFacePath.contains(tapInCanvas)) {
        widget.ctrl.onBoothTapped(area.booth);
        return;
      }
    }
    widget.ctrl.clearSelection();
  }
}

class _BoothInfoPanel extends StatelessWidget {
  final BoothMapController ctrl;
  final bool isDark;

  const _BoothInfoPanel({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final booth = ctrl.selectedBooth.value!;
    final hall  = ctrl.hallForBooth(booth);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
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
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: hall?.color.withOpacity(0.15) ?? AppColors.darkPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.store_mall_directory_rounded,
                      color: hall?.color ?? AppColors.darkPrimary, size: 22),
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
                        fontSize: 17, fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      booth.hallName,
                      style: TextStyle(fontSize: 12, color: hall?.color ?? AppColors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${booth.price.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ريال',
                    style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const Text('للمعرض كاملاً', style: TextStyle(color: AppColors.grey, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoChip(icon: Icons.straighten_rounded,  label: '${booth.area.toInt()} م²', isDark: isDark),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.height_rounded,       label: 'ارتفاع ${booth.height}م',  isDark: isDark),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.grid_3x3_rounded,     label: '${booth.gridWidth}×${booth.gridDepth}', isDark: isDark),
            ],
          ),
          if (booth.amenities.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: booth.amenities.map((a) => _AmenityChip(label: a, isDark: isDark)).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: ctrl.clearSelection,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('إلغاء'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.grey,
                    side: const BorderSide(color: AppColors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomButton(
                  label: 'احجز هذا الجناح',
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoChip({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _AmenityChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.darkPrimary.withOpacity(0.25)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkPrimary)),
    );
  }
}
