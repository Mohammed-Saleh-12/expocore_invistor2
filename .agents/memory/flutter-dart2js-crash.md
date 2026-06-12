---
name: Flutter 3.32.0 dart2js crash workaround
description: dart2js compiler crashes in --release mode; use --profile instead
---

## Rule
Never use `flutter build web --release` in this project. Use `flutter build web --profile` instead.

**Why:** Flutter 3.32.0 / Dart 3.8.0 has a known dart2js compiler bug: `Bad state: Non-constant annotation on _#ImplicitlyAnimatedWidgetState#controller#FI`. It crashes the release build every time via the `LateLowering._copyAnnotations` path. Profile mode skips that optimization pass and builds successfully.

**How to apply:** Any workflow or build script that builds for web must use `--profile` not `--release`. The deployed app feels identical to release for users.
