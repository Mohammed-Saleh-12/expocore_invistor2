# Flutter Map Rendering Agent Instructions

render the exhibition map from the exported JSON produced by the web map builder.

Your job is to build the map viewer so it reads the JSON generically, renders every placed object, and links each map object to its detailed booth/wing record by stable ID from a separate API response.

Important: do not assume the map only contains booths. The JSON contains all scene elements, including sections, gates, hall structures, wing models, meeting rooms, and generic decorations.

## JSON contract you must support

The JSON root shape is:

```json
{
  "map_id": 101,
  "scene": {
    "width": 1200,
    "height": 800,
    "background_color": "#0b1020",
    "theme": "modern",
    "unit": "meters",
    "meters_per_unit": 1,
    "floors": [
      {
        "id": "f1",
        "name": "Floor 1",
        "level_index": 0,
        "elevation": 0,
        "floor_height": 3,
        "width": 1200,
        "height": 800
      }
    ]
  },
  "assets": {
    "booth_mod1": "https://cdn.example.com/models/mod1.glb",
    "meet1": "https://cdn.example.com/models/meet1.glb",
    "gate": "https://cdn.example.com/models/gate.glb",
    "wall_section": "procedural",
    "hall_section": "procedural"
  },
  "instances": [
    {
      "id": "wing_1001",
      "type": "booth",
      "label": "booth_mod1",
      "floor_id": "f1",
      "asset_key": "booth_mod1",
      "position": { "x": 10.5, "y": 0.0, "z": -4.2 },
      "rotation": { "x": 0.0, "y": 1.5708, "z": 0.0 },
      "scale": { "x": 1.0, "y": 1.0, "z": 1.0 },
      "color": "#22d3ee",
      "fill": "#22d3ee",
      "stroke": "#67e8f9",
      "width": 1.0,
      "height": 1.0,
      "depth": 1.0
    },
    {
      "id": "section_01",
      "type": "section",
      "label": "hall_section",
      "floor_id": "f1",
      "asset_key": "hall_section",
      "position": { "x": 0, "y": 0, "z": 0 },
      "rotation": { "x": 0, "y": 0, "z": 0 },
      "scale": { "x": 1, "y": 1, "z": 1 },
      "color": "#7c3aed",
      "fill": "#7c3aed",
      "stroke": "#8b5cf6",
      "width": 18,
      "height": 3,
      "depth": 12
    }
  ]
}
```

## Required behavior

### 1) Parse the map generically
- Read `map_id` from the root.
- Read `scene` and use width, height, background color, floors, and units.
- Read `assets` as the asset registry.
- Read `instances` as the list of all placed objects.

Do not assume that only `type == "booth"` exists.

### 2) Render every instance
For each item in `instances`:
- use `asset_key` to resolve the model path from `assets`
- use `position`, `rotation`, and `scale`
- use `width`, `height`, `depth` if needed for procedural fallback
- use `color`, `fill`, `stroke` for procedural meshes or UI styling
- use `floor_id` to group objects by floor

### 3) Render GLB assets when available
If `assets[instance.asset_key]` is a valid `.glb` URL or asset path:
- load it in Flutter using a 3D model loader
- place it using the `position`, `rotation`, `scale`

Example logic:

```dart
final modelPath = map.assets[instance.asset_key];
if (modelPath != null && modelPath.endsWith('.glb')) {
  // Load GLB model and place using transform
}
```

### 4) Procedural fallback for non-GLB items
Some elements like `section`, `wall_section`, `hall_section`, or `map_frame` may not have a GLB.

In that case, render them using geometry instead of trying to fetch a nonexistent model.

Use procedural geometry for these cases:
- walls / dividers / frames / borders
- floor plate / outer boundary / base shape
- section areas
- structure blocks
- glow frame / neon rails

Use values from:
- width
- height
- depth
- color / stroke / fill
- position / rotation / scale

