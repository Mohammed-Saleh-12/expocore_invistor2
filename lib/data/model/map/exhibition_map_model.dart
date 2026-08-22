import 'package:flutter/material.dart';

class MapSceneVector3 {
  final double x;
  final double y;
  final double z;

  const MapSceneVector3({required this.x, required this.y, required this.z});

  factory MapSceneVector3.fromJson(Map<String, dynamic> json) {
    return MapSceneVector3(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      z: (json['z'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MapSceneFloor {
  final String id;
  final String name;
  final int levelIndex;
  final double elevation;
  final double floorHeight;
  final double width;
  final double height;

  const MapSceneFloor({
    required this.id,
    required this.name,
    required this.levelIndex,
    required this.elevation,
    required this.floorHeight,
    required this.width,
    required this.height,
  });

  factory MapSceneFloor.fromJson(Map<String, dynamic> json) {
    return MapSceneFloor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      levelIndex: json['level_index'] as int? ?? 0,
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      floorHeight: (json['floor_height'] as num?)?.toDouble() ?? 3,
      width: (json['width'] as num?)?.toDouble() ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MapSceneInstance {
  final String id;
  final String type;
  final String assetKey;
  final String? floorId;
  final MapSceneVector3 position;
  final MapSceneVector3 rotation;
  final MapSceneVector3 scale;
  final String? color;
  final String? fill;
  final String? stroke;
  final double? width;
  final double? height;
  final double? depth;
  final String? label;

  const MapSceneInstance({
    required this.id,
    required this.type,
    required this.assetKey,
    this.floorId,
    required this.position,
    required this.rotation,
    required this.scale,
    this.color,
    this.fill,
    this.stroke,
    this.width,
    this.height,
    this.depth,
    this.label,
  });

  factory MapSceneInstance.fromJson(Map<String, dynamic> json) {
    return MapSceneInstance(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'unknown',
      assetKey:
          json['asset_key']?.toString() ?? json['label']?.toString() ?? '',
      floorId: json['floor_id']?.toString(),
      position: MapSceneVector3.fromJson(
        (json['position'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ??
            {},
      ),
      rotation: MapSceneVector3.fromJson(
        (json['rotation'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ??
            {},
      ),
      scale: MapSceneVector3.fromJson(
        (json['scale'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {},
      ),
      color: json['color']?.toString(),
      fill: json['fill']?.toString(),
      stroke: json['stroke']?.toString(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      depth: (json['depth'] as num?)?.toDouble(),
      label: json['label']?.toString(),
    );
  }

  bool get hasValidGlbAsset => assetKey.toLowerCase().endsWith('.glb');
  String get normalizedType => type.toLowerCase();
}

class ExhibitionMapModel {
  final int exhibitionId;
  final String exhibitionName;
  final int gridWidth;
  final int gridDepth;
  final List<MapHallModel> halls;
  final List<MapSceneFloor> floors;
  final Map<String, dynamic> assets;
  final List<MapSceneInstance> sceneInstances;

  ExhibitionMapModel({
    required this.exhibitionId,
    required this.exhibitionName,
    required this.gridWidth,
    required this.gridDepth,
    required this.halls,
    this.floors = const [],
    this.assets = const {},
    this.sceneInstances = const [],
  });

  bool get isGenericScene => sceneInstances.isNotEmpty || assets.isNotEmpty;

  factory ExhibitionMapModel.fromJson(Map<String, dynamic> json) {
    final payload =
        json['data'] is Map &&
            json['scene'] is! Map &&
            json['instances'] is! List &&
            json['halls'] is! List
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final genericScene =
        payload['scene'] is Map || payload['instances'] is List;
    if (genericScene) {
      final sceneMap = payload['scene'] is Map
          ? Map<String, dynamic>.from(payload['scene'] as Map)
          : <String, dynamic>{};
      final assetMap = payload['assets'] is Map
          ? Map<String, dynamic>.from(payload['assets'] as Map)
          : <String, dynamic>{};
      final floorList = (sceneMap['floors'] as List? ?? [])
          .map(
            (f) => MapSceneFloor.fromJson(Map<String, dynamic>.from(f as Map)),
          )
          .toList();
      final instanceList = (payload['instances'] as List? ?? [])
          .map(
            (item) => MapSceneInstance.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      return ExhibitionMapModel(
        exhibitionId:
            int.tryParse(
              (payload['exhibition_id'] ?? payload['exhibitionId'] ?? 0)
                  .toString(),
            ) ??
            0,
        exhibitionName:
            payload['exhibition_name']?.toString() ?? 'Exhibition Map',
        gridWidth: (sceneMap['width'] as num?)?.toInt() ?? 1200,
        gridDepth: (sceneMap['height'] as num?)?.toInt() ?? 800,
        halls: const [],
        floors: floorList,
        assets: assetMap,
        sceneInstances: instanceList,
      );
    }

    return ExhibitionMapModel(
      exhibitionId: payload['exhibition_id'] ?? 0,
      exhibitionName: payload['exhibition_name'] ?? '',
      gridWidth: payload['grid_width'] ?? 12,
      gridDepth: payload['grid_depth'] ?? 10,
      halls: (payload['halls'] as List<dynamic>? ?? [])
          .map((h) => MapHallModel.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MapHallModel {
  final String id;
  final String name;
  final String colorHex;
  final List<MapBoothModel> booths;

  MapHallModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.booths,
  });

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  factory MapHallModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    return MapHallModel(
      id: id,
      name: name,
      colorHex: json['color']?.toString() ?? '7A1FFF',
      booths: (json['booths'] as List<dynamic>? ?? [])
          .map(
            (b) => MapBoothModel.fromJson(
              b as Map<String, dynamic>,
              hallId: id,
              hallName: name,
            ),
          )
          .toList(),
    );
  }
}

class MapBoothModel {
  final int id;
  final String number;
  final int col;
  final int row;
  final int gridWidth;
  final int gridDepth;
  final double height;
  String status;
  final double price;
  final double area;
  final String hallId;
  final String hallName;
  final List<String> amenities;

  MapBoothModel({
    required this.id,
    required this.number,
    required this.col,
    required this.row,
    required this.gridWidth,
    required this.gridDepth,
    required this.height,
    required this.status,
    required this.price,
    required this.area,
    required this.hallId,
    required this.hallName,
    required this.amenities,
  });

  bool get isAvailable => status == 'available';
  bool get isBooked {
    final normalized = status.trim().toLowerCase();
    return normalized == 'booked' ||
        normalized == 'reserved' ||
        normalized == 'occupied';
  }

  factory MapBoothModel.fromJson(
    Map<String, dynamic> json, {
    String hallId = '',
    String hallName = '',
  }) {
    return MapBoothModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      number: json['number']?.toString() ?? '',
      col: json['col'] as int? ?? 0,
      row: json['row'] as int? ?? 0,
      gridWidth: json['width'] as int? ?? 1,
      gridDepth: json['depth'] as int? ?? 1,
      height: (json['height'] as num?)?.toDouble() ?? 1.0,
      status: json['status']?.toString() ?? 'available',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      area: (json['area'] as num?)?.toDouble() ?? 0,
      hallId: hallId,
      hallName: hallName,
      amenities: List<String>.from(json['amenities'] as List? ?? []),
    );
  }
}
