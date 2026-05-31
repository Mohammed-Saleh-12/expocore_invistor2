# ExpoCore Investor Platform — Requirements Document

---

## 1. Functional Requirements

### 1.1 Authentication & Session Management

| Req # | Summary |
|-------|---------|
| FR01 | An investor can register an account by providing company name, trade name, email, phone number, website, password, password confirmation, and activity type. The system validates all fields and requires acceptance of terms and conditions before submission. |
| FR02 | A registered investor can log in using email and password. A "Remember Me" option persists the session. On success, a JWT Bearer token is stored locally and the investor is redirected to the Dashboard. |
| FR03 | An investor can request a password reset link by submitting their registered email address. The system calls the forgot-password endpoint. |
| FR04 | An authenticated investor can log out. The system calls the logout API to invalidate the server-side token, clears local session storage, and redirects to the Login screen. |
| FR05 | The system persists the JWT token, company name, theme preference, and language preference in local storage (SharedPreferences) across sessions. |

### 1.2 Dashboard

| Req # | Summary |
|-------|---------|
| FR06 | An authenticated investor can view a dashboard summary showing: Total Bookings, Active Booths, Published Events, and Total Engagement. |
| FR07 | The investor can filter dashboard statistics by time period: This Month, Last 3 Months, or This Year. The system fetches updated data from the API for the selected period. |
| FR08 | The dashboard displays a list of featured exhibitions and a list of upcoming investor events. |

### 1.3 Exhibitions

| Req # | Summary |
|-------|---------|
| FR09 | The investor can browse all available exhibitions. The list supports real-time search by exhibition name or city. |
| FR10 | The investor can filter the exhibitions list by status: All, Upcoming, Active, or Ended. |
| FR11 | The investor can view the detail page of any exhibition, including description, dates, location, city, available booths, and sectors. |
| FR12 | The investor can toggle an exhibition as a favourite. The system calls POST/DELETE to the favorites API endpoint accordingly. |

### 1.4 Booth Browsing & Map

| Req # | Summary |
|-------|---------|
| FR13 | The investor can view an interactive 3D grid map of an exhibition, rendered with hall partitions and individually coloured booth cells. |
| FR14 | On the 3D map, tapping a booth reveals its number, area, price, and status (available / booked). Available booths can be selected to proceed to booking. |
| FR15 | The investor can navigate directly from a booth cell on the map to the Booking Request screen. |

### 1.5 My Booths & Bookings

| Req # | Summary |
|-------|---------|
| FR16 | The investor can view a list of their booked booths. Each booth shows its number, exhibition name, area, price, status, and end date. |
| FR17 | The investor can filter My Booths by status: All, Active, Under Review, Rejected, or Ended. |
| FR18 | The investor can cancel an active booking from the Booking Detail screen. |

### 1.6 Booth Booking

| Req # | Summary |
|-------|---------|
| FR19 | The investor can submit a booth booking request specifying duration (days), optional add-on services (Screen Display Service, Setup Service, Security Service, Cleaning Service), and notes. |
| FR20 | The system calculates and displays the total booking cost in real time based on duration and selected services. |
| FR21 | On successful submission, the booking status is set to "Under Review" and the investor is notified via a snackbar. |

### 1.7 Booth Profile Management

| Req # | Summary |
|-------|---------|
| FR22 | The investor can manage their booth's public profile, including company nature, services/products description, and headquarters. |
| FR23 | The investor can add, view, and remove social media links for their booth profile. |
| FR24 | The investor can add product images and booth images to their booth profile. |
| FR25 | The investor can view events associated with their booth from the Booth Management screen. |
| FR26 | The investor can save all booth profile changes by calling the booth profile PUT API endpoint. |

### 1.8 Events — Investor Events

| Req # | Summary |
|-------|---------|
| FR27 | The investor can create a new event associated with one of their booths, specifying: name, type, booth, exhibition, date, time, duration (days), max participants, description, and optional ticket configuration. |
| FR28 | Event types include: Workshop, Live Demo, Competition, Seminar, Party, Interview, B2B Meeting, Conference. |
| FR29 | The investor can configure bookable seats with a total seat count and ticket price per seat. |
| FR30 | The investor can specify whether the event uses a general invitation (open) or requires individual ticket approval. |
| FR31 | The investor can view a list of their created events with status, registration count, and a link to ticket requests. |

### 1.9 Events — Sponsor Events & Sponsorships

| Req # | Summary |
|-------|---------|
| FR32 | The investor can browse sponsor events announced by exhibition management for exhibitions where they have an active booth. |
| FR33 | The investor can book a sponsorship slot in a sponsor event by choosing a duration option (with associated days and price) and providing company and product information. |
| FR34 | The investor can view their booked sponsorships with status (Pending, Approved, Active, Ended). |

### 1.10 Ticket Requests

| Req # | Summary |
|-------|---------|
| FR35 | The investor can view all visitor ticket requests for a specific event, showing requester name, phone, email, and request date. |
| FR36 | The investor can approve a ticket request; the system generates a unique ticket number and QR code data. |
| FR37 | The investor can reject a ticket request with a single action. |

### 1.11 Campaigns

| Req # | Summary |
|-------|---------|
| FR38 | The investor can create a new advertising campaign by specifying title, description, type (Exhibition Screens / 3D Map / Special Visitor Offers), budget, and start/end dates. |
| FR39 | The investor can view a list of all campaigns with title, type, status, budget, reach count, and a weekly trend sparkline chart. |
| FR40 | The investor can delete an existing campaign via the campaigns API. |

