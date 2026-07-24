# ExpoCore Investor Platform — Backend API Reference

All requests are made to:

### Authentication Header
Every request (except login / register / forgot-password / reset-password) must include:
```
Authorization: Bearer <token>
```
The token is obtained from the login response and stored client-side.

---

## 1. AUTH

### 1.1 Login
```
POST /auth/login
```
Body (JSON):
```json
{
  "email": "string",
  "password": "string",
  "remember_me": true
}
```

---

### 1.2 Register
```
POST /auth/register
```
Body (JSON):
```json
{
  "company_name": "string",
  "trade_name": "string",
  "email": "string",
  "location": "string",
  "phone": "string",
  "website": "string",
  "password": "string",
  "password_confirmation": "string",
  "activity_type": "string"
}
```

---

### 1.3 Forgot Password
```
POST /auth/forgot-password
```
Body (JSON):
```json
{
  "email": "string"
}
```

---

### 1.4 Reset Password
```
POST /auth/reset-password
```
Body (JSON):
```json
{
  "token": "string",
  "password": "string",
  "password_confirmation": "string"
}
```

---

### 1.5 Logout
```
POST /auth/logout
```
Body: empty `{}`

---

### 1.6 Refresh Token
```
POST /auth/refresh
```
*(endpoint defined, not yet called from a controller)*

---

## 2. EXHIBITIONS

### 2.1 Get All Exhibitions
```
GET /exhibitions
```
Query params (all optional):

| Param | Type | Description |
|---|---|---|
| `page` | integer | Page number |
| `per_page` | integer | Items per page |
| `status` | string | `"active"`, `"upcoming"`, `"ended"` |
| `city` | string | Filter by city |
| `sector` | string | Filter by sector |

---

### 2.2 Get Exhibition Detail
```
GET /exhibitions/{id}
```
No params.

Response includes the following fields beyond the basic listing fields:

| Field | Type | Description |
|---|---|---|
| `images` | `string[]` | Ordered list of image URLs (first = hero) |
| `services` | `string[]` | Exhibition-provided services (e.g. "واي فاي مجاني", "موقف سيارات") |
| `map_data` | `object \| null` | Full 3D map data — halls and booths layout (see §3.2 note) |
| `sponsor_events` | `object[]` | Sponsorship events embedded in this exhibition's detail |

Response example:
```json
{
  "id": 1,
  "name": "معرض التقنية 2026",
  "images": [
    "https://cdn.example.com/ex1-hero.jpg",
    "https://cdn.example.com/ex1-hall-a.jpg"
  ],
  "services": ["واي فاي مجاني", "موقف سيارات", "أمن 24/7", "استقبال", "مطاعم"],
  "map_data": {
    "exhibition_id": 1,
    "grid_width": 13,
    "grid_depth": 10,
    "halls": [
      {
        "id": "A", "name": "القاعة أ", "color": "7A1FFF",
        "booths": [{ "id": 1, "number": "A01", "col": 0, "row": 0, "width": 2, "depth": 2, "status": "available", "price": 18000, "area": 400 }]
      }
    ]
  },
  "sponsor_events": [
    { "id": 10, "name": "حفل افتتاح", "type": "حفل افتتاح", "date": "2026-07-15", "place": "القاعة الرئيسية" }
  ],
  "start_date": "2026-07-15",
  "end_date": "2026-07-20",
  "location": "مركز الرياض للمعارض",
  "city": "الرياض",
  "status": "upcoming",
  "available_booths": 45,
  "sectors": ["تقنية", "ذكاء اصطناعي"]
}
```

> **Note:** `map_data` is embedded in the exhibition detail response. The separate `GET /exhibitions/{id}/map` endpoint still exists on the server but is no longer called by the client — the map is parsed directly from this response via `ExhibitionModel.mapJson`.

---

### 2.3 Toggle Favorite Exhibition
```
POST   /investor/favorites/exhibitions/{id}     — add to favorites
DELETE /investor/favorites/exhibitions/{id}     — remove from favorites
```
POST body: empty `{}`

---

## 3. BOOTHS

### 3.1 Get All Booths
```
GET /booths
```
Query params (all optional):

| Param | Type | Description |
|---|---|---|
| `exhibition_id` | integer | Filter by exhibition |
| `status` | string | `"available"`, `"booked"` |
| `page` | integer | Page number |
| `per_page` | integer | Items per page |

---

### 3.2 Get Exhibition Booths
```
GET /booths?exhibition_id={id}
```
Returns all booths belonging to a specific exhibition. Called automatically by `ExhibitionDetailController` on opening the exhibition detail page.

