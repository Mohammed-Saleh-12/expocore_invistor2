---
name: Flutter dart2js compiler crash fix
description: dart2js crashes with "Bad state: Non-constant annotation" when .dart_tool has stale intermediate files from an interrupted build.
---

The dart2js compiler crashes with errors like:
- `Bad state: Non-constant annotation on _#ImplicitlyAnimatedWidgetState#controller#FI`
- `Error: Undefined name 'protected'` on Flutter SDK files

This is NOT a user code bug — it's stale/corrupted intermediate files in `.dart_tool/flutter_build/`.

**Why:** When a workflow restart interrupts an in-progress `flutter build web --release`, it leaves partial `.dart_tool` state. The next build picks up corrupted intermediate `.dill` files and dart2js crashes.

**How to apply:** Whenever `flutter build web --release` crashes with a dart2js internal error or `@protected` annotation errors inside Flutter SDK files, run:
```
flutter clean
flutter pub get
flutter build web --release
```
Then restart the workflow. The clean wipes `.dart_tool` and `build/`, forcing a fresh compilation.
