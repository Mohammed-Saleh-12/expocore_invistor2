import 'package:flutter_test/flutter_test.dart';

import 'package:expocore_invistor2/data/model/booth/booth_model.dart';
import 'package:expocore_invistor2/data/model/map/exhibition_map_model.dart';

void main() {
  test('parses exported map JSON generically and keeps exact stable IDs', () {
    final json = {
      'map_id': 101,
      'scene': {
        'width': 1200,
        'height': 800,
        'background_color': '#0b1020',
        'floors': [
          {
            'id': 'f1',
            'name': 'Floor 1',
            'level_index': 0,
            'elevation': 0,
            'floor_height': 3,
            'width': 1200,
            'height': 800,
          },
        ],
      },
      'assets': {
        'booth_mod1': 'https://cdn.example.com/models/mod1.glb',
        'hall_section': 'procedural',
      },
      'instances': [
        {
          'id': 'wing_1001',
          'type': 'booth',
          'label': 'booth_mod1',
          'floor_id': 'f1',
          'asset_key': 'booth_mod1',
          'position': {'x': 10.5, 'y': 0.0, 'z': -4.2},
          'rotation': {'x': 0.0, 'y': 1.5708, 'z': 0.0},
          'scale': {'x': 1.0, 'y': 1.0, 'z': 1.0},
          'color': '#22d3ee',
          'width': 1.0,
          'height': 1.0,
          'depth': 1.0,
        },
        {
          'id': 'section_01',
          'type': 'section',
          'label': 'hall_section',
          'floor_id': 'f1',
          'asset_key': 'hall_section',
          'position': {'x': 0, 'y': 0, 'z': 0},
          'rotation': {'x': 0, 'y': 0, 'z': 0},
          'scale': {'x': 1, 'y': 1, 'z': 1},
          'color': '#7c3aed',
          'fill': '#7c3aed',
          'stroke': '#8b5cf6',
          'width': 18,
          'height': 3,
          'depth': 12,
        },
      ],
    };

    final model = ExhibitionMapModel.fromJson(json);

    expect(model.exhibitionId, 101);
    expect(model.sceneInstances.length, 2);
    expect(model.sceneInstances.first.id, 'wing_1001');
    expect(
      model.assets['booth_mod1'],
      'https://cdn.example.com/models/mod1.glb',
    );
    expect(model.sceneInstances.first.assetKey, 'booth_mod1');
    expect(model.sceneInstances.last.type, 'section');
    expect(model.floors.first.id, 'f1');
  });

  test('links booth details by exact id instead of array position', () {
    final booths = [
      BoothModel(
        id: 1001,
        number: 'A1',
        exhibitionName: 'Demo',
        imageUrl: '',
        area: 12,
        status: 'available',
        price: 2000,
        endDate: '',
        location: 'Hall A',
        amenities: ['wifi'],
      ),
    ];

    final boothById = {for (final booth in booths) booth.id: booth};
    final mapInstanceId = 'wing_1001';
    final parsedId =
        int.tryParse(mapInstanceId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    expect(parsedId, 1001);
    expect(boothById[parsedId]?.number, 'A1');
    expect(boothById[parsedId]?.status, 'available');
  });
}
