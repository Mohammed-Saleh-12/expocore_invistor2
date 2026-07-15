## 1. المصادقة (Auth) — `remote/Auth/`

### 1.1 تسجيل الدخول —
- **Method:** `POST`
- **Endpoint:** `/auth/login`
- **Body:**
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```

### 1.2 إنشاء حساب — 
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

### 1.3 نسيت كلمة المرور —
- **Method:** `POST`
- **Endpoint:** `/auth/forgot-password`
- **Body:**
  ```json
  { "email": "string" }
  ```

### 1.4 إعادة تعيين كلمة المرور —
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

### 1.5 تسجيل الخروج —
- **Method:** `POST`
- **Endpoint:** `/auth/logout`
- **Body:** (`{}`)

### 1.7 توكن الإشعارات (FCM Token)
- **Method:** `POST`
- **Endpoint:**  `/auth/fcm-token`
- **Body:**
```json 
  {
  "fcm_token": "string"
  }

---

## 2. لوحة التحكم (Dashboard) —

### 2.1 بيانات لوحة التحكم —
- **Method:** `GET`
- **Endpoint:** `/investor/dashboard`
- **Query Params:**
  ```json
  { "period": "string  // مثال: week, month, year" }
  ```
- **Body:** لا يوجد

---

## 3. المعارض (Exhibitions) —

### 3.1 جلب كل المعارض —
- **Method:** `GET`
- **Endpoint:** `/exhibitions`
- **Body:** لا يوجد

### 3.2 إضافة معرض للمفضلة —
- **Method:** `POST`
- **Endpoint:** `/investor/favorites/exhibitions/{id}`
- **Body:** لا يوجد (`{}`)

### 3.3 إزالة معرض من المفضلة — 
- **Method:** `DELETE`
- **Endpoint:** `/investor/favorites/exhibitions/{id}`
- **Body:** لا يوجد
---

## 4. الأجنحة (Booths) — 

### 4.1 حجوزاتي —
- **Method:** `GET`
- **Endpoint:** `/investor/bookings`
- **Body:** لا يوجد

### 4.2 إضافة جناح للمفضلة — 
- **Method:** `POST`
- **Endpoint:** `/investor/favorites/booths/{id}`
- **Body:** لا يوجد (`{}`)

### 4.3 إزالة جناح من المفضلة —
- **Method:** `DELETE`
- **Endpoint:** `/investor/favorites/booths/{id}`
- **Body:** لا يوجد

> ملاحظة: `AppLink.booths` (`GET /booths`) و`AppLink.boothDetail(id)` معرّفان لكن غير مستخدمين حالياً في أي `remote` class.

---

## 5. ملف الجناح (Booth Profile) 

### 5.1 جلب ملف الجناح — `getBoothProfile(boothId)`
- **Method:** `GET`
- **Endpoint:** `/investor/booths/{boothId}/profile`
- **Body:** لا يوجد

### 5.2 تحديث ملف الجناح — 
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

### 5.3 فعاليات الجناح — 
- **Method:** `GET`
- **Endpoint:** `/investor/events`
- **Query Params:**
  ```json
  { "booth_id": "int" }
  ```
- **Body:** لا يوجد

---

## 6. الحجوزات (Booking) —

### 6.1 حجز جناح —
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

### 6.2 إلغاء حجز — 
- **Method:** `PATCH`
- **Endpoint:** `/investor/bookings/{id}/cancel`
- **Body:** لا يوجد (`{}`)

---

## 7. الحملات (Campaigns) — 

### 7.1 جلب الحملات — `getCampaigns()`
- **Method:** `GET`
- **Endpoint:** `/investor/campaigns`
- **Body:** لا يوجد

### 7.2 إنشاء حملة — 
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

### 7.3 حذف حملة — `
- **Method:** `DELETE`
- **Endpoint:** `/investor/campaigns/{id}`
- **Body:** لا يوجد

---

## 8. الفعاليات (Events) — 

### 8.1 فعالياتي — 
- **Method:** `GET`
- **Endpoint:** `/investor/events`
- **Body:** لا يوجد

### 8.2 إنشاء فعالية —
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

### 8.3 فعاليات الرعاية المتاحة — 
- **Method:** `GET`
- **Endpoint:** `/investor/sponsor-events`
- **Body:** لا يوجد

### 8.4 رعاياتي — 
- **Method:** `GET`
- **Endpoint:** `/investor/sponsorships`
- **Body:** لا يوجد

### 8.5 إنشاء رعاية — 
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

### 8.6 طلبات التذاكر لفعالية —
- **Method:** `GET`
- **Endpoint:** `/investor/events/{eventId}/ticket-requests`
- **Body:** لا يوجد

### 8.7 قبول/رفض طلب تذكرة — 
- **Method:** `PATCH`
- **Endpoint:** `/investor/events/{eventId}/ticket-requests/{requestId}`
- **Body:**
  ```json
  { "action": "string  // accept | reject" }
  ```

### 8.8 إضافة فعالية للمفضلة — 
- **Method:** `POST`
- **Endpoint:** `/investor/favorites/events/{id}`
- **Body:** لا يوجد (`{}`)

### 8.9 إزالة فعالية من المفضلة —
- **Method:** `DELETE`
- **Endpoint:** `/investor/favorites/events/{id}`
- **Body:** لا يوجد

---

## 9. المفضلة (Favorites) — 

### 9.1 جلب كل المفضلة — 
- **Method:** `GET`
- **Endpoint:** `/investor/favorites`
- **Body:** لا يوجد


---

## 12. الإشعارات (Notifications) — 

### 12.1 جلب الإشعارات —
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

## 13. الملف الشخصي (Profile) — 

### 13.1 جلب بيانات الملف الشخصي — 
- **Method:** `GET`
- **Endpoint:** `/investor/profile`
- **Body:** لا يوجد

### 13.2 تحديث الملف الشخصي —
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

## 14. التقارير (Reports) —

### 14.1 جلب التقارير — `getReports()`
- **Method:** `GET`
- **Endpoint:** `/investor/reports`
- **Body:** لا يوجد

---

## 15. التحليلات (Analytics) — 

### 15.1 بيانات التحليلات — 
- **Method:** `GET`
- **Endpoint:** `/investor/analytics`
- **Query Params:**
  ```json
  { "period": "string  // مثال: week, month, year" }
  ```
- **Body:** لا يوجد

---