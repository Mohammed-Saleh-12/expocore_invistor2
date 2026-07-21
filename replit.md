# ExpoCore - Investor Platform

A Flutter web application for investors to manage their presence in exhibitions and trade shows. Features include browsing exhibitions, booking booths, managing events, launching advertising campaigns, messaging, and performance analytics.

## Tech Stack

- **Framework:** Flutter 3.32 (Dart 3.8)
- **State Management:** GetX
- **Backend:** Custom REST API at `https://api.expocore.app/api/v1`
- **Auth:** JWT Bearer tokens (own backend auth)
- **Push Notifications:** Firebase Messaging (FCM)
- **UI:** CanvasKit renderer (WebGL-based)

## Running the App

The workflow `Start application` builds the Flutter web app and serves it on port 5000 via Node.js.

To rebuild after code changes:
```bash
flutter build web --profile
```
> **Important:** Use `--profile`, not `--release`. Flutter 3.32.0 has a dart2js compiler bug that crashes release builds. Profile builds are functionally identical for users.
Then restart the workflow.

## Project Structure

- `lib/core/` — constants, services, utilities, localization
- `lib/controller/` — GetX controllers (business logic)
- `lib/view/` — UI screens and widgets
- `lib/data/model/` — data models
- `lib/bindings/` — GetX dependency injection bindings
- `build/web/` — compiled Flutter web output (served by Node.js)

## Notes

- The app uses Flutter's CanvasKit (WebGL) renderer — screenshot tools will show a blank page, but the app renders correctly in a real browser
- Firebase config in `lib/firebase_options.dart` is public web config (standard Flutter/Firebase practice)
- API environment is set in `lib/core/constant/app_env.dart` (`_Env.dev` by default)

## User Preferences
