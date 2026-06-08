# ExpoCore Investor Platform — Use Cases Document

---

## Use Cases Table

| Use Case ID | Use Case Name | General Description | Requirement(s) |
|-------------|---------------|---------------------|----------------|
| UC01 | Register Account | A new investor completes the registration form with company and personal details to create an account on the platform. | FR01 |
| UC02 | Login | A registered investor authenticates with email and password to access the platform. | FR02, FR05 |
| UC03 | Recover Password | An investor who has forgotten their password requests a reset link to be sent to their email. | FR03 |
| UC04 | Logout | An authenticated investor ends their session, invalidating the server token and clearing local storage. | FR04, FR05 |
| UC05 | View Dashboard | An authenticated investor views a summary of their activity (bookings, booths, events, engagement) for a chosen time period, along with featured exhibitions and upcoming events. | FR06, FR07, FR08 |
| UC06 | Browse Exhibitions | An investor searches and filters the full list of exhibitions by name/city and by status. | FR09, FR10 |
| UC07 | View Exhibition Detail | An investor views full details of a specific exhibition including dates, location, sectors, and available booths. | FR11 |
| UC08 | Favourite an Exhibition | An investor toggles the favourite status of an exhibition, persisting the change to the server. | FR12 |
| UC09 | View 3D Booth Map | An investor opens an interactive, zoomable 3D-grid map of an exhibition showing hall partitions, booth cells, and company occupancy. | FR13, FR14 |
| UC10 | Select Booth from Map | An investor taps a booth cell on the map to view its details (number, area, price, status) and decides whether to book it. | FR14, FR15 |
| UC11 | Book a Booth | An investor submits a booking request for a chosen booth, selecting duration and optional add-on services; the system calculates the total cost and sends the request to the API. | FR19, FR20, FR21 |
| UC12 | View My Booths | An investor views the list of all their bookings filtered by booth status. | FR16, FR17 |
| UC13 | Cancel Booking | An investor cancels an active booking from the Booking Detail screen. | FR18 |
| UC14 | Manage Booth Profile | An investor edits their booth's public profile — company description, services, social links, and media images — and saves to the server. | FR22, FR23, FR24, FR25, FR26 |
| UC15 | Create Event | An investor creates a new event for one of their booths, specifying all event details including optional ticket and seat configuration. | FR27, FR28, FR29, FR30 |
| UC16 | View My Events | An investor views all their created events and their status. | FR31 |
| UC17 | Browse Sponsor Events | An investor browses exhibition-management-announced events where sponsorship slots are available for their exhibitions. | FR32 |
| UC18 | Book Sponsorship | An investor books a sponsorship slot in a sponsor event by selecting a duration option and providing company details. | FR33 |
| UC19 | View My Sponsorships | An investor views all their sponsorship bookings and their approval status. | FR34 |
| UC20 | Manage Ticket Requests | An investor views incoming ticket requests for one of their events and approves or rejects each one. Approvals generate a QR-code ticket. | FR35, FR36, FR37 |
| UC21 | Create Campaign | An investor creates a new advertising campaign by specifying type, budget, and date range. | FR38 |
| UC22 | View Campaigns | An investor views a list of all their campaigns with performance metrics and weekly trend charts. | FR39 |
| UC23 | Delete Campaign | An investor permanently deletes a campaign via the API. | FR40 |
| UC24 | View Analytics | An investor views aggregated performance metrics with trend indicators and charts for a selected time period. | FR41, FR42, FR43 |
| UC25 | Navigate to Reports | An investor navigates from the Analytics screen to the Reports screen. | FR44 |
| UC26 | Browse Reports | An investor views the list of available reports filtered by report type. | FR45, FR46 |
| UC27 | View Report Detail | An investor opens a specific report to view its full content. | FR47 |
| UC28 | Download Report | An investor downloads a report in PDF or CSV format, with a live progress indicator shown during download. | FR48 |
| UC29 | View Exhibition Conversations | An investor views the list of conversations with exhibition department representatives, including unread message counts. | FR49 |
| UC30 | Chat with Exhibition Department | An investor opens a conversation thread with an exhibition department and sends text messages. | FR50, FR51 |
| UC31 | Initiate Exhibition Conversation | An investor starts a new conversation with an exhibition department from the Exhibition Detail screen. | FR50 |
| UC32 | View Visitor Conversations | An investor views the list of chat threads from booth visitors with unread counts. | FR52 |
| UC33 | Reply to Visitor | An investor opens a visitor conversation and sends a reply message. | FR53 |
| UC34 | Initiate Visitor Conversation | An investor starts a new conversation with a named visitor. | FR54 |
| UC35 | View All Favourites | An investor views all their saved items (exhibitions, booths, events) in tabbed lists. | FR55, FR57 |
| UC36 | Remove Favourite | An investor removes any item from their favourites list; the change is persisted to the server. | FR56 |
| UC37 | View Notifications | An investor views all platform notifications sorted by time. | FR58 |
| UC38 | Mark Notification Read | An investor marks a single notification as read, updating the server record. | FR59 |
| UC39 | Mark All Notifications Read | An investor marks all notifications as read in one action. | FR60 |
| UC40 | View Company Profile | An investor views their loaded company profile data. | FR61 |
| UC41 | Edit Company Profile | An investor edits and saves their company profile, updating both the server and local company name. | FR62 |
| UC42 | Change Theme | An investor switches between Dark and Light mode; the preference is saved and applied immediately. | FR64 |
| UC43 | Change Language | An investor switches the app language between Arabic and English; text direction and locale update instantly. | FR65 |
| UC44 | Manage Notification Preferences | An investor enables or disables categories of push notification (general, favourites, reports). | FR66 |
