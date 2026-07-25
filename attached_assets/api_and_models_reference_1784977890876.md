# ExpoCore Investor — API Requests & Models Reference

> **Base URL (حسب البيئة):**
> | البيئة | الـ URL |
> |---|---|
> | Dev (نشطة حالياً) | `https://api-dev.expocore.app/api/v1` |
> | Staging | `https://api-staging.expocore.app/api/v1` |
> | Prod | `https://api.expocore.app/api/v1` |
>
> لتغيير البيئة غيّر `_env` في `lib/core/constant/app_env.dart`.  
> **Auth:** كل طلب (ما عدا تسجيل الدخول / التسجيل) يحمل `Authorization: Bearer <token>` يُضاف تلقائياً في `Crud`.  
> **هيكل الرد الموحَّد:**
> ```json
> { "status": true|false, "message": "...", "data": { ... } }
> ```

---

## الفهرس

1. [طلبات المصادقة — Auth](#1-auth)
2. [لوحة التحكم — Dashboard](#2-dashboard)
3. [التحليلات — Analytics](#3-analytics)
4. [المعارض — Exhibitions](#4-exhibitions)
5. [الأجنحة — Booths](#5-booths)
6. [الحجز — Booking](#6-booking)
7. [ملف الجناح — Booth Profile](#7-booth-profile)
8. [الحملات — Campaigns](#8-campaigns)
9. [الفعاليات — Events](#9-events)
10. [التقارير — Reports](#10-reports)
11. [المفضلة — Favorites](#11-favorites)
12. [الملف الشخصي — Profile](#12-profile)
13. [الرسائل مع المعارض — Messages (Firebase)](#13-messages-firebase)
14. [الرسائل مع الزوار — Visitor Messages (Firebase)](#14-visitor-messages-firebase)
15. [الإشعارات — Notifications (Firebase)](#15-notifications-firebase)
16. [الموديلات — Models](#16-models)

---

## 1. Auth

### 1.1 تسجيل الدخول
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/login` |
| **الملف** | `LoginData.login()` |
| **الكنترولر** | `LoginController.login()` |
| **متى يُرسَل** | عند الضغط على زر "تسجيل الدخول" في صفحة Login |

**Body المرسَل:**
```json
{
  "email":    "string",
  "password": "string"
}
```

**الاستجابة المتوقعة (`data`):**
```json
{
  "token":        "string",
  "id":           1,
  "name":         "string",
  "email":        "string",
  "company_name": "string",
  "avatar_url":   "string"
}
```

---

### 1.2 تسجيل حساب جديد
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/register` |
| **الملف** | `RegisterData.register()` |
| **الكنترولر** | `RegisterController.register()` / `AuthController.register()` ← زر "إنشاء حساب" |

**Body المرسَل:**
```json
{
  "company_name":           "string",
  "trade_name":             "string",
  "email":                  "string",
  "location":               "string",
  "phone":                  "string",
  "website":                "string",
  "password":               "string",
  "password_confirmation":  "string",
  "activity_type":          "string"
}
```

**الاستجابة المتوقعة (`data`):** رسالة نجاح أو بيانات المستخدم (راجع UserModel).

---

### 1.3 التحقق من OTP بعد التسجيل
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/verify-otp` |
| **الملف** | `AuthData.verifyOtp()` |
| **الكنترولر** | `AuthController.verifyOtp()` ← زر "تأكيد" في صفحة OTP |

**Body المرسَل:**
```json
{ "otp": "string" }
```

---

### 1.4 إعادة إرسال OTP (تسجيل)
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/resend-otp` |
| **الملف** | `AuthData.resendOtp()` |
| **الكنترولر** | `AuthController.resendOtp()` ← رابط "إعادة الإرسال" |

**Body المرسَل:** `{}` (فارغ)

---

### 1.5 نسيان كلمة المرور — الخطوة 1: إرسال OTP
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/forgot-password` |
| **الملف** | `ForgotPasswordData.sendOtp()` |
| **الكنترولر** | `ForgotPasswordController.sendOtp()` ← زر "إرسال" |

**Body المرسَل:**
```json
{ "email": "string" }
```

---

### 1.6 نسيان كلمة المرور — الخطوة 2: التحقق من OTP
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/forgot-password/verify-otp` |
| **الملف** | `ForgotPasswordData.verifyOtp()` |
| **الكنترولر** | `ForgotPasswordController.verifyOtp()` ← زر "تأكيد" |

**Body المرسَل:**
```json
{ "email": "string", "otp": "string" }
```

---

### 1.7 نسيان كلمة المرور — الخطوة 3: تعيين كلمة مرور جديدة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/reset-password` |
| **الملف** | `ForgotPasswordData.resetPassword()` |
| **الكنترولر** | `ForgotPasswordController.resetPassword()` ← زر "تعيين" |

**Body المرسَل:**
```json
{
  "email":                 "string",
  "otp":                   "string",
  "password":              "string",
  "password_confirmation": "string"
}
```

---

### 1.8 إعادة إرسال OTP (نسيان كلمة المرور)
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/forgot-password/resend-otp` |
| **الملف** | `ForgotPasswordData.resendOtp()` |
| **الكنترولر** | `ForgotPasswordController.resendOtp()` ← رابط "إعادة الإرسال" |

**Body المرسَل:**
```json
{ "email": "string" }
```

---

### 1.9 تغيير كلمة المرور (داخل التطبيق)
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/change-password` |
| **الملف** | `ChangePasswordData.changePassword()` |
| **الكنترولر** | `ChangePasswordController.changePassword()` / `SettingsController.changePassword()` ← زر "تغيير" في الإعدادات |

**Body المرسَل:**
```json
{
  "current_password":          "string",
  "new_password":              "string",
  "new_password_confirmation": "string"
}
```

---

### 1.10 تسجيل الخروج
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/logout` |
| **الملف** | `LogoutData.logout()` |
| **الكنترولر** | `SettingsController.logout()` ← زر "تسجيل الخروج" |

**Body المرسَل:** `{}` (فارغ)

---

### 1.11 حذف الحساب
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/delete-account` |
| **الملف** | `DeleteAccountData.deleteAccount()` |
| **الكنترولر** | `SettingsController.deleteAccount()` ← زر "حذف الحساب" |

**Body المرسَل:** `{}` (فارغ)

---

### 1.12 تحديث FCM Token
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/fcm-token` |
| **الملف** | `AppLink.fcmToken` (يُستدعى من `fcmConfig`) |

> يُرسَل تلقائياً عند الحصول على FCM token جديد.

---

## 2. Dashboard

### 2.1 جلب بيانات لوحة التحكم
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/dashboard?period={period}` |
| **الملف** | `DashboardData.getDashboard()` |
| **الكنترولر** | `DashboardController._loadDashboard()` ← عند فتح شاشة الداشبورد |
| **أيضاً** | `DashboardController.changePeriod()` ← عند تغيير الفترة الزمنية (يوم/أسبوع/شهر) |

**Query Params:**
| المتغير | النوع | الوصف |
|---|---|---|
| `period` | `String` | `day` \| `week` \| `month` |

**الاستجابة المتوقعة (`data`):**
```json
{
  "total_visitors":     1234,
  "total_bookings":     56,
  "total_campaigns":    12,
  "total_revenue":      45000.0,
  "visitors_trend":     [120, 180, 250, 310, 400, 380, 420],
  "top_booths":         [ { "booth_number": "B12", "visitors": 320 } ]
}
```

---

## 3. Analytics

### 3.1 جلب بيانات التحليلات
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/analytics?period={period}` |
| **الملف** | `AnalyticsData.getAnalytics()` |
| **الكنترولر** | `AnalyticsController._loadAnalytics()` ← عند فتح صفحة التحليلات |
| **أيضاً** | `AnalyticsController.changePeriod()` ← عند تغيير الفترة |

**Query Params:**
| المتغير | النوع | الوصف |
|---|---|---|
| `period` | `String` | `day` \| `week` \| `month` |

**الاستجابة المتوقعة (`data`):**
```json
{
  "total_visitors":      4500,
  "total_scans":         1200,
  "avg_visit_duration":  "14 دقيقة",
  "conversion_rate":     32.5,
  "visitors_chart":      [120, 250, 380, 450, 520, 610, 700],
  "top_events":          [ { "name": "ورشة AI", "visitors": 420 } ],
  "engagement_by_hour":  { "09": 120, "10": 250 }
}
```

---

## 4. Exhibitions

### 4.1 جلب قائمة المعارض
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/exhibitions` |
| **الملف** | `ExhibitionsData.getExhibitions()` |
| **الكنترولر** | `ExhibitionsController.onInit()` ← عند فتح صفحة المعارض |
| **أيضاً** | `ExhibitionsController.applyFilter()` / `setSector()` / `setCity()` ← عند تغيير أي فلتر |

**Query Params (جميعها اختيارية):**
| المتغير | النوع | الوصف |
|---|---|---|
| `page` | `int` | رقم الصفحة (افتراضي: 1) |
| `per_page` | `int` | العناصر في الصفحة (افتراضي: 15) |
| `status` | `String?` | `upcoming` \| `active` \| `ended` |
| `city` | `String?` | اسم المدينة |
| `sector` | `String?` | القطاع |

**الاستجابة المتوقعة (`data`):** قائمة `List<ExhibitionModel>` — راجع [ExhibitionModel](#exhibitionmodel).

---

### 4.2 جلب تفاصيل معرض واحد
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/exhibitions/{id}` |
| **الملف** | `ExhibitionsData.getExhibitionDetail()` |
| **الكنترولر** | `ExhibitionDetailController.onInit()` ← عند فتح صفحة تفاصيل المعرض |

**الاستجابة المتوقعة (`data`):** `ExhibitionModel` — راجع [ExhibitionModel](#exhibitionmodel).

---

### 4.3 جلب خريطة المعرض ثلاثية الأبعاد
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/exhibitions/{id}/map` |
| **الملف** | `ExhibitionMapData.getExhibitionMap()` |
| **الكنترولر** | `BoothMapController.loadMap()` ← عند فتح صفحة الخريطة ثلاثية الأبعاد |

**الاستجابة المتوقعة (`data`):** `ExhibitionMapModel` — راجع [ExhibitionMapModel](#exhibitionmapmodel).

---

## 5. Booths

### 5.1 جلب أجنحتي (حجوزاتي)
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/bookings` |
| **الملف** | `BoothsData.getMyBookings()` |
| **الكنترولر** | `BoothController.onInit()` ← عند فتح صفحة "أجنحتي" |

**لا توجد Query Params.**

**الاستجابة المتوقعة (`data`):** قائمة `List<BoothModel>` (مع حقول الحجز) — راجع [BoothModel](#boothmodel).

---

### 5.2 جلب الأجنحة المتاحة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/booths` |
| **الملف** | `BoothsData.getAvailableBooths()` |
| **الكنترولر** | `BoothController` عند الحاجة لعرض الأجنحة المتاحة / فلترتها |

**Query Params (جميعها اختيارية):**
| المتغير | النوع | الوصف |
|---|---|---|
| `page` | `int` | رقم الصفحة (افتراضي: 1) |
| `per_page` | `int` | العناصر في الصفحة (افتراضي: 20) |
| `exhibition_id` | `int?` | فلتر بمعرض معين |
| `status` | `String?` | `available` \| `booked` \| ... |

**الاستجابة المتوقعة (`data`):** قائمة `List<BoothModel>` — راجع [BoothModel](#boothmodel).

---

### 5.3 جلب أجنحة معرض معين
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/booths?exhibition_id={id}&per_page=100` |
| **الملف** | `BoothsData.getExhibitionBooths()` |
| **الكنترولر** | `ExhibitionDetailController` ← عند فتح صفحة تفاصيل المعرض لعرض أجنحته |

**الاستجابة المتوقعة (`data`):** قائمة `List<BoothModel>` — راجع [BoothModel](#boothmodel).

---

### 5.4 جلب تفاصيل جناح واحد
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/booths/{id}` |
| **الملف** | `BoothsData.getBoothDetail()` |
| **الكنترولر** | `BoothDetailController.onInit()` ← عند الضغط على جناح في الخريطة أو القائمة |

**الاستجابة المتوقعة (`data`):** `BoothModel` — راجع [BoothModel](#boothmodel).

---

### 5.5 جلب تفاصيل حجز جناح
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/bookings/{id}` |
| **الملف** | `BoothsData.getBookingDetail()` / `BookingData.getBookingDetail()` |
| **الكنترولر** | `BoothController` / `BookingController` ← عند فتح صفحة تفاصيل الحجز |

**الاستجابة المتوقعة (`data`):** `BoothModel` (كامل مع حقول الحجز) — راجع [BoothModel](#boothmodel).

---

## 6. Booking

### 6.1 إنشاء حجز جديد
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/booths/book` |
| **الملف** | `BookingData.bookBooth()` |
| **الكنترولر** | `BookingController.bookBooth()` ← زر "تأكيد الحجز" في صفحة الحجز |

**Body المرسَل:**
```json
{
  "booth_id":    1,
  "start_date":  "YYYY-MM-DD",
  "end_date":    "YYYY-MM-DD",
  "notes":       "string",
  "services":    { "اسم الخدمة": true, "خدمة أخرى": false },
  "total_price": 16500.0
}
```

> `services` هو Map ديناميكي يحتوي اسم كل خدمة مع `true/false`، يُبنى من الخدمات المتاحة للجناح (`BoothModel.services`).

---

### 6.2 إلغاء حجز
| الخاصية | القيمة |
|---|---|
| **الميثود** | `PATCH` |
| **المسار** | `/investor/bookings/{id}/cancel` |
| **الملف** | `BookingData.cancelBooking()` |
| **الكنترولر** | `BookingController.cancelBooking()` ← زر "إلغاء الحجز" في صفحة تفاصيل الجناح |

**Body المرسَل:** `{}` (فارغ)

---

### 6.3 جلب تفاصيل حجز
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/bookings/{id}` |
| **الملف** | `BookingData.getBookingDetail()` |
| **الكنترولر** | `BookingController` ← عند الحاجة لتفاصيل حجز بعينه |

**الاستجابة المتوقعة (`data`):** `BoothModel` (مع حقول الحجز) — راجع [BoothModel](#boothmodel).

---

## 7. Booth Profile

### 7.1 جلب ملف جناح
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/booths/{boothId}/profile` |
| **الملف** | `BoothProfileData.getBoothProfile()` |
| **الكنترولر** | `BoothManagementController.loadBoothProfile()` ← عند فتح صفحة إدارة الجناح |

**الاستجابة المتوقعة (`data`):**
```json
{
  "company_nature":    "string",
  "services_products": "string",
  "headquarters":      "string",
  "social_links":      ["https://..."],
  "product_images":    ["https://..."],
  "booth_images":      ["https://..."]
}
```

---

### 7.2 تحديث ملف جناح
| الخاصية | القيمة |
|---|---|
| **الميثود** | `PUT` |
| **المسار** | `/investor/booths/{boothId}/profile` |
| **الملف** | `BoothProfileData.updateBoothProfile()` |
| **الكنترولر** | `BoothManagementController.saveProfile()` ← زر "حفظ" في صفحة تحرير ملف الجناح |

**Body المرسَل (JSON إذا لا توجد ملفات):**
```json
{
  "company_nature":    "string",
  "services_products": "string",
  "headquarters":      "string",
  "social_links":      ["https://..."],
  "product_images":    ["https://..."],
  "booth_images":      ["https://..."]
}
```

**Body المرسَل (Multipart إذا توجد ملفات):**
| الحقل | النوع | الوصف |
|---|---|---|
| `company_nature` | `String` | |
| `services_products` | `String` | |
| `headquarters` | `String` | |
| `social_links` | `String` (JSON encoded) | القوائم تُشفَّر كـ JSON string |
| `product_images` | `String` (JSON encoded) | روابط الصور الموجودة |
| `booth_images` | `String` (JSON encoded) | روابط صور الجناح الموجودة |
| `product_image_files[]` | `File` | ملفات صور المنتجات الجديدة |
| `booth_image_files[]` | `File` | ملفات صور الجناح الجديدة |
| `cover_image` | `File?` | صورة الغلاف (اختيارية) |

> ملاحظة: `_method: PUT` يُضاف تلقائياً في multipart لتجاوز قيود بعض الخوادم.

---

### 7.3 رفع صورة غلاف الجناح
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/investor/booths/{boothId}/cover` |
| **الملف** | `BoothProfileData.uploadBoothCover()` |
| **الكنترولر** | `BoothManagementController` ← عند تحديث صورة الغلاف منفردةً |

**Body المرسَل (Multipart):**
| الحقل | النوع |
|---|---|
| `cover_image` | `File` |

---

### 7.4 جلب فعاليات جناح
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/events?booth_id={boothId}` |
| **الملف** | `BoothProfileData.getBoothEvents()` |
| **الكنترولر** | `BoothManagementController.loadBoothEvents()` ← عند فتح تبويب "الفعاليات" في صفحة إدارة الجناح |

**Query Params:**
| المتغير | النوع | الوصف |
|---|---|---|
| `booth_id` | `int` | معرّف الجناح |

**الاستجابة المتوقعة (`data`):** قائمة `List<EventModel>` — راجع [EventModel](#eventmodel).

---

## 8. Campaigns

### 8.1 جلب قائمة الحملات
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/campaigns` |
| **الملف** | `CampaignsData.getCampaigns()` |
| **الكنترولر** | `CampaignsController.onInit()` ← عند فتح صفحة الحملات |

**لا توجد Query Params.**

**الاستجابة المتوقعة (`data`):** قائمة `List<CampaignModel>` — راجع [CampaignModel](#campaignmodel).

---

### 8.2 إنشاء حملة جديدة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/investor/campaigns` |
| **الملف** | `CampaignsData.createCampaign()` |
| **الكنترولر** | `CampaignsController.createCampaign()` ← زر "إنشاء حملة" في نموذج الحملة |

**Body المرسَل (JSON إذا لا توجد وسائط):**
```json
{
  "title":       "string",
  "description": "string",
  "type":        "string",
  "budget":      5000.0,
  "start_date":  "2026-07-15",
  "end_date":    "2026-07-20"
}
```

**Body المرسَل (Multipart إذا توجد وسائط):** نفس الحقول + `media[]` (ملفات وسائط اختيارية).

---

### 8.3 حذف حملة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `DELETE` |
| **المسار** | `/investor/campaigns/{id}` |
| **الملف** | `CampaignsData.deleteCampaign()` |
| **الكنترولر** | `CampaignsController.deleteCampaign()` ← زر "حذف" على بطاقة الحملة |

---

## 9. Events

### 9.1 جلب فعاليات المستثمر
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/events` |
| **الملف** | `EventsData.getInvestorEvents()` |
| **الكنترولر** | `EventsController.onInit()` ← عند فتح صفحة الفعاليات |

**لا توجد Query Params.**

**الاستجابة المتوقعة (`data`):** قائمة `List<EventModel>` — راجع [EventModel](#eventmodel).

---

### 9.2 إنشاء فعالية جديدة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/investor/events` |
| **الملف** | `EventsData.createInvestorEvent()` |
| **الكنترولر** | `EventsController.createEvent()` ← زر "إنشاء فعالية" في نموذج الفعالية |

**Body المرسَل (JSON إذا لا توجد صور):**
```json
{
  "name":                  "string",
  "type":                  "string",
  "booth_id":              1,
  "booth_number":          "B12",
  "exhibition_name":       "string",
  "start_date":            "2026-07-16",
  "end_date":              "2026-07-16",
  "time":                  "14:00",
  "max_participants":      50,
  "description":           "string",
  "requires_booking":      true,
  "has_bookable_seats":    true,
  "total_seats":           50,
  "ticket_price":          150.0,
  "is_general_invitation": false,
  "ticket_type":           "paid",
  "free_ticket_limit":     0,
  "video_promo_url":       "string"
}
```

> ⚠️ يُرسَل `start_date` و`end_date` بدلاً من `date` و`duration_days`.  
> **Multipart:** إذا أُرفقت صور تُضاف كـ `images[]`.

---

### 9.3 جلب الفعاليات الإعلانية (Sponsor Events)
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/sponsor-events` |
| **الملف** | `EventsData.getSponsorEvents()` |
| **الكنترولر** | `EventsController.onInit()` ← عند فتح تبويب "الفعاليات الإعلانية" |
| **أيضاً** | `EventsController.setSponsorType()` / `setSponsorDateStart()` / `setSponsorDateEnd()` ← عند تغيير أي فلتر |

**Query Params (جميعها اختيارية):**
| المتغير | النوع | الوصف |
|---|---|---|
| `page` | `int` | رقم الصفحة (افتراضي: 1) |
| `per_page` | `int` | العناصر في الصفحة (افتراضي: 15) |
| `type` | `String?` | نوع الفعالية |
| `date_start` | `String?` | فلتر من تاريخ (YYYY-MM-DD) |
| `date_end` | `String?` | فلتر إلى تاريخ (YYYY-MM-DD) |

**الاستجابة المتوقعة (`data`):** قائمة `List<ExhibitionSponsorEvent>` — راجع [ExhibitionSponsorEvent](#exhibitionsponsorevent).

---

### 9.4 جلب رعايات المستثمر
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/sponsorships` |
| **الملف** | `EventsData.getSponsorships()` |
| **الكنترولر** | `EventsController.onInit()` ← عند فتح تبويب "رعاياتي" |

**الاستجابة المتوقعة (`data`):** قائمة `List<SponsorshipBookingModel>` — راجع [SponsorshipBookingModel](#sponsorshipbookingmodel).

---

### 9.5 إنشاء رعاية جديدة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/investor/sponsorships` |
| **الملف** | `EventsData.createSponsorship()` |
| **الكنترولر** | `EventsController.createSponsorship()` ← زر "تأكيد الرعاية" في bottom sheet الرعاية |

**Body المرسَل (JSON إذا لا توجد ملفات):**
```json
{
  "event_id":                1,
  "selected_duration_label": "3 أيام",
  "selected_days":           3,
  "price":                   4500.0,
  "company_name":            "string",
  "company_website":         "https://...",
  "company_phone":           "0501234567",
  "product_names":           "string"
}
```

**Body المرسَل (Multipart إذا توجد ملفات):** نفس الحقول + الملفات الاختيارية:
| الحقل | الوصف |
|---|---|
| `logo` | شعار الشركة |
| `ad_images[]` | صور إعلانية |
| `poster_images[]` | ملصقات |
| `product_images[]` | صور المنتجات |

---

### 9.6 إلغاء رعاية
| الخاصية | القيمة |
|---|---|
| **الميثود** | `PATCH` |
| **المسار** | `/investor/sponsorships/{id}/cancel` |
| **الملف** | `EventsData.cancelSponsorship()` |
| **الكنترولر** | `EventsController.cancelSponsorship()` ← زر "إلغاء" في صفحة تفاصيل الرعاية |

**Body المرسَل:** `{}` (فارغ)

---

### 9.7 جلب طلبات تذاكر فعالية
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/events/{id}/ticket-requests` |
| **الملف** | `EventsData.getTicketRequests()` |
| **الكنترولر** | `EventsController.loadTicketRequests()` ← عند فتح صفحة إدارة التذاكر لفعالية معينة |

**الاستجابة المتوقعة (`data`):** قائمة `List<TicketRequestModel>` — راجع [TicketRequestModel](#ticketrequestmodel).

---

### 9.8 قبول / رفض طلب تذكرة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `PATCH` |
| **المسار** | `/investor/events/{eventId}/ticket-requests/{requestId}` |
| **الملف** | `EventsData.ticketRequestAction()` |
| **الكنترولر** | `EventsController.approveTicketRequest()` ← أزرار قبول/رفض في قائمة الطلبات |

**Body المرسَل:**
```json
{ "action": "approve" }
```
> القيم المتاحة: `approve` \| `reject`

---

## 10. Reports

### 10.1 جلب قائمة التقارير
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/reports` |
| **الملف** | `ReportsData.getReports()` |
| **الكنترولر** | `ReportsController.onInit()` ← عند فتح صفحة التقارير |

**لا توجد Query Params.**

**الاستجابة المتوقعة (`data`):** قائمة `List<ReportModel>` — راجع [ReportModel](#reportmodel).

---

### 10.2 جلب تفاصيل تقرير واحد
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/reports/{id}` |
| **الملف** | `ReportsData.getReportDetail()` |
| **الكنترولر** | `ReportsController` ← عند الضغط على تقرير لعرض تفاصيله |

**الاستجابة المتوقعة (`data`):** `ReportModel` — راجع [ReportModel](#reportmodel).

---

### 10.3 تنزيل تقرير
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` (رابط مباشر) |
| **المسار** | `/investor/reports/{id}/download?format={format}` |
| **الملف** | `ReportsData.getDownloadUrl()` — يُعيد URL كـ `String` مباشرةً (لا يستدعي API) |
| **الكنترولر** | `ReportsController` ← زر "تنزيل" → يُمرَّر لـ `DownloadService` |

**Query Params:**
| المتغير | النوع | الوصف |
|---|---|---|
| `format` | `String` | `pdf` \| `excel` \| `csv` |

---

## 11. Favorites

### 11.1 جلب المفضلة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/favorites` |
| **الملف** | `FavoritesData.getFavorites()` |
| **الكنترولر** | `FavoritesController.onInit()` ← عند فتح صفحة المفضلة |

**الاستجابة المتوقعة (`data`):**
```json
{
  "exhibitions": [ /* List<ExhibitionModel> */ ],
  "booths":      [ /* List<BoothModel> */ ],
  "events":      [ /* List<EventModel> */ ]
}
```

---

### 11.2 إضافة عنصر للمفضلة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/investor/favorites/{id}?type={type}` |
| **الملف** | `FavoritesData.addFavorite()` |
| **الكنترولر** | `ExhibitionsController.toggleFavorite()` / `BoothController.toggleFavorite()` / `EventsController.toggleSponsorFavorite()` ← الضغط على أيقونة القلب |

**Query Params:**
| المتغير | النوع | الوصف |
|---|---|---|
| `type` | `String` | `exhibition` \| `booth` \| `event` |

**Body المرسَل:** `{}` (فارغ)

---

### 11.3 حذف عنصر من المفضلة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `DELETE` |
| **المسار** | `/investor/favorites/{id}?type={type}` |
| **الملف** | `FavoritesData.removeFavorite()` |
| **الكنترولر** | نفس كنترولرات الإضافة ← الضغط على القلب مجدداً |

**Query Params:**
| المتغير | النوع | الوصف |
|---|---|---|
| `type` | `String` | `exhibition` \| `booth` \| `event` |

---

## 12. Profile

### 12.1 جلب الملف الشخصي
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/profile` |
| **الملف** | `ProfileData.getProfile()` |
| **الكنترولر** | `ProfileCompanyController.onInit()` ← عند فتح صفحة الملف الشخصي |

**الاستجابة المتوقعة (`data`):**
```json
{
  "id":           1,
  "name":         "string",
  "email":        "string",
  "company_name": "string",
  "avatar_url":   "string",
  "location":     "string",
  "phone":        "string",
  "website":      "string",
  "bio":          "string",
  "social": {
    "linkedin":  "string",
    "twitter":   "string",
    "instagram": "string",
    "facebook":  "string"
  }
}
```

---

### 12.2 تحديث الملف الشخصي
| الخاصية | القيمة |
|---|---|
| **الميثود** | `PUT` |
| **المسار** | `/investor/profile` |
| **الملف** | `ProfileData.updateProfile()` |
| **الكنترولر** | `ProfileCompanyController.saveProfile()` ← زر "حفظ" في صفحة تعديل الملف |

**Body المرسَل:**
```json
{
  "company_name": "string",
  "email":        "string",
  "location":     "string",
  "phone":        "string",
  "website":      "string",
  "bio":          "string",
  "social": {
    "linkedin":  "string",
    "twitter":   "string",
    "instagram": "string",
    "facebook":  "string"
  }
}
```

---

### 12.3 رفع الصورة الشخصية
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/investor/profile/avatar` |
| **الملف** | `ProfileData.uploadAvatar()` |
| **الكنترولر** | `ProfileCompanyController` ← عند اختيار صورة جديدة |

**Body المرسَل (Multipart):**
| الحقل | النوع |
|---|---|
| `avatar` | `File` |

---

## 13. Messages (Firebase)

> **Firestore Collection:** `conversations/{conversationId}`  
> **Sub-collection:** `conversations/{conversationId}/messages/{messageId}`

### 13.1 Stream محادثات المستثمر
| الخاصية | القيمة |
|---|---|
| **الميثود** | Firestore Stream |
| **المسار** | `conversations` where `investor_id == investorId` orderBy `last_time` desc |
| **الملف** | `MessagesFirebaseData.conversationsStream()` |
| **الكنترولر** | `MessagesController.onInit()` ← تلقائي عند فتح صفحة الرسائل |

**الحقول المقروءة من Firestore:**
| الحقل | النوع | الوصف |
|---|---|---|
| `id` | `int` (من doc.id) | معرّف المحادثة (يُحوَّل من String) |
| `investor_id` | `int` | معرّف المستثمر |
| `exhibition_id` | `int` | معرّف المعرض |
| `exhibition_name` | `String` | اسم المعرض |
| `exhibition_initials` | `String` | الأحرف الأولى |
| `color` | `String` (hex) | لون hex يُحوَّل لـ `int` |
| `unread_count` | `int` | عدد الرسائل غير المقروءة |
| `last_message` | `String` | آخر رسالة |
| `last_time` | `Timestamp` | وقت آخر رسالة |

---

### 13.2 Stream رسائل محادثة
| الخاصية | القيمة |
|---|---|
| **الملف** | `MessagesFirebaseData.messagesStream()` |
| **الكنترولر** | `MessagesController` ← عند فتح نافذة محادثة معينة |

**المسار:** `conversations/{conversationId}/messages` orderBy `time` asc

**الحقول المقروءة من Firestore:**
```
id, text, is_me, sender_id, time (Timestamp), is_read
```

---

### 13.3 إرسال رسالة
| الخاصية | القيمة |
|---|---|
| **الملف** | `MessagesFirebaseData.sendMessage()` |
| **الكنترولر** | `MessagesController.sendMessage()` ← زر إرسال في نافذة المحادثة |

**الحقول المكتوبة إلى Firestore (batch):**

رسالة جديدة في `conversations/{id}/messages/{auto-id}`:
```json
{
  "id":        "auto-doc-id",
  "text":      "string",
  "is_me":     true,
  "sender_id": 1,
  "time":      "ServerTimestamp",
  "is_read":   false
}
```

تحديث المحادثة في `conversations/{id}`:
```json
{
  "last_message": "string",
  "last_time":    "ServerTimestamp"
}
```

---

### 13.4 إنشاء محادثة جديدة مع معرض
| الخاصية | القيمة |
|---|---|
| **الملف** | `MessagesFirebaseData.createConversation()` |
| **الكنترولر** | `MessagesController` ← عند مراسلة معرض للمرة الأولى |

**الحقول المكتوبة إلى `conversations/{auto-id}`:**
```json
{
  "investor_id":         1,
  "exhibition_id":       1,
  "exhibition_name":     "string",
  "exhibition_initials": "string",
  "color":               "FF7A1FFF",
  "unread_count":        0,
  "last_message":        "",
  "last_time":           "ServerTimestamp"
}
```

---

### 13.5 تعليم المحادثة كمقروءة
| الخاصية | القيمة |
|---|---|
| **الملف** | `MessagesFirebaseData.markConversationRead()` |
| **الكنترولر** | `MessagesController` ← عند فتح المحادثة |

يُحدِّث `conversations/{id}.unread_count = 0`.

---

## 14. Visitor Messages (Firebase)

> **Firestore Collection:** `visitor_conversations/{conversationId}`  
> **Sub-collection:** `visitor_conversations/{conversationId}/messages/{messageId}`

### 14.1 Stream محادثات الزوار
| الخاصية | القيمة |
|---|---|
| **الملف** | `VisitorMessagesFirebaseData.conversationsStream()` |
| **الكنترولر** | `VisitorMessagesController.onInit()` ← عند فتح صفحة محادثات الزوار |

**المسار:** `visitor_conversations` where `investor_id == investorId` orderBy `last_time` desc

**الحقول المقروءة:**
| الحقل | النوع | الوصف |
|---|---|---|
| `id` | `int` (من doc.id) | يُحوَّل من String |
| `visitor_name` | `String` | اسم الزائر |
| `visitor_initials` | `String` | الأحرف الأولى |
| `color` | `String` (hex) | يُحوَّل لـ `int` |
| `unread_count` | `int` | عدد الرسائل غير المقروءة |
| `messages` | `List<MessageModel>` | الرسائل المدمجة |

> **getters محسوبة:** `lastMessage` و`lastTime` تُستخرجان من آخر عنصر في `messages`.

---

### 14.2 Stream رسائل محادثة زائر
| الخاصية | القيمة |
|---|---|
| **الملف** | `VisitorMessagesFirebaseData.messagesStream()` |
| **الكنترولر** | `VisitorMessagesController` ← عند فتح محادثة زائر معين |

**المسار:** `visitor_conversations/{conversationId}/messages` orderBy `time` asc

---

### 14.3 إرسال رسالة لزائر
| الخاصية | القيمة |
|---|---|
| **الملف** | `VisitorMessagesFirebaseData.sendMessage()` |
| **الكنترولر** | `VisitorMessagesController.sendMessage()` ← زر إرسال |

**الحقول المكتوبة (batch):**

رسالة في `visitor_conversations/{id}/messages/{auto-id}`:
```json
{
  "id":      "auto-doc-id",
  "text":    "string",
  "is_me":   true,
  "time":    "ServerTimestamp",
  "is_read": false
}
```

تحديث في `visitor_conversations/{id}`:
```json
{
  "last_message": "string",
  "last_time":    "ServerTimestamp"
}
```

---

### 14.4 تعليم محادثة زائر كمقروءة
| الخاصية | القيمة |
|---|---|
| **الملف** | `VisitorMessagesFirebaseData.markConversationRead()` |
| **الكنترولر** | `VisitorMessagesController` ← عند فتح المحادثة |

يُحدِّث `visitor_conversations/{id}.unread_count = 0`.

---

## 15. Notifications (Firebase)

> **Firestore Collection:** `notifications/{userId}/items/{notifId}`

### 15.1 Stream الإشعارات
| الخاصية | القيمة |
|---|---|
| **الملف** | `NotificationsFirebaseData.notificationsStream()` |
| **الكنترولر** | `NotificationsController.onInit()` ← عند فتح صفحة الإشعارات |

**المسار:** `notifications/{userId}/items` orderBy `time` desc

**الحقول المقروءة:**
```
id (doc.id → int), title, body|message, type, time|created_at, is_read, route?
```

---

### 15.2 تعليم إشعار كمقروء
| الخاصية | القيمة |
|---|---|
| **الملف** | `NotificationsFirebaseData.markRead()` |
| **الكنترولر** | `NotificationsController.markRead()` ← الضغط على إشعار |

يُحدِّث `notifications/{userId}/items/{notifId}.is_read = true`.

---

### 15.3 تعليم جميع الإشعارات كمقروءة
| الخاصية | القيمة |
|---|---|
| **الملف** | `NotificationsFirebaseData.markAllRead()` |
| **الكنترولر** | `NotificationsController.markAllRead()` ← زر "تعليم الكل كمقروء" |

يُحدِّث جميع الوثائق التي `is_read == false` باستخدام Firestore batch.

---

## 16. Models

---

### ApiResponse\<T\>
> غلاف الاستجابة الموحَّد — كل طلب REST يُعيد هذا الشكل.

| # | الحقل | النوع | JSON Key | الوصف |
|---|---|---|---|---|
| 1 | `success` | `bool` | `status` (true/false) | هل الطلب نجح |
| 2 | `data` | `T?` | `data` | البيانات الفعلية |
| 3 | `message` | `String` | `message` | رسالة الخادم |
| 4 | `statusCode` | `int` | `code` | كود HTTP |

**factory methods:** `ApiResponse.ok()`, `ApiResponse.fail()`, `ApiResponse.fromMap()`  
**getters:** `isUnauthorized` (401), `isNotFound` (404), `isServerError` (≥500)

---

### UserModel

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `int` | `id` |
| 2 | `name` | `String` | `name` |
| 3 | `email` | `String` | `email` |
| 4 | `token` | `String` | `token` |
| 5 | `companyName` | `String` | `company_name` |
| 6 | `avatarUrl` | `String` | `avatar_url` |

---

### BoothModel

| # | الحقل | النوع | JSON Key | ملاحظة |
|---|---|---|---|---|
| 1 | `id` | `int` | `id` | |
| 2 | `number` | `String` | `number` | رقم الجناح (B12) |
| 3 | `exhibitionName` | `String` | `exhibition_name` | |
| 4 | `imageUrl` | `String` | `image_url` | |
| 5 | `area` | `double` | `area` | المساحة م² |
| 6 | `status` | `String` | `status` | `available` \| `booked` \| `pending` \| `rejected` \| `ended` |
| 7 | `price` | `double` | `price` | سعر الجناح |
| 8 | `startDate` | `String` | `start_date` | تاريخ بدء الحجز |
| 9 | `endDate` | `String` | `end_date` | تاريخ انتهاء الحجز |
| 10 | `location` | `String` | `location` | الموقع داخل المعرض |
| 11 | `amenities` | `List<String>` | `amenities` | الحقوق الأساسية |
| 12 | `isFavorite` | `bool` | `is_favorite` | |
| 13 | `services` | `Map<String, double>` | `services` | خدمات الجناح الديناميكية (اسم الخدمة → سعرها) |
| 14 | `companyName` | `String?` | `company_name` | اسم الشركة الحاجزة (nullable) |
| 15 | `companyEmail` | `String?` | `company_email` | إيميل الشركة الحاجزة (nullable) |
| 16 | `companyInitials` | `String?` | `company_initials` | الأحرف الأولى للشركة (nullable) |
| — | **حقول الحجز** (تُملأ من `/investor/bookings`) | | | |
| 17 | `bookingId` | `int` | `booking_id` | معرّف الحجز |
| 18 | `bookingNumber` | `String` | `booking_number` | رقم الحجز (BK-2026-001) |
| 19 | `bookedAt` | `String` | `booked_at` | تاريخ إجراء الحجز |
| 20 | `durationDays` | `int` | `duration_days` | المدة بالأيام |
| 21 | `servicesPrice` | `double` | `services_price` | سعر الخدمات الإضافية |
| 22 | `totalPrice` | `double` | `total_price` | الإجمالي |
| 23 | `paidAmount` | `double` | `paid_amount` | المدفوع |
| 24 | `remainingAmount` | `double` | `remaining_amount` | المتبقي |
| 25 | `bookedServices` | `List<String>` | `booked_services` | أسماء الخدمات المحجوزة |
| 26 | `notes` | `String` | `notes` | ملاحظات الحجز |

> ⚠️ **الخدمات ديناميكية:** لا يوجد `screen_service` / `setup_service` / `security_service` / `cleaning_service` كحقول ثابتة. بدلاً منها `services: Map<String, double>` يأتي من API، ويُرسَل في الحجز كـ `services: Map<String, bool>`.

---

### CampaignModel

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `int` | `id` |
| 2 | `title` | `String` | `title` |
| 3 | `description` | `String` | `description` |
| 4 | `type` | `String` | `type` |
| 5 | `startDate` | `String` | `start_date` |
| 6 | `endDate` | `String` | `end_date` |
| 7 | `reach` | `int` | `reach` |
| 8 | `status` | `String` | `status` | `active` \| `ended` \| `pending` |
| 9 | `budget` | `double` | `budget` |
| 10 | `weeklyTrend` | `List<double>` | `weekly_trend` |

**`toJson()` يُرسَل عند الإنشاء:** `title, description, type, start_date, end_date, budget`

---

### ExhibitionModel

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `int` | `id` |
| 2 | `name` | `String` | `name` |
| 3 | `description` | `String` | `description` |
| 4 | `imageUrl` | `String` | `image_url` |
| 5 | `startDate` | `String` | `start_date` |
| 6 | `endDate` | `String` | `end_date` |
| 7 | `location` | `String` | `location` |
| 8 | `city` | `String` | `city` |
| 9 | `status` | `String` | `status` | `active` \| `upcoming` \| `ended` |
| 10 | `availableBooths` | `int` | `available_booths` |
| 11 | `sectors` | `List<String>` | `sectors` |
| 12 | `isFavorite` | `bool` | `is_favorite` |

---

### EventModel

| # | الحقل | النوع | JSON Key | ملاحظة |
|---|---|---|---|---|
| 1 | `id` | `int` | `id` | |
| 2 | `name` | `String` | `name` | |
| 3 | `type` | `String` | `type` | |
| 4 | `boothNumber` | `String` | `booth_number` | |
| 5 | `exhibitionName` | `String` | `exhibition_name` | |
| 6 | `date` | `String` | `date` | |
| 7 | `time` | `String` | `time` | |
| 8 | `maxParticipants` | `int` | `max_participants` | |
| 9 | `registeredCount` | `int` | `registered_count` | |
| 10 | `status` | `String` | `status` | `upcoming` \| `active` \| `ended` |
| 11 | `description` | `String` | `description` | |
| 12 | `requiresBooking` | `bool` | `requires_booking` | |
| 13 | `isFavorite` | `bool` | `is_favorite` | |
| 14 | `place` | `String` | `place` | |
| 15 | `durationDays` | `int` | `duration_days` | افتراضي: 1 |
| 16 | `hasBookableSeats` | `bool` | `has_bookable_seats` | |
| 17 | `totalSeats` | `int` | `total_seats` | |
| 18 | `bookedSeats` | `int` | `booked_seats` | |
| 19 | `soldTickets` | `int` | `sold_tickets` | |
| 20 | `ticketPrice` | `double` | `ticket_price` | |
| 21 | `isGeneralInvitation` | `bool` | `is_general_invitation` | افتراضي: true |
| 22 | `videoPromoUrl` | `String` | `video_promo_url` | |
| 23 | `companyImages` | `List<String>` | `company_images` | |
| 24 | `currentDay` | `int` | `current_day` | اليوم الحالي |
| 25 | `totalEventDays` | `int` | `total_event_days` | |
| 26 | `dailyAttendees` | `List<int>` | `daily_attendees` | |
| 27 | `scannedCount` | `int` | `scanned_count` | |

**getter محسوب:** `ticketCategory` → `'paid'` \| `'free'` \| `'none'`

---

### ExhibitionSponsorEvent

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `int` | `id` |
| 2 | `name` | `String` | `name` |
| 3 | `type` | `String` | `type` |
| 4 | `exhibitionId` | `int` | `exhibition_id` |
| 5 | `exhibitionName` | `String` | `exhibition_name` |
| 6 | `exhibitionImageUrl` | `String` | `exhibition_image_url` |
| 7 | `date` | `String` | `date` |
| 8 | `startTime` | `String` | `start_time` |
| 9 | `endTime` | `String` | `end_time` |
| 10 | `place` | `String` | `place` |
| 11 | `listingDays` | `int` | `listing_days` |
| 12 | `description` | `String` | `description` |
| 13 | `durationOptions` | `List<SponsorDurationOption>` | `duration_options` |
| 14 | `isFavorite` | `bool` | `is_favorite` |

#### SponsorDurationOption (nested)

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `label` | `String` | `label` |
| 2 | `days` | `int` | `days` |
| 3 | `price` | `double` | `price` |

---

### SponsorshipBookingModel

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `int` | `id` |
| 2 | `eventId` | `int` | `event_id` |
| 3 | `eventName` | `String` | `event_name` |
| 4 | `eventType` | `String` | `event_type` |
| 5 | `exhibitionName` | `String` | `exhibition_name` |
| 6 | `date` | `String` | `date` |
| 7 | `place` | `String` | `place` |
| 8 | `time` | `String` | `time` |
| 9 | `selectedDurationLabel` | `String` | `selected_duration_label` |
| 10 | `selectedDays` | `int` | `selected_days` |
| 11 | `price` | `double` | `price` |
| 12 | `status` | `String` | `status` | `pending` \| `approved` \| `confirmed` \| `active` \| `rejected` |
| 13 | `bookedAt` | `String` | `booked_at` |
| 14 | `totalVisitors` | `int` | `total_visitors` |
| 15 | `totalAttendees` | `int` | `total_attendees` |
| 16 | `dailyVisitors` | `List<int>` | `daily_visitors` |
| 17 | `currentDay` | `int` | `current_day` |
| 18 | `totalDays` | `int` | `total_days` |

**getter محسوب:** `statusLabel` → نص عربي حسب الحالة (`approved`/`confirmed`/`active` → "مقبول"، `pending` → "قيد المراجعة"، `rejected` → "مرفوض")

**`toJson()` يُرسَل عبر الموديل فقط:** `event_id, selected_duration_label, selected_days, price`  
> الحقول الإضافية (`company_name`, `company_website`, `company_phone`, `product_names`) تُرسَل مباشرةً من `EventsData.createSponsorship()`.

---

### TicketRequestModel

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `int` | `id` |
| 2 | `eventId` | `int` | `event_id` |
| 3 | `requesterName` | `String` | `requester_name` |
| 4 | `requesterPhone` | `String` | `requester_phone` |
| 5 | `requesterEmail` | `String` | `requester_email` |
| 6 | `requestedAt` | `String` | `requested_at` |
| 7 | `status` | `String` | `status` | `pending` \| `approved` \| `rejected` |
| 8 | `qrCodeData` | `String?` | `qr_code_data` | nullable |
| 9 | `ticketNumber` | `String?` | `ticket_number` | nullable |

---

### ReportModel

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `String` | `id` (toString) |
| 2 | `title` | `String` | `title` |
| 3 | `type` | `String` | `type` | `visitors` \| `revenue` \| ... |
| 4 | `description` | `String` | `description` |
| 5 | `period` | `String` | `period` |
| 6 | `boothName` | `String` | `booth_name` |
| 7 | `exhibitionName` | `String` | `exhibition_name` |
| 8 | `createdAt` | `String` | `created_at` |
| 9 | `mainValue` | `double` | `main_value` |
| 10 | `mainLabel` | `String` | `main_label` |
| 11 | `trend` | `double` | `trend` | نسبة التغير % |
| 12 | `sparklineData` | `List<double>` | `sparkline_data` |

---

### ExhibitionMapModel

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `exhibitionId` | `int` | `exhibition_id` |
| 2 | `exhibitionName` | `String` | `exhibition_name` |
| 3 | `gridWidth` | `int` | `grid_width` |
| 4 | `gridDepth` | `int` | `grid_depth` |
| 5 | `halls` | `List<MapHallModel>` | `halls` |

#### MapHallModel (nested)

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `String` | `id` |
| 2 | `name` | `String` | `name` |
| 3 | `colorHex` | `String` | `color` |
| 4 | `booths` | `List<MapBoothModel>` | `booths` |

#### MapBoothModel (nested)

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `int` | `id` |
| 2 | `number` | `String` | `number` |
| 3 | `col` | `int` | `col` |
| 4 | `row` | `int` | `row` |
| 5 | `gridWidth` | `int` | `width` |
| 6 | `gridDepth` | `int` | `depth` |
| 7 | `height` | `double` | `height` |
| 8 | `status` | `String` | `status` | `available` \| `booked` |
| 9 | `price` | `double` | `price` |
| 10 | `area` | `double` | `area` |
| 11 | `hallId` | `String` | *(يُمرَّر من الأب)* |
| 12 | `hallName` | `String` | *(يُمرَّر من الأب)* |
| 13 | `amenities` | `List<String>` | `amenities` |

---

### ConversationModel (Firebase)

| # | الحقل | النوع | Firestore Field |
|---|---|---|---|
| 1 | `id` | `int` | doc.id (يُحوَّل من String) |
| 2 | `exhibitionId` | `int` | `exhibition_id` |
| 3 | `exhibitionName` | `String` | `exhibition_name` |
| 4 | `exhibitionInitials` | `String` | `exhibition_initials` |
| 5 | `color` | `int` | `color` (hex string → int) |
| 6 | `messages` | `List<MessageModel>` | `messages[]` |
| 7 | `unreadCount` | `int` | `unread_count` |

---

### VisitorConversationModel (Firebase)

| # | الحقل | النوع | Firestore Field |
|---|---|---|---|
| 1 | `id` | `int` | doc.id (يُحوَّل من String) |
| 2 | `visitorName` | `String` | `visitor_name` |
| 3 | `visitorInitials` | `String` | `visitor_initials` |
| 4 | `color` | `int` | `color` (hex string → int) |
| 5 | `messages` | `List<MessageModel>` | `messages[]` |
| 6 | `unreadCount` | `int` | `unread_count` |

**getters محسوبة:** `lastMessage` و`lastTime` من آخر عنصر في `messages`.

---

### MessageModel (Firebase)

| # | الحقل | النوع | Firestore Field / JSON Key |
|---|---|---|---|
| 1 | `id` | `int` | `id` |
| 2 | `text` | `String` | `text` \| `body` |
| 3 | `isMe` | `bool` | `is_me` |
| 4 | `time` | `String` | `time` \| `created_at` |
| 5 | `isRead` | `bool` | `is_read` |

---

### NotificationModel (Firebase)

| # | الحقل | النوع | Firestore Field |
|---|---|---|---|
| 1 | `id` | `int` | doc.id (يُحوَّل من String) |
| 2 | `title` | `String` | `title` |
| 3 | `body` | `String` | `body` \| `message` |
| 4 | `type` | `String` | `type` |
| 5 | `time` | `String` | `time` \| `created_at` |
| 6 | `isRead` | `bool` | `is_read` |
| 7 | `route` | `String?` | `route` (nullable) |

---