### 1.12 Analytics

| Req # | Summary |
|-------|---------|
| FR41 | The investor can view performance analytics including: Total Visits, Product Views, Event Participants, and Total Engagement, each with a trend percentage indicator. |
| FR42 | The investor can filter analytics data by time period: This Month, Last 3 Months, This Year, or Custom. |
| FR43 | The analytics screen displays a Visitors Chart and an Engagement Chart rendered as line/bar charts. |
| FR44 | The investor can navigate from the Analytics screen directly to the Reports screen. |

### 1.13 Reports

| Req # | Summary |
|-------|---------|
| FR45 | The investor can view a list of generated reports, each showing title, type, description, period, booth name, exhibition name, and a sparkline trend. |
| FR46 | The investor can filter reports by type: All, Visitors, Performance, Events, Campaigns, or Comparison. |
| FR47 | The investor can view the detailed content of a specific report. |
| FR48 | The investor can download a report in PDF or CSV format. The system shows a download progress indicator. |

### 1.14 Messaging — Exhibition Departments

| Req # | Summary |
|-------|---------|
| FR49 | The investor can view a list of conversations with exhibition department representatives, showing the last message and unread count badge. |
| FR50 | The investor can open an existing conversation or initiate a new one for a specific exhibition from the Exhibition Detail screen. |
| FR51 | The investor can send messages to exhibition departments. Messages are sent to the API and displayed optimistically in the chat view. |

### 1.15 Messaging — Visitor Messages

| Req # | Summary |
|-------|---------|
| FR52 | The investor can view a list of conversations with booth visitors, showing last message and unread count. |
| FR53 | The investor can open a visitor conversation and reply to visitor messages. |
| FR54 | The investor can initiate a conversation with a named visitor. |

### 1.16 Favourites

| Req # | Summary |
|-------|---------|
| FR55 | The investor can view all their favourited items in one screen, organised into three tabs: Exhibitions, Booths, and Events. |
| FR56 | The investor can remove any item from favourites; the system calls DELETE on the corresponding favourites API endpoint. |
| FR57 | The investor can sort favourites by: Date Added, Name, or Status. |

### 1.17 Notifications

| Req # | Summary |
|-------|---------|
| FR58 | The investor can view a list of all notifications with title, body, type, timestamp, and read/unread status. |
| FR59 | The investor can mark an individual notification as read; the system calls PATCH on the notification read endpoint. |
| FR60 | The investor can mark all notifications as read in one action. |

### 1.18 Company Profile

| Req # | Summary |
|-------|---------|
| FR61 | The investor can view their company profile showing name, email, phone, website, and bio, loaded from the API. |
| FR62 | The investor can edit their company profile and save changes via a PUT call to the investor profile endpoint. The company name is also updated in local storage. |
| FR63 | The investor can navigate to their reports from the Profile screen. |

### 1.19 Settings

| Req # | Summary |
|-------|---------|
| FR64 | The investor can toggle between Dark Mode and Light Mode; the preference is saved locally. |
| FR65 | The investor can switch the app language between Arabic and English; the app immediately updates locale and text direction. |
| FR66 | The investor can manage notification preferences (general notifications, favourites alerts, report alerts). |
| FR67 | The investor can log out from the Settings screen (same flow as FR04). |

---

## 2. Non-Functional Requirements

| Req # | Category | Description |
|-------|----------|-------------|
| NFR01 | Security | All authenticated API requests must include a Bearer JWT token in the `Authorization` header. Tokens are obtained at login and invalidated at logout via the server. |
| NFR02 | Reliability / Offline | When the API is unreachable or returns an error, all data screens fall back to locally defined Dummy Data so the app remains usable during backend development or network outages. |
| NFR03 | Localisation | Arabic (RTL) is the primary language. English (LTR) is the secondary language. The app must correctly render text direction for both locales. |
| NFR04 | Theming | The app must support a Dark Theme (primary) and a Light Theme switchable at runtime without restart. |
| NFR05 | Responsiveness & Feedback | All network operations must display a loading indicator while in progress. Errors and successes must be communicated to the user via snackbar notifications in Arabic. |
| NFR06 | Persistence | JWT token, company name, theme preference, language preference, and onboarding completion flag must persist across app restarts using SharedPreferences. |
| NFR07 | Architecture | The project must follow the MVC pattern: Models (data only), Views (UI only), Controllers (business logic via GetX `GetxController`). Direct dependency injection is handled via GetX bindings. |
| NFR08 | API Standard | The backend base URL is `https://api.expocore.app/api/v1`. All endpoints follow RESTful conventions (GET/POST/PUT/PATCH/DELETE). Request and response bodies use JSON. |
| NFR09 | Deployment Platform | The app compiles to Flutter Web and is served by a Node.js server on port 5000. |
| NFR10 | Error Transparency | The system must surface the `message` field from API error responses in user-facing notifications rather than generic messages. |
| NFR11 | State Management | All reactive UI state must use GetX observables (`.obs`) to ensure the view auto-rebuilds on data changes without manual `setState` calls. |
| NFR12 | Code Quality | Business logic must not exist in View files. Views interact with Controllers only through declared methods and observable properties. |
