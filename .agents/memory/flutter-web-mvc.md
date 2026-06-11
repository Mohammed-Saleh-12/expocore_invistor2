---
name: Flutter Web MVC Conventions
description: Rules and patterns enforced for MVC compliance across the ExpoCore web layer
---

## Rule
Views (pages/widgets under `lib/web/`) must contain zero business logic or formatting. All logic belongs in controllers or models.

**Why:** The project enforces strict MVC — controllers manage state and logic, models own domain behavior, views only render.

## How to apply

### Domain labels (e.g. status strings like "active" → "جارٍ")
- Add a `String get statusLabel` getter directly to the **model** class (no Flutter import needed — pure Dart).
- Models live in `lib/data/model/`. Both `ExhibitionModel` and `SponsorshipBookingModel` now have `statusLabel`.

### Number / date formatting
- Formatting methods belong on the relevant **controller**, not the view.
- `DashboardController.formatEngagement(int v)` — K/M abbreviation.
- `ReportsController.formatDate(DateTime? d)` — yyyy-MM-dd padding.

### UI-only state (tab index, hover, etc.)
- Hover state is the only acceptable `StatefulWidget` state in views (it is purely visual).
- Tab/page-level state → reactive `RxInt` on the appropriate controller.
- `WebNavController.messagesTab` (`.obs`) drives the messages tab; `WebMessagesPage` is now a `StatelessWidget`.

### Color mapping for status
- Status → `Color` mapping **may stay in the view** because `Color` is a Flutter UI class and models should not import Flutter.
- When a color map and a label map duplicate each other, extract the label into the model and keep the color in the view.

### GetX navigation calls from view
- Calling `WebNavController.to.select(n)` or `WebNavController.to.openX()` from a view is acceptable — it is a controller method, not business logic.

### `ever()` Workers / reactive side-effects
- Must live in `controller.onInit()`, never in `StatefulWidget.initState()`.
- `WebAuthController.onInit()` owns all auth-state `ever()` watchers.
