---
name: Web theme toggle partial staleness (const widget skip)
description: Why toggling dark/light mode on the web shell (lib/web/...) can leave some widgets showing the old theme until navigation/refresh
---

## Rule
In `lib/web/view/pages/web_app.dart`, the page widgets returned by `_WebHome._page(i)` and the auth-gate branches in `_WebRoot` must NOT be `const`. Same applies to any future top-level web page/shell widget that reads `WebTheme.*` getters directly in its own `build()` (outside an inner `Obx`).

**Why:** Flutter's `Element.updateChild` skips calling `build()` again when the incoming widget is `==` to the previous one (`child.widget == newWidget`). Zero-arg `const WebXxxPage()` calls are canonicalized to a single singleton instance, so on every rebuild of the ancestor `Obx` (triggered by `WebTheme.isDark` changing), the exact same const instance is handed down and Flutter concludes "nothing changed" — skipping that page's `build()` entirely. Any theme-dependent styling read directly in that build (not wrapped in its own `Obx`) then stays frozen until the widget is torn down and recreated (switching to a different nav section changes the `ValueKey`, or a full page refresh remounts everything from scratch). This exactly reproduces the reported symptom: toggling dark/light mode on web leaves some parts on the old theme until you navigate away or refresh; mobile doesn't have this parallel `WebTheme`/const-page shell so it isn't affected.

**How to apply:** When adding a new page/screen to the web shell (`lib/web/view/pages/`) that's dispatched from `_WebHome._page()` or similar switch/map lookups feeding an `Obx`, construct it without `const`. Alternatively, wrap all `WebTheme.*`-dependent parts of the page in their own local `Obx` (Obx's internal State persists and reacts to Rx changes independently of parent rebuild-skips) — but removing `const` at the dispatch site is the simpler, systemic fix already applied.
