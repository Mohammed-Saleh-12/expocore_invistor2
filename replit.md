# ExpoCore - Investor Platform

A Flutter web application for investors and companies participating in exhibitions and trade shows. It allows them to manage booth bookings, create events and campaigns, view analytics, and communicate through an integrated messaging system.

## Tech Stack
- **Framework:** Flutter (SDK ^3.8.0) compiled to web
- **State Management:** GetX
- **Networking:** Dio (connects to `https://api.expocore.app/api/v1`)
- **Charts:** fl_chart
- **Local Storage:** shared_preferences

## How to Run
The app builds Flutter to web and serves it via a Node.js server on port 5000.

The workflow `Start application` runs:
```
flutter build web --release && node serve.js
```

## User Preferences
