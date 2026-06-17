---
name: Web detail page MVC pattern
description: How StatelessWidget detail pages in the web module receive their data model without constructor params, following GetX MVC rules.
---

## The Rule
Web detail pages (`WebBoothManagementPage`, `WebBookingRequestPage`) are `StatelessWidget` — they carry **no** constructor parameters and perform **no** init logic. All controller setup (including `webInit`, `resetForWeb`, and `ever()` workers) is done in `WebNavController` before the route change.

**Why:** MVC rule — views must be zero-logic. `initState()` workers lived in the view, which violated the convention and made the view stateful unnecessarily.

## How to apply
1. `WebNavController.openXxx(model)` — get/put the target controller, call its setup method, then set `detail.value`.
2. The detail page's `build()` calls `Get.find<XxxController>()` and reads reactive state from the controller.
3. `WebDetailView` renders `const XxxPage()` (no data args).

## Success callback pattern (BookingController)
When web-mode navigation needs to react to a controller event (e.g., close detail on booking success), use a stored `VoidCallback? _onWebSuccess` field. `resetForWeb(b, closeDetail)` sets it; `submitBooking()` calls and nulls it after success. This avoids `ever()` in the view and avoids coupling controllers to WebNavController.

## Controller init pattern in WebNavController
```dart
final c = Get.isRegistered<XxxController>()
    ? Get.find<XxxController>()
    : Get.put(XxxController());
c.setupMethod(data);
detail.value = WebDetailRequest(WebDetailType.xxx, data: data);
```
