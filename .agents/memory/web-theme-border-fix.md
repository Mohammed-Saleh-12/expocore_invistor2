---
name: Web theme toggle — border colours frozen until refresh
description: Why OutlineInputBorder colours on web don't update on theme change, and the two-part fix applied.
---

## Rule
When `WebTheme.setDark()` is called, it must also call `Get.changeThemeMode()` so Flutter propagates a full widget-tree rebuild. Without this, the inner `Obx` in `_WebHome` (which only tracks `nav.selected` / `nav.detail`) is reused by Flutter's element reconciliation and never re-runs `_page()`, so all inline `WebTheme.*` calls in page `_field()` helpers stay frozen.

Additionally, any widget that hardcodes `AppColors.darkPrimary` for border colours (e.g. `AppTextField`) must instead read `Theme.of(context).colorScheme.primary` so it reacts to the theme change.

**Why:** `WebTheme.*` getters are plain static getters — they return the correct value when *called*, but they're not Rx-tracked unless called inside an `Obx`. If the page widget is not rebuilt (due to inner-Obx reuse), the getters are never re-called and colours stay stale. `Get.changeThemeMode()` triggers Flutter's own theme propagation, which marks the whole tree dirty and forces every `build()` to re-run.

**How to apply:**
- `lib/web/models/web_theme.dart` → `setDark()` must call `Get.changeThemeMode(v ? ThemeMode.dark : ThemeMode.light)` alongside `isDark.value = v`.
- Any widget building `InputDecoration` borders with hardcoded `AppColors.darkXxx` → replace with `Theme.of(context).colorScheme.primary` (or the appropriate semantic token).
- If `flutter pub get` is skipped after a Replit session restart, the pub cache can lose package resolution (seen with `_flutterfire_internals`). Always run `flutter pub get` before `flutter build web` in a fresh session.
