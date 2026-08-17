import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../data/model/map/exhibition_map_model.dart';

class Exhibition3DScene extends StatelessWidget {
  final ExhibitionMapModel mapModel;
  final MapBoothModel? selectedBooth;
  final ValueChanged<MapBoothModel>? onBoothTapped;
  final bool isDark;

  const Exhibition3DScene({
    super.key,
    required this.mapModel,
    this.selectedBooth,
    this.onBoothTapped,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!mapModel.isGenericScene || mapModel.sceneInstances.isEmpty) {
      return const SizedBox.shrink();
    }

    final instances = mapModel.sceneInstances;
    final maxX = _maxAbs(instances.map((e) => e.position.x).toList());
    final maxZ = _maxAbs(instances.map((e) => e.position.z).toList());

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth == 0 ? 1.0 : constraints.maxWidth;
        final height = constraints.maxHeight == 0 ? 1.0 : constraints.maxHeight;

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark
                          ? const Color(0xFF090B18)
                          : const Color(0xFFF4F6FF)),
                      (isDark
                          ? const Color(0xFF1A1730)
                          : const Color(0xFFE9EEF9)),
                    ],
                  ),
                ),
              ),
            ),
            ...instances.asMap().entries.map((entry) {
              final index = entry.key;
              final instance = entry.value;
              final modelUrl = _resolveAssetUrl(instance);
              final x = _clamp(
                (instance.position.x / (maxX == 0 ? 1 : maxX)) * width,
                0,
                width,
              );
              final y = _clamp(
                (instance.position.z / (maxZ == 0 ? 1 : maxZ)) * height +
                    (height * 0.18),
                0,
                height,
              );
              final size = _itemSize(instance, width, height);
              final isSelected =
                  selectedBooth != null &&
                  selectedBooth!.id.toString() == instance.id;

              return Positioned(
                left: x,
                top: y,
                child: Transform.translate(
                  offset: Offset(-(size / 2), -(size / 2)),
                  child: GestureDetector(
                    onTap: () {
                      final realBooth = _coerceBoothFromInstance(instance);
                      if (realBooth != null && onBoothTapped != null) {
                        onBoothTapped!(realBooth);
                      }
                    },
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(instance.rotation.y * 0.2)
                        ..rotateX(instance.rotation.x * 0.2),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: modelUrl != null
                            ? _ModelViewerCard(
                                key: ValueKey('scene_model_$index'),
                                src: modelUrl,
                                isSelected: isSelected,
                                label: instance.label ?? instance.id,
                              )
                            : _ProceduralBox(
                                instance: instance,
                                isSelected: isSelected,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  String? _resolveAssetUrl(MapSceneInstance instance) {
    final raw = mapModel.assets[instance.assetKey];
    if (raw is String && raw.trim().isNotEmpty) {
      final value = raw.trim();
      if (value.toLowerCase().endsWith('.glb') ||
          value.toLowerCase().endsWith('.gltf')) {
        return value;
      }
    }

    if (instance.assetKey.toLowerCase().endsWith('.glb') ||
        instance.assetKey.toLowerCase().endsWith('.gltf')) {
      return instance.assetKey;
    }

    return null;
  }

  MapBoothModel? _coerceBoothFromInstance(MapSceneInstance instance) {
    final id = int.tryParse(instance.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (id == 0) return null;
    return MapBoothModel(
      id: id,
      number: instance.label ?? instance.id,
      col: 0,
      row: 0,
      gridWidth: 1,
      gridDepth: 1,
      height: instance.height ?? 1,
      status: 'available',
      price: 0,
      area: 0,
      hallId: instance.floorId ?? 'floor',
      hallName: instance.label ?? 'Scene Item',
      amenities: const [],
    );
  }

  double _itemSize(MapSceneInstance instance, double width, double height) {
    final base = ((instance.width ?? 1.0) + (instance.depth ?? 1.0)) * 32;
    final safe = base.clamp(80.0, math.min(width, height) * 0.42);
    return safe;
  }

  double _maxAbs(List<double> values) {
    if (values.isEmpty) return 0;
    final max = values.reduce((a, b) => a.abs() > b.abs() ? a : b).abs();
    return max == 0 ? 1 : max;
  }

  double _clamp(double value, double min, double max) => value.clamp(min, max);
}

class _ModelViewerCard extends StatelessWidget {
  final String src;
  final bool isSelected;
  final String label;

  const _ModelViewerCard({
    super.key,
    required this.src,
    required this.isSelected,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFFFD700)
              : Colors.white.withOpacity(0.4),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isSelected ? const Color(0xFFFFD700) : const Color(0xFF7A1FFF))
                    .withOpacity(0.25),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: ModelViewer(
                src: src,
                alt: label,
                ar: false,
                arModes: const ['webxr', 'scene-viewer'],
                autoRotate: true,
                autoRotateDelay: 2000,
                cameraControls: true,
                disableZoom: false,
                shadowIntensity: 0.9,
                backgroundColor: Colors.transparent,
                interactionPrompt: InteractionPrompt.whenFocused,
                disableTap: false,
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.42),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProceduralBox extends StatelessWidget {
  final MapSceneInstance instance;
  final bool isSelected;

  const _ProceduralBox({required this.instance, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color = _parseHexColor(instance.color ?? instance.fill ?? '#7A1FFF');
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFFFD700)
              : Colors.white.withOpacity(0.6),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          instance.label ?? instance.id,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Color _parseHexColor(String value) {
    var hex = value.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFF7A1FFF);
  }
}
