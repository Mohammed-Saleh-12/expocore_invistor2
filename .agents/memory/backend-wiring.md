---
name: Backend wiring pattern
description: How controllers connect to the Laravel API and why dio must be aliased.
---

## Rule
Import `dio` with a package alias to avoid `FormData` / `MultipartFile` naming conflicts with the `get` package:

```dart
import 'package:dio/dio.dart' as dio;
// Then use: dio.Dio(), dio.Options(), dio.FormData, dio.MultipartFile, dio.DioException
```

## Controller pattern
Every controller:
1. Holds `final _crud = Crud();`
2. Has a `_loadXxx()` method that calls `_crud.getData(AppLink.xxx)` and parses with `Model.fromJson`
3. Falls back to `DummyData.xxx` on API failure so the app still functions during development
4. All write operations (POST/PUT/PATCH/DELETE) call the API, then refresh the list on success

## API response normalization
Laravel responses may wrap data in `data.data` or `data` directly. Use a helper:
```dart
dynamic _body(dynamic data) =>
    (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});

List _asList(dynamic data) {
  if (data is List) return data;
  if (data is Map && data['data'] is List) return data['data'];
  return [];
}
```

## AppLink conventions
- Static constants for fixed endpoints
- Static methods (not string interpolation) for dynamic IDs: `static String boothProfile(int id) => "$server/.../$id";`

## Why
The `get` package ships its own `FormData` and `MultipartFile` from its HTTP layer, which collides with `dio`'s exports when both are imported at the top level. Aliasing `dio` completely avoids the ambiguity.