Response example:
```json
{
  "data": [
    {
      "id": 1,
      "number": "A01",
      "exhibition_name": "معرض التقنية 2026",
      "area": 400,
      "price": 18000,
      "status": "available",
      "location": "القاعة أ - صف 1",
      "amenities": ["واي فاي", "كهرباء", "إضاءة"],
      "services": {
        "شاشة عرض إضافية": 500,
        "إضاءة مميزة": 300,
        "خدمة تجهيز": 800
      }
    },
    {
      "id": 2,
      "number": "A02",
      "status": "booked",
      "company_name": "تقنية الغد",
      "company_email": "info@techfuture.sa",
      "company_initials": "تغ",
      "services": {}
    }
  ]
}
```

| Response field | Model field | Notes |
|---|---|---|
| `services` | `BoothModel.services: Map<String,double>` | Dynamic map of service name → price |
| `company_name` | `BoothModel.companyName` | Present only when `status == "booked"` |
| `company_email` | `BoothModel.companyEmail` | Present only when `status == "booked"` |
| `company_initials` | `BoothModel.companyInitials` | Present only when `status == "booked"` |

---

### 3.3 Book a Booth
```
POST /booths/book
```
Body (JSON):
```json
{
  "booth_id": "integer",
  "start_date": "string (YYYY-MM-DD)",
  "end_date": "string (YYYY-MM-DD)",
  "notes": "string",
  "services": {
    "شاشة عرض إضافية": true,
    "إضاءة مميزة": false,
    "خدمة تجهيز": true
  },
  "total_price": "number"
}
```

**Booking modes (client-side):**

| Mode | Description | Sent dates |
|---|---|---|
| Full period (`full`) | Book the entire availability window | `start_date` and `end_date` taken directly from `BoothModel.startDate` / `endDate` |
| Specific days (`custom`) | Investor picks a consecutive day range within the availability window | `start_date` = first selected day, `end_date` = last selected day |

> **Notes:**
> - `duration_days` is **no longer sent**. The backend derives duration from `start_date` and `end_date`.
> - Consecutive-day constraint is enforced on the client: the investor picks a contiguous range (no gaps).
> - If only a single day is selected, `start_date` equals `end_date`.
> - `services` is a dynamic map of `{ "service name": selected (bool) }`. Available service names and prices come from `BoothModel.services` (returned by §3.2).

---

### 3.4 Toggle Favorite Booth
```
POST   /investor/favorites/booths/{id}          — add to favorites
DELETE /investor/favorites/booths/{id}          — remove from favorites
```
POST body: empty `{}`

---

## 4. INVESTOR — DASHBOARD

### 4.1 Get Dashboard Data
```
GET /investor/dashboard?period={period}
```
Query params:

| Param | Type | Example values |
|---|---|---|
| `period` | string | `"week"`, `"month"`, `"year"` |

---

## 5. INVESTOR — PROFILE

### 5.1 Get Profile
```
GET /investor/profile
```
No params.

---

### 5.2 Update Profile
```
PUT /investor/profile
```
Body (JSON):
```json
{
  "company_name": "string",
  "email": "string",
  "location": "string",
  "phone": "string",
  "website": "string",
  "bio": "string",
  "social": {
    "linkedin": "string",
    "twitter": "string",
    "instagram": "string",
    "facebook": "string"
  }
}
```

---

## 6. INVESTOR — BOOKINGS

### 6.1 Get All Bookings
```
GET /investor/bookings
```
No params.

---

### 6.2 Cancel a Booking
```
PATCH /investor/bookings/{id}/cancel
```
Body: empty `{}`

---

## 7. INVESTOR — BOOTH PROFILE

### 7.1 Get Booth Profile
```
GET /investor/booths/{boothId}/profile
```
No params.

---

### 7.2 Update Booth Profile
```
PUT /investor/booths/{boothId}/profile
```
Body (JSON):
```json
{
  "company_nature": "string",
  "services_products": "string",
  "headquarters": "string",
  "social_links": "object",
  "product_images": "array",
  "booth_images": "array"
}
```

---

## 8. INVESTOR — CAMPAIGNS

### 8.1 Get All Campaigns
```
GET /investor/campaigns
```
No params.

---

### 8.2 Create a Campaign
```
POST /investor/campaigns
```
Body (JSON):
```json
{
  "title": "string",
  "description": "string",
  "type": "string",
  "budget": "number",
  "start_date": "string (date)",
  "end_date": "string (date)"
}
```

---

### 8.3 Delete a Campaign
```
DELETE /investor/campaigns/{id}
```
No body.

---

## 9. INVESTOR — EVENTS

### 9.1 Get All Investor Events
```
GET /investor/events
```
No params.

---

### 9.2 Get Events for a Specific Booth
```
GET /investor/events?booth_id={boothId}
```
Query params:

| Param | Type |
|---|---|
| `booth_id` | integer |

---