Examples:
- section / hall section => box or framed box
- gate frame => rectangular or custom frame geometry
- wall section => thin box or panel strip

### 5) Match map instance IDs to API wing/booth details
This is mandatory.

The exported scene JSON does not include `metadata`. The stable ID in the map JSON is the link key.

Example:
- map JSON instance: `"id": "wing_1001"`
- separate API response may contain: `{ "id": "wing_1001", "name": "Wing A", "price": 2000, ... }`

You must match by exact `id`, never by array index.

Correct behavior:

```dart
final wingById = {for (final wing in wings) wing.id: wing};

for (final instance in map.instances) {
  final info = wingById[instance.id];
  if (info != null) {
    // attach metadata to the model
  }
}
```

Do not do this:
- `wings[i]` matches `instances[i]`
- matching by model type only
- matching by name only
- matching by position order

### 6) Maintain a neutral renderer
The app should not hardcode booth-only logic.

Render everything using a generic model class like this:

```dart
class MapSceneInstance {
  final String id;
  final String type;
  final String assetKey;
  final String? floorId;
  final Vector3 position;
  final Vector3 rotation;
  final Vector3 scale;
  final String? color;
  final double? width;
  final double? height;
  final double? depth;
}
```

Then render based on `instance.type` and `instance.assetKey` without assuming it is a booth.

## Required integration flow

1. Fetch `map JSON` from backend / local source.
2. Parse `map_id`, `scene`, `assets`, and `instances`.
3. Build a map of `assets`.
4. Fetch separate wing/booth detail API.
5. Create index by `id` exactly.
6. For each JSON instance:
   - resolve model/path
   - resolve details by `instance.id`
   - create a renderable object
   - apply transforms
7. Render to 3D scene.
8. Use `scene.background_color` for scene background.
9. Use `scene.floors` to create floor layers if needed.

## Required data linkage rules

- `instance.id` is the primary identity key for linking with booth/wing details.
- `instance.asset_key` is for loading the visual model.
- `instance.type` is for semantic type, but not for matching detail records.
- The exported scene JSON does not include `metadata`; detail records must be fetched separately by `id`.

## Must not do
- Do not build a booth-only UI.
- Do not ignore `section` or `structure` items.
- Do not ignore `scale`, `rotation`, or `color`.
- Do not assume `assets` contains only GLB files.
- Do not match IDs by array position.
- Do not skip `scene.floors`.
- Do not ignore `map_id`.

## Rendering strategy for matching the original map

To match the original web map as closely as possible:
- use the exact `position` values from JSON
- use the exact `rotation` values from JSON
- use the exact `scale` values from JSON
- use the exact `width`, `height`, `depth` values where geometry is procedural
- use the exact `color`, `fill`, and `stroke` values
- keep `floor_id` in the render grouping so the same level is respected
- construct section and frame geometry to match visual structure even when no GLB exists

## Example mapping logic

```dart
Future<void> loadMap() async {
  final mapJson = await fetchMapJson();
  final map = MapScene.fromJson(mapJson);

  final wings = await fetchWingDetails();
  final wingById = {for (final wing in wings) wing.id: wing};

  for (final instance in map.instances) {
    final wingInfo = wingById[instance.id];
    final assetUrl = map.assets[instance.assetKey];

    final renderable = RenderableMapObject(
      id: instance.id,
      type: instance.type,
      assetKey: instance.assetKey,
      position: instance.position,
      rotation: instance.rotation,
      scale: instance.scale,
      width: instance.width,
      height: instance.height,
      depth: instance.depth,
      color: instance.color,
    );

    scene.add(renderable.build(assetUrl));
  }
}
```

## Final requirement

Build the Flutter viewer as a neutral scene renderer that reads the exported JSON, reconstructs the projected 3D map, and binds each map instance to its own metadata using the exact unique `id` field.

The result must visually match the original map builder scene as closely as possible, even when some elements are procedural rather than GLB-based.