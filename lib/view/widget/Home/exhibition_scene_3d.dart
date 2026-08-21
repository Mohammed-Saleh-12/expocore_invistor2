import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../data/model/map/exhibition_map_model.dart';
import '../../../linkapi.dart';

class Exhibition3DScene extends StatelessWidget {
  static const double _worldScale = 0.01;
  final ExhibitionMapModel mapModel;
  final MapBoothModel? selectedBooth;
  final ValueChanged<MapBoothModel>? onBoothTapped;
  final bool isDark;
  final TransformationController? transformationController;

  const Exhibition3DScene({
    super.key,
    required this.mapModel,
    this.selectedBooth,
    this.onBoothTapped,
    this.isDark = false,
    this.transformationController,
  });

  @override
  Widget build(BuildContext context) {
    return _ThreeSceneWebView(
      mapModel: mapModel,
      selectedBooth: selectedBooth,
      onBoothTapped: onBoothTapped,
      isDark: isDark,
    );

    // Kept below as a native fallback for platforms without WebView support.
    // ignore: dead_code
    if (!mapModel.isGenericScene && mapModel.halls.isEmpty) {
      return const SizedBox.shrink();
    }

    final instances = mapModel.sceneInstances.isNotEmpty
        ? mapModel.sceneInstances
        : _legacyInstances;
    final sceneWidth = mapModel.gridWidth.toDouble().clamp(
      1.0,
      double.infinity,
    );
    final sceneDepth = mapModel.gridDepth.toDouble().clamp(
      1.0,
      double.infinity,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth == 0 ? 1.0 : constraints.maxWidth;
        final height = constraints.maxHeight == 0 ? 1.0 : constraints.maxHeight;

        return InteractiveViewer(
          transformationController: transformationController,
          minScale: 0.35,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(240),
          constrained: false,
          child: SizedBox(
            width: math.max(width, sceneWidth),
            height: math.max(height, sceneDepth),
            child: Stack(
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
                    ((instance.position.x / _worldScale) / sceneWidth) * width,
                    0,
                    width,
                  );
                  final y = _clamp(
                    ((instance.position.z / _worldScale) / sceneDepth) * height,
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
                            child: modelUrl != null && _supportsModelViewer
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
            ),
          ),
        );
      },
    );
  }

  List<MapSceneInstance> get _legacyInstances => [
    for (final hall in mapModel.halls)
      for (final booth in hall.booths)
        MapSceneInstance(
          id: 'booth_${booth.id}',
          type: 'booth',
          assetKey: '',
          position: MapSceneVector3(
            x: booth.col.toDouble(),
            y: booth.height / 2,
            z: booth.row.toDouble(),
          ),
          rotation: const MapSceneVector3(x: 0, y: 0, z: 0),
          scale: const MapSceneVector3(x: 1, y: 1, z: 1),
          color: hall.colorHex,
          width: booth.gridWidth.toDouble(),
          height: booth.height,
          depth: booth.gridDepth.toDouble(),
          label: booth.number,
        ),
  ];

  String? _resolveAssetUrl(MapSceneInstance instance) {
    final raw = mapModel.assets[instance.assetKey];
    if (raw is String && raw.trim().isNotEmpty) {
      final value = raw.trim();
      if (value.toLowerCase().endsWith('.glb') ||
          value.toLowerCase().endsWith('.gltf')) {
        if (value.startsWith('http://') || value.startsWith('https://')) {
          return value;
        }
        final canonicalFile = _canonicalModelFile(value);
        if (canonicalFile != null) return AppLink.mapModel(canonicalFile);
        return _absoluteAssetUrl(value);
      }
    }

    final canonicalFile = _canonicalModelFile(instance.assetKey);
    if (canonicalFile != null) {
      return AppLink.mapModel(canonicalFile);
    }

    if (instance.assetKey.toLowerCase().endsWith('.glb') ||
        instance.assetKey.toLowerCase().endsWith('.gltf')) {
      return _absoluteAssetUrl(instance.assetKey);
    }

    return null;
  }

  MapBoothModel? _coerceBoothFromInstance(MapSceneInstance instance) {
    if (!_isModBooth(instance)) return null;

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

  bool _isModBooth(MapSceneInstance instance) {
    final type = instance.type.trim().toLowerCase();
    if (type != 'booth' && type != 'wing') return false;

    final key = _assetKeyName(instance.assetKey).toLowerCase();
    return RegExp(r'^(?:booth_)?mod[1-5]$').hasMatch(key);
  }

  String? _canonicalModelFile(String assetKey) {
    final key = _assetKeyName(assetKey).toLowerCase();
    final mod = RegExp(r'^(?:booth_)?mod([1-5])$').firstMatch(key);
    if (mod != null) return 'mod${mod.group(1)}.glb';

    final meet = RegExp(r'^meet([1-3])$').firstMatch(key);
    if (meet != null) return 'meet${meet.group(1)}.glb';

    if (key == 'gate') return 'gate.glb';
    return null;
  }

  String _assetKeyName(String value) {
    final withoutQuery = value.split('?').first;
    final fileName = withoutQuery.split('/').last;
    return fileName.toLowerCase().endsWith('.glb') ||
            fileName.toLowerCase().endsWith('.gltf')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
  }

  String _absoluteAssetUrl(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return AppLink.mapModel(value.split('/').last);
  }

  double _itemSize(MapSceneInstance instance, double width, double height) {
    final instanceWidth = (instance.width ?? instance.scale.x) / _worldScale;
    final instanceDepth = (instance.depth ?? instance.scale.z) / _worldScale;
    final base =
        (instanceWidth + instanceDepth) *
        math.min(width / mapModel.gridWidth, height / mapModel.gridDepth);
    final safe = base.clamp(80.0, math.min(width, height) * 0.42);
    return safe;
  }

  double _clamp(double value, double min, double max) => value.clamp(min, max);

  bool get _supportsModelViewer =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

class _ThreeSceneWebView extends StatefulWidget {
  final ExhibitionMapModel mapModel;
  final MapBoothModel? selectedBooth;
  final ValueChanged<MapBoothModel>? onBoothTapped;
  final bool isDark;

  const _ThreeSceneWebView({
    required this.mapModel,
    required this.selectedBooth,
    required this.onBoothTapped,
    required this.isDark,
  });

  @override
  State<_ThreeSceneWebView> createState() => _ThreeSceneWebViewState();
}

class _ThreeSceneWebViewState extends State<_ThreeSceneWebView> {
  late final WebViewController _webController;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        widget.isDark ? const Color(0xFF090B18) : Colors.white,
      )
      ..addJavaScriptChannel('SceneBridge', onMessageReceived: _onSceneMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _ready = true;
            _sendScene();
          },
        ),
      )
      ..loadRequest(Uri.parse(AppLink.mapViewer));
  }

  @override
  void didUpdateWidget(covariant _ThreeSceneWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ready) _sendScene();
  }

  void _sendScene() {
    final payload = jsonEncode(_scenePayload());
    _webController.runJavaScript(
      'window.setExpoScene(${jsonEncode(payload)});',
    );
    final selected = widget.selectedBooth?.id;
    if (selected != null) {
      _webController.runJavaScript(
        'window.setExpoSelected("booth_$selected");',
      );
    }
  }

  Map<String, dynamic> _scenePayload() {
    final instances = widget.mapModel.sceneInstances.isNotEmpty
        ? widget.mapModel.sceneInstances
        : [
            for (final hall in widget.mapModel.halls)
              for (final booth in hall.booths)
                MapSceneInstance(
                  id: 'booth_${booth.id}',
                  type: 'booth',
                  assetKey: 'procedural',
                  position: MapSceneVector3(
                    x: booth.col.toDouble() * 0.01,
                    y: booth.height / 2,
                    z: booth.row.toDouble() * 0.01,
                  ),
                  rotation: const MapSceneVector3(x: 0, y: 0, z: 0),
                  scale: const MapSceneVector3(x: 1, y: 1, z: 1),
                  color: hall.colorHex,
                  width: booth.gridWidth.toDouble() * 0.01,
                  height: booth.height,
                  depth: booth.gridDepth.toDouble() * 0.01,
                  label: booth.number,
                ),
          ];
    return {
      'scene': {
        'width': widget.mapModel.gridWidth,
        'height': widget.mapModel.gridDepth,
        'background_color': widget.isDark ? '#090B18' : '#F4F6FF',
      },
      'assets': {
        for (final entry in widget.mapModel.assets.entries)
          entry.key: _assetUrl(entry.value.toString()),
        for (final item in instances)
          if (!widget.mapModel.assets.containsKey(item.assetKey) &&
              item.assetKey.isNotEmpty)
            item.assetKey: _assetUrl(item.assetKey),
      },
      'instances': [
        for (final item in instances)
          {
            'id': item.id,
            'type': item.type,
            'label': item.label ?? item.id,
            'asset_key': item.assetKey,
            'floor_id': item.floorId,
            'position': {
              'x': item.position.x,
              'y': item.position.y,
              'z': item.position.z,
            },
            'rotation': {
              'x': item.rotation.x,
              'y': item.rotation.y,
              'z': item.rotation.z,
            },
            'scale': {'x': item.scale.x, 'y': item.scale.y, 'z': item.scale.z},
            'width': item.width,
            'height': item.height,
            'depth': item.depth,
            'color': item.color ?? item.fill ?? '#7A1FFF',
          },
      ],
    };
  }

  String _assetUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    var name = trimmed.split('/').last;
    final key = name.toLowerCase().replaceAll('.glb', '');
    final mod = RegExp(r'^(?:booth_)?mod([1-5])$').firstMatch(key);
    if (mod != null) name = 'mod${mod.group(1)}.glb';
    if (RegExp(r'^meet[1-3]$').hasMatch(key)) name = '$key.glb';
    if (key == 'gate') name = 'gate.glb';
    final normalized = name.toLowerCase().endsWith('.glb')
        ? name
        : '${name.isEmpty ? 'mod1' : name}.glb';
    return AppLink.mapModel(normalized);
  }

  void _onSceneMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message);
      if (data is! Map || data['type'] != 'elementTap') return;
      final id = data['id']?.toString() ?? '';
      final numericId = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), ''));
      if (numericId == null || numericId == 0) return;
      MapBoothModel? booth;
      for (final hall in widget.mapModel.halls) {
        for (final item in hall.booths) {
          if (item.id == numericId) booth = item;
        }
      }
      if (booth != null) widget.onBoothTapped?.call(booth);
    } catch (_) {
      // Ignore malformed bridge messages from the WebView.
    }
  }

  @override
  Widget build(BuildContext context) =>
      WebViewWidget(controller: _webController);
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
