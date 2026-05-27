import 'package:flutter/material.dart';

class ExhibitionMapModel {
  final int exhibitionId;
  final String exhibitionName;
  final int gridWidth;
  final int gridDepth;
  final List<MapHallModel> halls;

  ExhibitionMapModel({
    required this.exhibitionId,
    required this.exhibitionName,
    required this.gridWidth,
    required this.gridDepth,
    required this.halls,
  });

  factory ExhibitionMapModel.fromJson(Map<String, dynamic> json) {
    return ExhibitionMapModel(
      exhibitionId: json['exhibition_id'] ?? 0,
      exhibitionName: json['exhibition_name'] ?? '',
      gridWidth: json['grid_width'] ?? 12,
      gridDepth: json['grid_depth'] ?? 10,
      halls: (json['halls'] as List<dynamic>? ?? [])
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
    final id = json['id'] as String? ?? '';
    final name = json['name'] as String? ?? '';
    return MapHallModel(
      id: id,
      name: name,
      colorHex: json['color'] as String? ?? '7A1FFF',
      booths: (json['booths'] as List<dynamic>? ?? [])
          .map((b) => MapBoothModel.fromJson(
                b as Map<String, dynamic>,
                hallId: id,
                hallName: name,
              ))
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
  bool get isBooked => status == 'booked';

  factory MapBoothModel.fromJson(
    Map<String, dynamic> json, {
    String hallId = '',
    String hallName = '',
  }) {
    return MapBoothModel(
      id: json['id'] as int? ?? 0,
      number: json['number'] as String? ?? '',
      col: json['col'] as int? ?? 0,
      row: json['row'] as int? ?? 0,
      gridWidth: json['width'] as int? ?? 1,
      gridDepth: json['depth'] as int? ?? 1,
      height: (json['height'] as num?)?.toDouble() ?? 1.0,
      status: json['status'] as String? ?? 'available',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      area: (json['area'] as num?)?.toDouble() ?? 0,
      hallId: hallId,
      hallName: hallName,
      amenities: List<String>.from(json['amenities'] as List? ?? []),
    );
  }
}
