# توثيق كل الريكوستات (API Requests) في التطبيق

هذا الملف يوثّق كل نداءات الـ API الموجودة في التطبيق، مصدرها في الكود (ملفات `lib/data/sourcedata/remote/...`)، نوع الريكوست (HTTP Method)، الرابط (Endpoint)، ومحتوى الـ Body/Params إن وُجد.

> ملاحظة: كل الروابط تُبنى من `AppLink` في `lib/linkapi.dart`، وقاعدة الرابط (`server`) تأتي من `AppEnv.baseUrl` وتتغير تلقائياً حسب بيئة التشغيل (dev/staging/prod).

---

## 1. المصادقة (Auth) — `remote/Auth/`

### 1.1 تسجيل الدخول — `LoginData.login()`
- **Method:** `POST`
- **Endpoint:** `/auth/login`
- **Body:**
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```

### 1.2 إنشاء حساب — `RegisterData.register()`
- **Method:** `POST`
- **Endpoint:** `/auth/register`
- **Body:**
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

### 1.3 نسيت كلمة المرور — `ForgotPasswordData.sendResetLink()`
- **Method:** `POST`
- **Endpoint:** `/auth/forgot-password`
- **Body:**
  ```json
  { "email": "string" }
  ```

### 1.4 إعادة تعيين كلمة المرور — `ResetPasswordData.resetPassword()`
- **Method:** `POST`
- **Endpoint:** `/auth/reset-password`
- **Body:**
  ```json
  {
    "token": "string",
    "password": "string",
    "password_confirmation": "string"
  }
  ```

### 1.5 تسجيل الخروج — `LogoutData.logout()`
- **Method:** `POST`
- **Endpoint:** `/auth/logout`
- **Body:** لا يوجد (`{}`)

### 1.6 تحديث الجلسة (Refresh Token)
- **Endpoint معرّف في AppLink فقط:** `/auth/refresh` — لا يوجد استخدام فعلي حالياً في أي ملف `remote` أو كونترولر.

### 1.7 توكن الإشعارات (FCM Token)
- **Endpoint معرّف في AppLink فقط:** `/auth/fcm-token` (`AppLink.fcmToken`) — يُستخدم مباشرة من خدمة الإشعارات (`fcmConfig.dart`) وليس عبر طبقة `remote`، لذا لم يُدرج ضمن إعادة الهيكلة.

---

## 2. لوحة التحكم (Dashboard) — `remote/Dashboard/`

### 2.1 بيانات لوحة التحكم — `DashboardData.getDashboard(period)`
- **Method:** `GET`
- **Endpoint:** `/investor/dashboard`
- **Query Params:**
  ```json
  { "period": "string  // مثال: week, month, year" }
  ```
- **Body:** لا يوجد

---

## 3. المعارض (Exhibitions) — `remote/Exhibitions/`

### 3.1 جلب كل المعارض — `ExhibitionsData.getExhibitions()`
- **Method:** `GET`
- **Endpoint:** `/exhibitions`
- **Body:** لا يوجد

### 3.2 إضافة معرض للمفضلة — `ExhibitionsData.addFavorite(exhibitionId)`
- **Method:** `POST`
- **Endpoint:** `/investor/favorites/exhibitions/{id}`
- **Body:** لا يوجد (`{}`)

### 3.3 إزالة معرض من المفضلة — `ExhibitionsData.removeFavorite(exhibitionId)`
- **Method:** `DELETE`
- **Endpoint:** `/investor/favorites/exhibitions/{id}`
- **Body:** لا يوجد

> ملاحظة: `AppLink.exhibitionDetail(id)` معرّف (`/exhibitions/{id}`) لكن غير مستخدم حالياً — تفاصيل المعرض تُعرض من نفس بيانات القائمة.

---

## 4. الأجنحة (Booths) — `remote/Booths/`

### 4.1 حجوزاتي — `BoothsData.getMyBookings()`
- **Method:** `GET`
- **Endpoint:** `/investor/bookings`
- **Body:** لا يوجد

### 4.2 إضافة جناح للمفضلة — `BoothsData.addFavorite(boothId)`
- **Method:** `POST`
- **Endpoint:** `/investor/favorites/booths/{id}`
- **Body:** لا يوجد (`{}`)

### 4.3 إزالة جناح من المفضلة — `BoothsData.removeFavorite(boothId)`
- **Method:** `DELETE`
- **Endpoint:** `/investor/favorites/booths/{id}`
- **Body:** لا يوجد

> ملاحظة: `AppLink.booths` (`GET /booths`) و`AppLink.boothDetail(id)` معرّفان لكن غير مستخدمين حالياً في أي `remote` class.

---

## 5. ملف الجناح (Booth Profile) — `remote/Booths/BoothProfileData.dart`

### 5.1 جلب ملف الجناح — `getBoothProfile(boothId)`
- **Method:** `GET`
- **Endpoint:** `/investor/booths/{boothId}/profile`
- **Body:** لا يوجد

### 5.2 تحديث ملف الجناح — `updateBoothProfile()`
- **Method:** `PUT`
- **Endpoint:** `/investor/booths/{boothId}/profile`
- **Body:**
  ```json
  {
    "company_nature": "string",
    "services_products": "string",
    "headquarters": "string",
    "social_links": ["string"],
    "product_images": ["string"],
    "booth_images": ["string"]
  }
  ```

### 5.3 فعاليات الجناح — `getBoothEvents(boothId)`
- **Method:** `GET`
- **Endpoint:** `/investor/events`
- **Query Params:**
  ```json
  { "booth_id": "int" }
  ```
- **Body:** لا يوجد

---

## 6. الحجوزات (Booking) — `remote/Booking/`

### 6.1 حجز جناح — `BookingData.bookBooth()`
- **Method:** `POST`
- **Endpoint:** `/booths/book`
- **Body:**
  ```json
  {
    "booth_id": "int",
    "duration_days": "int",
    "notes": "string",
    "screen_service": "bool",
    "setup_service": "bool",
    "security_service": "bool",
    "cleaning_service": "bool",
    "total_price": "double"
  }
  ```

### 6.2 إلغاء حجز — `BookingData.cancelBooking(bookingId)`
- **Method:** `PATCH`
- **Endpoint:** `/investor/bookings/{id}/cancel`
- **Body:** لا يوجد (`{}`)

---

## 7. الحملات (Campaigns) — `remote/Campaigns/`

### 7.1 جلب الحملات — `getCampaigns()`
- **Method:** `GET`
- **Endpoint:** `/investor/campaigns`
- **Body:** لا يوجد

### 7.2 إنشاء حملة — `createCampaign()`
- **Method:** `POST`
- **Endpoint:** `/investor/campaigns`
- **Body:**
  ```json
  {
    "title": "string",
    "description": "string",
    "type": "string",
    "budget": "double",
    "start_date": "string",
    "end_date": "string"
  }
  ```

### 7.3 حذف حملة — `deleteCampaign(campaignId)`
- **Method:** `DELETE`
- **Endpoint:** `/investor/campaigns/{id}`
- **Body:** لا يوجد

---

## 8. الفعاليات (Events) — `remote/Events/`

### 8.1 فعالياتي — `getInvestorEvents()`
- **Method:** `GET`
- **Endpoint:** `/investor/events`
- **Body:** لا يوجد

### 8.2 إنشاء فعالية — `createInvestorEvent()`
- **Method:** `POST`
- **Endpoint:** `/investor/events`
- **Body:**
  ```json
  {
    "name": "string",
    "type": "string",
    "booth_id": "int",
    "booth_number": "string",
    "exhibition_name": "string",
    "date": "string",
    "time": "string",
    "max_participants": "int",
    "description": "string",
    "requires_booking": "bool",
    "duration_days": "int",
    "has_bookable_seats": "bool",
    "total_seats": "int",
    "ticket_price": "double",
    "is_general_invitation": "bool",
    "ticket_type": "string",
    "free_ticket_limit": "int",
    "video_promo_url": "string"
  }
  ```

### 8.3 فعاليات الرعاية المتاحة — `getSponsorEvents()`
- **Method:** `GET`
- **Endpoint:** `/investor/sponsor-events`
- **Body:** لا يوجد

### 8.4 رعاياتي — `getSponsorships()`
- **Method:** `GET`
- **Endpoint:** `/investor/sponsorships`
- **Body:** لا يوجد

### 8.5 إنشاء رعاية — `createSponsorship()`
- **Method:** `POST`
- **Endpoint:** `/investor/sponsorships`
- **Body:**
  ```json
  {
    "event_id": "int",
    "selected_duration_label": "string",
    "selected_days": "int",
    "price": "double",
    "company_name": "string",
    "company_website": "string",
    "company_phone": "string",
    "product_names": "string"
  }
  ```

### 8.6 طلبات التذاكر لفعالية — `getTicketRequests(eventId)`
- **Method:** `GET`
- **Endpoint:** `/investor/events/{eventId}/ticket-requests`
- **Body:** لا يوجد

### 8.7 قبول/رفض طلب تذكرة — `ticketRequestAction(eventId, requestId, action)`
- **Method:** `PATCH`
- **Endpoint:** `/investor/events/{eventId}/ticket-requests/{requestId}`
- **Body:**
  ```json
  { "action": "string  // accept | reject" }
  ```

### 8.8 إضافة فعالية للمفضلة — `addFavoriteEvent(eventId)`
- **Method:** `POST`
- **Endpoint:** `/investor/favorites/events/{id}`
- **Body:** لا يوجد (`{}`)

### 8.9 إزالة فعالية من المفضلة — `removeFavoriteEvent(eventId)`
- **Method:** `DELETE`
- **Endpoint:** `/investor/favorites/events/{id}`
- **Body:** لا يوجد

> ملاحظة: `AppLink.eventDetail(id)` و`AppLink.cancelSponsorship(id)` معرّفان لكن غير مستخدمين حالياً في أي `remote` class.

---

## 9. المفضلة (Favorites) — `remote/Favorites/`

### 9.1 جلب كل المفضلة — `getFavorites()`
- **Method:** `GET`
- **Endpoint:** `/investor/favorites`
- **Body:** لا يوجد

> إضافة/إزالة عناصر المفضلة (معارض، أجنحة، فعاليات) تتم عبر `ExhibitionsData` / `BoothsData` / `EventsData` أعلاه.

---

## 10. الرسائل (Messages) — `remote/Messages/`

### 10.1 جلب المحادثات — `getConversations()`
- **Method:** `GET`
- **Endpoint:** `/investor/messages`
- **Body:** لا يوجد

### 10.2 تفاصيل محادثة — `getConversationDetail(conversationId)`
- **Method:** `GET`
- **Endpoint:** `/investor/messages/{id}`
- **Body:** لا يوجد

### 10.3 إنشاء محادثة جديدة — `createConversation()`
- **Method:** `POST`
- **Endpoint:** `/investor/messages`
- **Body:**
  ```json
  {
    "exhibition_id": "int",
    "exhibition_name": "string"
  }
  ```

### 10.4 إرسال رسالة — `sendMessage(conversationId, text)`
- **Method:** `POST`
- **Endpoint:** `/investor/messages/{id}/send`
- **Body:**
  ```json
  { "text": "string" }
  ```

---

## 11. رسائل الزوار (Visitor Messages) — `remote/VisitorMessages/`

### 11.1 جلب المحادثات — `getConversations()`
- **Method:** `GET`
- **Endpoint:** `/investor/visitor-messages`
- **Body:** لا يوجد

### 11.2 تفاصيل محادثة زائر — `getConversationDetail(conversationId)`
- **Method:** `GET`
- **Endpoint:** `/investor/visitor-messages/{id}`
- **Body:** لا يوجد

### 11.3 إرسال رسالة لزائر — `sendMessage(conversationId, text)`
- **Method:** `POST`
- **Endpoint:** `/investor/visitor-messages/{id}/send`
- **Body:**
  ```json
  { "text": "string" }
  ```

---

## 12. الإشعارات (Notifications) — `remote/Notifications/`

### 12.1 جلب الإشعارات — `getNotifications()`
- **Method:** `GET`
- **Endpoint:** `/investor/notifications`
- **Body:** لا يوجد

### 12.2 تعليم إشعار كمقروء — `markRead(notificationId)`
- **Method:** `PATCH`
- **Endpoint:** `/investor/notifications/{id}/read`
- **Body:** لا يوجد (`{}`)

### 12.3 تعليم كل الإشعارات كمقروءة — `markAllRead()`
- **Method:** `PATCH`
- **Endpoint:** `/investor/notifications/read-all`
- **Body:** لا يوجد (`{}`)

---

## 13. الملف الشخصي (Profile) — `remote/Profile/`

### 13.1 جلب بيانات الملف الشخصي — `getProfile()`
- **Method:** `GET`
- **Endpoint:** `/investor/profile`
- **Body:** لا يوجد

### 13.2 تحديث الملف الشخصي — `updateProfile()`
- **Method:** `PUT`
- **Endpoint:** `/investor/profile`
- **Body:**
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

## 14. التقارير (Reports) — `remote/Reports/`

### 14.1 جلب التقارير — `getReports()`
- **Method:** `GET`
- **Endpoint:** `/investor/reports`
- **Body:** لا يوجد

> ملاحظات:
> - `AppLink.reportDetail(id)` معرّف لكن غير مستخدم حالياً (تفاصيل التقرير تُعرض من بيانات القائمة نفسها).
> - `AppLink.reportDownload(id, format)` (`GET /investor/reports/{id}/download?format={fmt}`) لا يُستخدم عبر `Crud`/`remote` — يُستخدم مباشرة في `reports_controller.dart` لبناء رابط تحميل يُمرَّر إلى `DownloadService` (تنزيل ملف وليس نداء بيانات JSON عادي)، لذا تُرك خارج طبقة `remote` بشكل متعمد.

---

## 15. التحليلات (Analytics) — `remote/Analytics/`

### 15.1 بيانات التحليلات — `getAnalytics(period)`
- **Method:** `GET`
- **Endpoint:** `/investor/analytics`
- **Query Params:**
  ```json
  { "period": "string  // مثال: week, month, year" }
  ```
- **Body:** لا يوجد

---

## ملخص عام

| العدد | التصنيف |
|---|---|
| 6 | POST بدون body ذي محتوى (فقط `{}`) — تفعيل مفضلة، تسجيل خروج، إلخ |
| 9 | POST/PUT ببody يحمل بيانات فعلية |
| 4 | PATCH (بعضها ببيانات، بعضها بدون) |
| 4 | DELETE |
| ~17 | GET (بعضها بـ query params) |

**إجمالي عدد نداءات API الموثّقة: 34 نداء** موزعة على 15 ملف `remote`، بالإضافة إلى استخدامين خاصين خارج طبقة `remote` (رابط تنزيل التقرير، وتوكن FCM) موضّحين أعلاه لأسباب واضحة.