### 9.3 Create an Event
```
POST /investor/events
```
Body (JSON):
```json
{
  "name": "string",
  "type": "string",
  "booth_id": "integer",
  "booth_number": "string",
  "exhibition_name": "string",
  "start_date": "string (YYYY-MM-DD)",
  "end_date": "string (YYYY-MM-DD)",
  "time": "string (HH:MM)",
  "max_participants": "integer",
  "description": "string",
  "requires_booking": true,
  "has_bookable_seats": true,
  "total_seats": "integer",
  "ticket_price": "number",
  "is_general_invitation": true,
  "ticket_type": "string",
  "free_ticket_limit": "integer",
  "video_promo_url": "string"
}
```

**Date selection rules (client-side):**

| Rule | Detail |
|---|---|
| Date range | Both `start_date` and `end_date` must fall within the booked booth's availability window (`BoothModel.startDate` → `BoothModel.endDate`) |
| Consecutive days | The investor picks a contiguous range — no gaps allowed |
| Single-day event | `start_date` equals `end_date` |
| Duration | Derived by the backend from `end_date − start_date + 1`; `duration_days` is **no longer sent** |

---

### 9.4 Get Ticket Requests for an Event
```
GET /investor/events/{id}/ticket-requests
```
No params.

---

### 9.5 Approve or Reject a Ticket Request
```
PATCH /investor/events/{eventId}/ticket-requests/{reqId}
```
Body (JSON) — approve:
```json
{ "action": "approve" }
```
Body (JSON) — reject:
```json
{ "action": "reject" }
```

---

### 9.6 Toggle Favorite Event
```
POST   /investor/favorites/events/{id}          — add to favorites
DELETE /investor/favorites/events/{id}          — remove from favorites
```
POST body: empty `{}`

---

## 10. INVESTOR — SPONSOR EVENTS & SPONSORSHIPS

### 10.1 Get All Available Sponsor Events (catalogue)
```
GET /investor/sponsor-events
```
No params.

---

### 10.2 Get Investor's Sponsorships
```
GET /investor/sponsorships
```
No params.

---

### 10.3 Book a Sponsorship
```
POST /investor/sponsorships
```
Body (JSON):
```json
{
  "event_id": "integer",
  "selected_duration_label": "string"
}
```

---

### 10.4 Cancel a Sponsorship
*(endpoint defined, not yet called from a controller)*
```
PATCH /investor/sponsorships/{id}/cancel
```

---

## 11. INVESTOR — ANALYTICS

### 11.1 Get Analytics Data
```
GET /investor/analytics?period={period}
```
Query params:

| Param | Type | Example values |
|---|---|---|
| `period` | string | `"week"`, `"month"`, `"year"` |

---

## 12. INVESTOR — MESSAGES (Exhibitor Conversations)

### 12.1 Get All Conversations
```
GET /investor/messages
```
No params.

---

### 12.2 Get a Conversation
```
GET /investor/messages/{id}
```
No params.

---

### 12.3 Start a New Conversation with an Exhibitor
```
POST /investor/messages
```
Body (JSON):
```json
{
  "exhibition_id": "integer",
  "exhibition_name": "string"
}
```

---

### 12.4 Send a Message in a Conversation
```
POST /investor/messages/{id}/send
```
Body (JSON):
```json
{
  "text": "string"
}
```

---

## 13. INVESTOR — VISITOR MESSAGES

### 13.1 Get All Visitor Conversations
```
GET /investor/visitor-messages
```
No params.

---

### 13.2 Get a Visitor Conversation
```
GET /investor/visitor-messages/{id}
```
No params.

---

### 13.3 Send a Message to a Visitor
```
POST /investor/visitor-messages/{id}/send
```
Body (JSON):
```json
{
  "text": "string"
}
```

---

## 14. INVESTOR — FAVORITES

### 14.1 Get All Favorites
```
GET /investor/favorites
```
No params. Returns exhibitions, booths, and events in one response.

---

*(Individual toggle endpoints are listed under their respective sections: §2.3, §3.4, §9.6)*

---

## 15. INVESTOR — REPORTS

### 15.1 Get All Reports
```
GET /investor/reports
```
No params.

---

### 15.2 Download a Report
```
GET /investor/reports/{id}/download?format={fmt}
```
Query params:

| Param | Type | Values |
|---|---|---|
| `format` | string | `"pdf"` or `"excel"` |

This endpoint streams a file (PDF or XLSX). The response body is binary.

---

## 16. INVESTOR — NOTIFICATIONS

### 16.1 Get All Notifications
```
GET /investor/notifications
```
No params.

---

### 16.2 Mark a Notification as Read
```
PATCH /investor/notifications/{id}/read
```
Body: empty `{}`

---

### 16.3 Mark All Notifications as Read
```
PATCH /investor/notifications/read-all
```
Body: empty `{}`

---