# ExpoCore Investor — API Requests & Models Reference

> **Base URLs:**`https://api.expocore.app/api/` |
>
> **Auth:** كل طلب (ما عدا تسجيل الدخول / التسجيل) يحمل `Authorization: Bearer <token>` يُضاف تلقائياً في `Crud`.  
> **هيكل الرد الموحَّد:**
> ```json
> { "status": true|false, "message": "...", "data": { ... } }
> ```

---

## الفهرس

1. [طلبات المصادقة — Auth](#1-auth)
2. [لوحة التحكم واللوحات الإعلانية — Dashboard & Home Billboard](#2-dashboard)
   - [2.1 اللوحة الإعلانية للمعارض المميّزة](#21-اللوحة-الإعلانية-للمعارض-المميّزة-home-billboard)
   - [2.2 اللوحة الإعلانية للفعاليات المميّزة](#22-اللوحة-الإعلانية-للفعاليات-الإعلانية-المميّزة-home-billboard)
   - [2.3 جلب بيانات لوحة التحكم](#23-جلب-بيانات-لوحة-التحكم)
   - [2.4 أحدث المعارض (ويب فقط)](#24-أحدث-المعارض-ويب-فقط)
3. [المعارض — Exhibitions](#3-exhibitions)
4. [الأجنحة — Booths](#4-booths)
5. [الحجز — Booking](#5-booking)
6. [ملف الجناح — Booth Profile](#6-booth-profile)
7. [الفعاليات — Events](#8-events)
8. [التقارير — Reports](#9-reports)
9. [المفضلة — Favorites](#10-favorites)
10. [الملف الشخصي — Profile](#11-profile)
11. [الرسائل مع المعارض — Messages (Firebase)](#12-messages-firebase)
12. [الرسائل مع الزوار — Visitor Messages (Firebase)](#13-visitor-messages-firebase)
13. [الإشعارات — Notifications (Firebase)](#14-notifications-firebase)
14. [الموديلات — Models](#15-models)

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
| **الكنترولر** | `RegisterController.register()` ← زر "إنشاء حساب" |

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
| **الكنترولر** | `ChangePasswordController.changePassword()` ← زر "تغيير" في الإعدادات |

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
| **الكنترولر** | `SettingsController` أو `ProfileCompanyController` ← زر "تسجيل الخروج" |

**Body المرسَل:** `{}` (فارغ)

---

### 1.11 حذف الحساب
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/delete-account` |
| **الملف** | `DeleteAccountData.deleteAccount()` |
| **الكنترولر** | `SettingsController` ← زر "حذف الحساب" |

**Body المرسَل:** `{}` (فارغ)

---

### 1.12 تسجيل FCM Token
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` |
| **المسار** | `/auth/fcm-token` |
| **الملف** | `AppLink.fcmToken` (يُستدعى مباشرةً عبر `Crud.postData`) |
| **متى يُرسَل** | بعد تسجيل الدخول الناجح لتسجيل token الإشعارات |

**Body المرسَل:**
```json
{ "fcm_token": "string" }
```

---

## 2. Dashboard

### 2.1 اللوحة الإعلانية للمعارض المميّزة (Home Billboard)

| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/exhibitions/featured` |
| **الملف** | `HomeBillboardData.getFeaturedExhibitions()` |
| **الكنترولر** | `HomeBillboardController._fetchExhibitions()` |
| **متى يُرسَل** | عند `onInit` — يجلب الصفحة 1 تلقائياً (5 عناصر) |
| **تحميل المزيد** | `HomeBillboardController.loadMoreExhibitions()` — يُستدعى عند الوصول للشريحة الأخيرة في الكاروسيل |

**Query Params:**

| المتغير | النوع | الوصف |
|---|---|---|
| `page` | `integer` | رقم الصفحة (يبدأ من 1) |
| `per_page` | `integer` | عدد العناصر في كل صفحة — ثابت عند **5** |

**الاستجابة المتوقعة (`data`):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "معرض التقنية 2026",
      "images": ["https://cdn.example.com/ex1.jpg"],
      "start_date": "2026-07-15",
      "end_date": "2026-07-20",
      "location": "مركز الرياض للمعارض",
      "city": "الرياض",
      "status": "upcoming",
      "available_booths": 45,
      "sectors": ["تقنية"]
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 5,
    "total": 14
  }
}
```

**الموديل المستخدم:** `ExhibitionModel`

**حالة الـ Controller:**

| المتغير | النوع | الوصف |
|---|---|---|
| `featuredExhibitions` | `RxList<ExhibitionModel>` | القائمة المتراكمة من كل الصفحات المحمَّلة |
| `isLoadingExhibitions` | `RxBool` | `true` أثناء تحميل الصفحة الأولى |
| `isLoadingMoreExhibitions` | `RxBool` | `true` أثناء تحميل الصفحات التالية |
| `hasMoreExhibitions` | `bool` | `true` إذا كانت هناك صفحات إضافية |

---

### 2.2 اللوحة الإعلانية للفعاليات الإعلانية المميّزة (Home Billboard)

| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/sponsor-events/featured` |
| **الملف** | `HomeBillboardData.getFeaturedSponsorEvents()` |
| **الكنترولر** | `HomeBillboardController._fetchSponsorEvents()` |
| **متى يُرسَل** | عند `onInit` — يجلب الصفحة 1 تلقائياً (5 عناصر) |
| **تحميل المزيد** | `HomeBillboardController.loadMoreSponsorEvents()` — يُستدعى عند الوصول للشريحة الأخيرة في الكاروسيل |

**Query Params:**

| المتغير | النوع | الوصف |
|---|---|---|
| `page` | `integer` | رقم الصفحة (يبدأ من 1) |
| `per_page` | `integer` | عدد العناصر في كل صفحة — ثابت عند **5** |

**الاستجابة المتوقعة (`data`):**
```json
{
  "data": [
    {
      "id": 10,
      "name": "حفل افتتاح معرض التقنية",
      "type": "حفل افتتاح",
      "exhibition_id": 1,
      "exhibition_name": "معرض التقنية 2026",
      "exhibition_image_url": "https://cdn.example.com/ex1.jpg",
      "date": "2026-07-15",
      "start_time": "10:00",
      "end_time": "13:00",
      "place": "القاعة الرئيسية",
      "listing_days": 3,
      "description": "فرصة إعلانية في حفل الافتتاح",
      "duration_options": [
        { "label": "يوم واحد", "days": 1, "price": 1500.0 },
        { "label": "3 أيام",   "days": 3, "price": 3500.0 }
      ],
      "is_favorite": false
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 2,
    "per_page": 5,
    "total": 9
  }
}
```

**الموديل المستخدم:** `ExhibitionSponsorEvent`

**حالة الـ Controller:**

| المتغير | النوع | الوصف |
|---|---|---|
| `featuredSponsorEvents` | `RxList<ExhibitionSponsorEvent>` | القائمة المتراكمة من كل الصفحات المحمَّلة |
| `isLoadingSponsorEvents` | `RxBool` | `true` أثناء تحميل الصفحة الأولى |
| `isLoadingMoreSponsorEvents` | `RxBool` | `true` أثناء تحميل الصفحات التالية |
| `hasMoreSponsorEvents` | `bool` | `true` إذا كانت هناك صفحات إضافية |

> **ملاحظة:** كلا الطلبين يُرسَلان بالتوازي (`Future.wait`) عند فتح الصفحة الرئيسية لأول مرة.  
> مبدأ تحميل المزيد: عندما يصل المستخدم للشريحة الأخيرة في الكاروسيل، يُستدعى `loadMore*` تلقائياً فتُضاف الصفحة التالية (5 عناصر) لنهاية القائمة.

---

### 2.3 جلب بيانات لوحة التحكم
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/dashboard?period={period}` |
| **الملف** | `DashboardData.getDashboard()` |
| **الكنترولر** | `DashboardController.onInit()` ← عند فتح شاشة الداشبورد |
| **أيضاً** | `DashboardController.changePeriod()` ← عند تغيير الفترة الزمنية (يوم/أسبوع/شهر) |

**Query Params:**
| المتغير | النوع | الوصف |
|---|---|---|
| `period` | `String` | `day` \| `week` \| `month` |

**الاستجابة المتوقعة (`data`):**
```json
{
  "total_bookings":12,
  "active_booths":3,
  "published_events":8,
  "total_engagement":24900
}
```

### 2.4 أحدث المعارض (ويب فقط)

| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/exhibitions/latest` |
| **الملف** | `LatestExhibitionsData.getLatestExhibitions()` — `lib/data/sourcedata/remote/Dashboard/latest_exhibitions_data.dart` |
| **الكنترولر** | `LatestExhibitionsController.fetchLatestExhibitions()` — `lib/controller/Home/latest_exhibitions_controller.dart` |
| **متى يُرسَل** | عند `onInit` — يجلب القائمة الكاملة دفعةً واحدة |
| **النطاق** | ويب فقط — مُسجَّل في `InitialBindings` داخل `if (GetPlatform.isWeb)` |

**Query Params:** لا يوجد — طلب بسيط بدون Pagination.

**الاستجابة المتوقعة (`data`):**
```json
[
  {
    "id": 5,
    "name": "معرض الغذاء والضيافة",
    "description": "معرض سنوي لقطاع الغذاء",
    "images": ["https://cdn.example.com/food-expo.jpg"],
    "services": ["واي فاي", "قاعات اجتماعات"],
    "start_date": "2026-08-01",
    "end_date": "2026-08-05",
    "location": "مركز المعارض الدولي",
    "city": "جدة",
    "status": "upcoming",
    "available_booths": 30,
    "sectors": ["غذاء", "ضيافة"],
    "is_favorite": false
  }
]
```

> يقبل الـ parser أيضاً هيكل `{ "data": [ ... ] }` — الـ controller يستخرج القائمة تلقائياً.

**الموديل المستخدم:** `ExhibitionModel`

**حالة الـ Controller:**

| المتغير | النوع | الوصف |
|---|---|---|
| `exhibitions` | `RxList<ExhibitionModel>` | قائمة أحدث المعارض |
| `isLoading` | `RxBool` | `true` أثناء الجلب |

**الاستخدام في الواجهة:**
```dart
// lib/web/view/pages/web_dashboard_page.dart
final latestExhib = Get.find<LatestExhibitionsController>();

Obx(() {
  final list = latestExhib.exhibitions.toList();
  // يُعرض في Wrap بعرض 280 لكل بطاقة
});
```

---

## 3. Exhibitions

### 3.1 جلب قائمة المعارض
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/exhibitions` |
| **الملف** | `ExhibitionsData.getExhibitions()` |
| **الكنترولر** | `ExhibitionsController.onInit()` ← عند فتح صفحة المعارض |
| **أيضاً** | `ExhibitionsController.applyFilter()` / `setSector()` / `setCity()` ← عند تغيير أي فلتر هيكلي (API call من page 1) |
| **أيضاً** | `ExhibitionsController.onSearch()` ← البحث النصي: فلترة محلية فورية + debounce 400ms → API call |

**Query Params (جميعها اختيارية):**
| المتغير | النوع | الوصف |
|---|---|---|
| `page` | `int` | رقم الصفحة (افتراضي: 1) |
| `per_page` | `int` | العناصر في الصفحة (افتراضي: 15) |
| `status` | `String?` | `upcoming` \| `active` \| `ended` |
| `city` | `String?` | اسم المدينة |
| `sector` | `String?` | القطاع |
| `search` | `String?` | بحث نصي في اسم المعرض والمدينة |

**الاستجابة المتوقعة (`data`):** قائمة `List<ExhibitionModel>` — راجع [ExhibitionModel](#exhibitionmodel).

---

### 3.2 جلب تفاصيل معرض واحد
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/exhibitions/{id}` |
| **الملف** | `ExhibitionsData.getExhibitionDetail()` |
| **الكنترولر** | `ExhibitionDetailController.onInit()` ← عند فتح صفحة تفاصيل المعرض (طلبان متوازيان: هذا + `getExhibitionBooths`) |

**الاستجابة المتوقعة (`data`):**
```json
{
  "id": 1,
  "name": "معرض التقنية 2026",
  "description": "string",
  "images": ["https://cdn.example.com/hero.jpg", "https://cdn.example.com/hall-a.jpg"],
  "services": ["واي فاي مجاني", "موقف سيارات", "أمن 24/7"],
  "start_date": "2026-07-15",
  "end_date": "2026-07-20",
  "location": "string",
  "city": "string",
  "status": "active",
  "available_booths": 12,
  "sectors": ["تقنية", "أعمال"],
  "is_favorite": false,
  "map_data": {
    "exhibition_id": 1,
    "grid_width": 13,
    "grid_depth": 10,
    "halls": [{ "id": "A", "name": "القاعة أ", "color": "7A1FFF", "booths": [...] }]
  },
  "sponsor_events": [{ "id": 10, "name": "فعالية إعلانية", "type": "banner" }]
}
```

> **ملاحظات:**
> - `images`: قائمة صور — `ExhibitionModel.imageUrl` getter يُعيد `images.first` للتوافق مع الكروت.
> - `services`: خدمات المعرض الأساسية (ليست خدمات الجناح).
> - `map_data`: بيانات الخريطة ثلاثية الأبعاد — تُحلَّل مباشرةً بدلاً من طلب `/exhibitions/{id}/map` منفصل.
> - `sponsor_events`: الفعاليات الإعلانية — لا يُستدعى `EventsController` لجلبها عند عرض تفاصيل المعرض.

---

## 4. Booths

### 4.1 جلب أجنحتي (حجوزاتي)
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/bookings` |
| **الملف** | `BoothsData.getMyBookings()` |
| **الكنترولر** | `BoothController.onInit()` ← عند فتح صفحة "أجنحتي" |
| **أيضاً** | `EventsController.onInit()` ← لجلب الأجنحة المرتبطة بالفعاليات |

**لا توجد Query Params.**

**الاستجابة المتوقعة (`data`):** قائمة `List<BoothModel>` (مع حقول الحجز) — راجع [BoothModel](#boothmodel).

---

### 4.2 جلب الأجنحة المتاحة
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

### 4.3 جلب أجنحة معرض بعينه
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/booths?exhibition_id={id}&per_page=100` |
| **الملف** | `BoothsData.getExhibitionBooths()` |
| **الكنترولر** | `ExhibitionDetailController.onInit()` ← طلب ثانٍ متوازٍ مع `getExhibitionDetail` عند فتح صفحة تفاصيل المعرض |

**Query Params:**
| المتغير | النوع | الوصف |
|---|---|---|
| `exhibition_id` | `int` | معرّف المعرض |
| `per_page` | `int` | ثابت: 100 |

**الاستجابة المتوقعة (`data`):** قائمة `List<BoothModel>` — كل جناح يحوي:
```json
{
  "data": [
    {
      "id": 1,
      "number": "A01",
      "status": "available",
      "price": 18000,
      "area": 400,
      "services": { "شاشة عرض إضافية": 500, "إضاءة مميزة": 300 }
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

> الناتج يُخزَّن في `ExhibitionDetailController.exhibitionBooths` ويُمرَّر لـ `BoothMapController.loadFromDetailData()` لربط أجنحة الخريطة ببياناتها الحقيقية.

---

### 4.4 جلب تفاصيل جناح واحد
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/booths/{id}` |
| **الملف** | `BoothsData.getBoothDetail()` |
| **الكنترولر** | `BoothDetailController.onInit()` ← عند الضغط على جناح في الخريطة أو القائمة |

**الاستجابة المتوقعة (`data`):** `BoothModel` — راجع [BoothModel](#boothmodel).

---

### 4.5 جلب تفاصيل حجز جناح
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/bookings/{id}` |
| **الملف** | `BoothsData.getBookingDetail()` |
| **الكنترولر** | `BoothController` / `BookingController` ← عند فتح صفحة تفاصيل الحجز |

**الاستجابة المتوقعة (`data`):** `BoothModel` (كامل مع حقول الحجز) — راجع [BoothModel](#boothmodel).

---

## 5. Booking

### 5.1 إنشاء حجز جديد
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
  "start_date":  "2026-08-01",
  "end_date":    "2026-08-05",
  "notes":       "string",
  "services":    { "اسم_الخدمة": true, "خدمة_أخرى": false },
  "total_price": 16500.0
}
```

> **ملاحظات:**
> - `duration_days` **مُحذوف** — يشتق الباك-إند المدة من `end_date - start_date`.
> - `start_date` / `end_date` بصيغة `YYYY-MM-DD`.
> - **وضع الحجز الكامل** ("حجز بالكامل"): تُؤخَذ `start_date` / `end_date` مباشرةً من `BoothModel.startDate` / `endDate` (نافذة الإتاحة).
> - **وضع الأيام المحددة** ("أيام محددة"): يختار المستثمر نطاقاً متتالياً عبر شبكة الأيام؛ النقرة الأولى = بداية، النقرة الثانية = نهاية، يوم واحد مسموح.
> - `services`: `Map<String,bool>` — مفاتيحه ديناميكية من `BoothModel.services` (Map<String,double>)؛ يُرسَل كل مفتاح بقيمة `true/false` حسب اختيار المستخدم. لا توجد حقول ثابتة (screen/setup/security/cleaning) بعد الآن.

---

### 5.2 إلغاء حجز
| الخاصية | القيمة |
|---|---|
| **الميثود** | `PATCH` |
| **المسار** | `/investor/bookings/{id}/cancel` |
| **الملف** | `BookingData.cancelBooking()` |
| **الكنترولر** | `BookingController.cancelBooking()` ← زر "إلغاء الحجز" في صفحة تفاصيل الجناح |

**Body المرسَل:** `{}` (فارغ)

---

### 5.3 جلب تفاصيل حجز
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/bookings/{id}` |
| **الملف** | `BookingData.getBookingDetail()` |
| **الكنترولر** | `BookingController` ← عند الحاجة لتفاصيل حجز بعينه |

**الاستجابة المتوقعة (`data`):** `BoothModel` (مع حقول الحجز) — راجع [BoothModel](#boothmodel).

---

## 6. Booth Profile

### 6.1 جلب ملف جناح
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

### 6.2 تحديث ملف جناح
| الخاصية | القيمة |
|---|---|
| **الميثود** | `PUT` (JSON) / `POST` + `_method=PUT` (multipart) |
| **المسار** | `/investor/booths/{boothId}/profile` |
| **الملف** | `BoothProfileData.updateBoothProfile()` |
| **الكنترولر** | `BoothManagementController.saveProfile()` ← زر "حفظ" في صفحة تحرير ملف الجناح |

**Body المرسَل (بدون ملفات — PUT JSON):**
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

**Body المرسَل (مع ملفات — multipart/form-data + `_method=PUT`):**
| الحقل | النوع | الوصف |
|---|---|---|
| `company_nature` | `String` | طبيعة الشركة |
| `services_products` | `String` | الخدمات والمنتجات |
| `headquarters` | `String` | المقر |
| `social_links` | `String` (JSON encoded) | `["https://..."]` |
| `product_images` | `String` (JSON encoded) | روابط الصور الموجودة |
| `booth_images` | `String` (JSON encoded) | روابط صور الجناح الموجودة |
| `product_image_files[]` | `File[]` | ملفات صور المنتجات الجديدة |
| `booth_image_files[]` | `File[]` | ملفات صور الجناح الجديدة |
| `cover_image` | `File?` | صورة غلاف الجناح (اختيارية) |

---

### 6.3 رفع صورة غلاف الجناح منفردةً
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` (multipart) |
| **المسار** | `/investor/booths/{boothId}/cover` |
| **الملف** | `BoothProfileData.uploadBoothCover()` |
| **الكنترولر** | `BoothManagementController` ← عند اختيار صورة غلاف جديدة للجناح |

**Body المرسَل (multipart/form-data):**
| الحقل | النوع | الوصف |
|---|---|---|
| `cover_image` | `File` | ملف الصورة |

---

### 6.4 جلب فعاليات جناح
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

## 8. Events

### 8.1 جلب فعاليات المستثمر
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/events` |
| **الملف** | `EventsData.getInvestorEvents()` |
| **الكنترولر** | `EventsController.onInit()` ← عند فتح صفحة الفعاليات |

**لا توجد Query Params.**

**الاستجابة المتوقعة (`data`):** قائمة `List<EventModel>` — راجع [EventModel](#eventmodel).

---

### 8.2 إنشاء فعالية جديدة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` (JSON) / `POST` multipart (مع صور) |
| **المسار** | `/investor/events` |
| **الملف** | `EventsData.createInvestorEvent()` |
| **الكنترولر** | `EventsController.createEvent()` ← زر "إنشاء فعالية" في نموذج الفعالية |

**Body المرسَل (بدون صور — JSON):**
```json
{
  "name":                  "string",
  "type":                  "string",
  "booth_id":              1,
  "booth_number":          "B12",
  "exhibition_name":       "string",
  "start_date":            "2026-07-16",
  "end_date":              "2026-07-17",
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

> **ملاحظات:**
> - يُرسَل `start_date` و`end_date` بدلاً من `date` و`duration_days`.
> - فعالية يوم واحد: `start_date == end_date`.
> - **منتقيا التاريخ مقيَّدان** بنافذة حجز الجناح المختار (`BoothModel.startDate` → `BoothModel.endDate`)؛ لا يمكن اختيار تاريخ خارجها.
> - التحقق قبل الإرسال: `start_date` ≥ `booth.startDate` و`end_date` ≤ `booth.endDate` و`end_date` ≥ `start_date`.

**Body المرسَل (مع صور — multipart/form-data):**
> نفس الحقول أعلاه + حقل إضافي:

| الحقل | النوع | الوصف |
|---|---|---|
| `images[]` | `File[]` | صور ترويجية للفعالية |

---

### 8.3 جلب الفعاليات الإعلانية (Sponsor Events)
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/sponsor-events` |
| **الملف** | `EventsData.getSponsorEvents()` |
| **الكنترولر** | `EventsController.onInit()` ← عند فتح تبويب "الفعاليات الإعلانية" |
| **أيضاً** | `EventsController.setSponsorType()` / `setSponsorDateStart()` / `setSponsorDateEnd()` ← API call من page 1 عند تغيير أي فلتر هيكلي |
| **أيضاً** | `EventsController.onSponsorSearch()` ← فلترة محلية فورية (السعر) + debounce 400ms → API call |
| **أيضاً** | `EventsController.clearSponsorFilters()` ← يُعيد ضبط جميع الفلاتر ويستدعي API |

**Query Params (جميعها اختيارية):**
| المتغير | النوع | الوصف |
|---|---|---|
| `page` | `int` | رقم الصفحة (افتراضي: 1) |
| `per_page` | `int` | العناصر في الصفحة (افتراضي: 20) |
| `type` | `String?` | نوع الفعالية |
| `date_start` | `String?` | فلتر من تاريخ (YYYY-MM-DD) |
| `date_end` | `String?` | فلتر إلى تاريخ (YYYY-MM-DD) |
| `search` | `String?` | بحث نصي في اسم الفعالية أو المعرض |

**الاستجابة المتوقعة (`data`):** قائمة `List<ExhibitionSponsorEvent>` — راجع [ExhibitionSponsorEvent](#exhibitionsponsorevent).

> **ملاحظة — منطق الفلترة:**
> - **API-side:** `type` + `date_start` / `date_end` + `search` — تُرسَل مع كل طلب.
> - **محلي فقط:** فلترة السعر (`sponsorPriceRange`) تطبَّق على النتائج المُعادة عبر getter `filteredSponsorEvents` في `EventsController` — لا تُرسَل للـ API.
> - **`setSponsorPriceRange()`** يُحدّث العرض المحلي فوراً دون API call.

---

### 8.4 جلب رعايات المستثمر
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/sponsorships` |
| **الملف** | `EventsData.getSponsorships()` |
| **الكنترولر** | `EventsController.onInit()` ← عند فتح تبويب "رعاياتي" |

**الاستجابة المتوقعة (`data`):** قائمة `List<SponsorshipBookingModel>` — راجع [SponsorshipBookingModel](#sponsorshipbookingmodel).

---

### 8.5 إنشاء رعاية جديدة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` (JSON) / `POST` multipart (مع وسائط) |
| **المسار** | `/investor/sponsorships` |
| **الملف** | `EventsData.createSponsorship()` |
| **الكنترولر** | `EventsController.createSponsorship()` ← زر "تأكيد الرعاية" في bottom sheet الرعاية |

**Body المرسَل (بدون ملفات — JSON):**
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

**Body المرسَل (مع ملفات — multipart/form-data):**
> نفس الحقول أعلاه + حقول إضافية:

| الحقل | النوع | الوصف |
|---|---|---|
| `logo` | `File?` | شعار الشركة |
| `ad_images[]` | `File[]` | الصور الإعلانية |
| `poster_images[]` | `File[]` | الملصقات الترويجية |
| `product_images[]` | `File[]` | صور المنتجات |

> يُرسَل multipart فقط إذا كانت هناك ملفات مرفقة — وإلا يُرسَل JSON عادي.

---

### 8.6 إلغاء رعاية
| الخاصية | القيمة |
|---|---|
| **الميثود** | `PATCH` |
| **المسار** | `/investor/sponsorships/{id}/cancel` |
| **الملف** | `EventsData.cancelSponsorship()` |
| **الكنترولر** | `EventsController.cancelSponsorship()` ← زر "إلغاء" في صفحة تفاصيل الرعاية |

**Body المرسَل:** `{}` (فارغ)

---

### 8.7 جلب طلبات تذاكر فعالية
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/events/{id}/ticket-requests` |
| **الملف** | `EventsData.getTicketRequests()` |
| **الكنترولر** | `EventsController.loadTicketRequests()` ← عند فتح صفحة إدارة التذاكر لفعالية معينة |

**الاستجابة المتوقعة (`data`):** قائمة `List<TicketRequestModel>` — راجع [TicketRequestModel](#ticketrequestmodel).

---

### 8.8 قبول / رفض طلب تذكرة
| الخاصية | القيمة |
|---|---|
| **الميثود** | `PATCH` |
| **المسار** | `/investor/events/{eventId}/ticket-requests/{requestId}` |
| **الملف** | `EventsData.ticketRequestAction()` |
| **الكنترولر** | `EventsController.approveTicket()` / `rejectTicket()` ← أزرار قبول/رفض في قائمة الطلبات |

**Body المرسَل:**
```json
{ "action": "approve" }
```
> القيم المتاحة: `approve` \| `reject`

---

## 9. Reports

### 10.1 جلب قائمة التقارير
| الخاصية | القيمة |
|---|---|
| **الميثود** | `GET` |
| **المسار** | `/investor/reports` |
| **الملف** | `ReportsData.getReports()` — `lib/data/sourcedata/remote/Reports/ReportsData.dart` |
| **الكنترولر** | `ReportsController._loadReports()` ← عند `onInit` وعند `refresh()` |

**لا توجد Query Params** — الفلترة تحدث كلياً على الكلايانت بعد جلب القائمة الكاملة.

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

> **ملاحظة:** في التطبيق الحالي، صفحة التفاصيل (`ReportDetailView`) تستقبل `ReportModel` كاملاً عبر `Get.arguments` مباشرةً من القائمة — طلب 10.2 متاح لكنه غير مستخدم حتى الآن (المودل مكتمل من طلب 10.1).

---

### 10.3 تنزيل تقرير
| الخاصية | القيمة |
|---|---|
| **المسار** | `/investor/reports/{id}/download?format={format}` |
| **الملف** | `ReportsData.getDownloadUrl()` — يُعيد URL كـ String |
| **الكنترولر** | `ReportsController.downloadReport(id, format)` |

**Query Params:**
| المتغير | النوع | الوصف |
|---|---|---|
| `format` | `String` | `pdf` \| `excel` |

> **⚠️ ملاحظة مهمة — تقسيم المسؤولية بين الكلايانت والباك-اند:**
>
> | الصيغة | من يولّدها؟ | الآلية |
> |---|---|---|
> | **PDF** | **الفرونت-اند** | `PdfExportService.printReport()` يبني HTML+SVG ويفتح نافذة طباعة المتصفح — **لا يُرسَل طلب للباك-اند** |
> | **Excel** | **الباك-اند** | `DownloadService.downloadUrl()` يفتح رابط `/download?format=excel` مباشرةً لتنزيله |

---

## 10. Favorites

### 10.1 جلب المفضلة
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

### 10.2 إضافة عنصر للمفضلة
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

### 10.3 حذف عنصر من المفضلة
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

## 11. Profile

### 11.1 جلب الملف الشخصي
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

### 11.2 تحديث الملف الشخصي
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

### 11.3 رفع صورة الملف الشخصي (Avatar)
| الخاصية | القيمة |
|---|---|
| **الميثود** | `POST` (multipart) |
| **المسار** | `/investor/profile/avatar` |
| **الملف** | `ProfileData.uploadAvatar()` |
| **الكنترولر** | `ProfileCompanyController` ← عند اختيار صورة شخصية جديدة |

**Body المرسَل (multipart/form-data):**
| الحقل | النوع | الوصف |
|---|---|---|
| `avatar` | `File` | ملف الصورة الشخصية (jpg / png / webp) |

> `Crud.uploadData()` يدعم multipart على الويب والجوال عبر `http.MultipartRequest`.

---

## 12. Messages (Firebase)

> **Firestore Collection:** `conversations/{conversationId}`  
> **Sub-collection:** `conversations/{conversationId}/messages/{messageId}`

### 12.1 Stream محادثات المستثمر
| الخاصية | القيمة |
|---|---|
| **الميثود** | Firestore Stream |
| **المسار** | `conversations` where `investor_id == userId` orderBy `last_time` desc |
| **الملف** | `MessagesFirebaseData.conversationsStream()` |
| **الكنترولر** | `MessagesController.onInit()` ← تلقائي عند فتح صفحة الرسائل |

**الحقول المقروءة من Firestore:**
| الحقل | النوع | الوصف |
|---|---|---|
| `id` | `String` (doc ID → `int`) | معرّف المحادثة — يُحوَّل لـ `int` عبر `_toInt()` (int.tryParse أو hashCode) |
| `investor_id` | `int` | معرّف المستثمر |
| `exhibition_id` | `int` | معرّف المعرض |
| `exhibition_name` | `String` | اسم المعرض |
| `exhibition_initials` | `String` | الأحرف الأولى |
| `color` | `String` (hex) | لون hex (مثال: `FF7A1FFF`) — يُحوَّل لـ `int` |
| `unread_count` | `int` | عدد الرسائل غير المقروءة |
| `last_message` | `String` | آخر رسالة |
| `last_time` | `Timestamp` | وقت آخر رسالة |

---

### 12.2 Stream رسائل محادثة
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

### 12.3 إرسال رسالة
| الخاصية | القيمة |
|---|---|
| **الملف** | `MessagesFirebaseData.sendMessage()` |
| **الكنترولر** | `MessagesController.sendMessage()` ← زر إرسال في نافذة المحادثة |

**الحقول المكتوبة إلى Firestore (batch write):**

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

تحديث المحادثة في `conversations/{id}` (ضمن نفس الـ batch):
```json
{
  "last_message": "string",
  "last_time":    "ServerTimestamp"
}
```

---

### 12.4 إنشاء محادثة جديدة مع معرض
| الخاصية | القيمة |
|---|---|
| **الملف** | `MessagesFirebaseData.createConversation()` |
| **الكنترولر** | `MessagesController` ← عند مراسلة معرض للمرة الأولى |

**الحقول المكتوبة إلى `conversations/{auto-id}`:**
```json
{
  "investor_id":         1,
  "exhibition_id":       5,
  "exhibition_name":     "string",
  "exhibition_initials": "string",
  "color":               "FF7A1FFF",
  "unread_count":        0,
  "last_message":        "",
  "last_time":           "ServerTimestamp"
}
```

---

### 12.5 تعليم المحادثة كمقروءة
| الخاصية | القيمة |
|---|---|
| **الملف** | `MessagesFirebaseData.markConversationRead()` |
| **الكنترولر** | `MessagesController` ← عند فتح المحادثة |

> يُعيِّن `unread_count = 0` في وثيقة المحادثة.

---

## 13. Visitor Messages (Firebase)

> **Firestore Collection:** `visitor_conversations/{conversationId}`  
> **Sub-collection:** `visitor_conversations/{conversationId}/messages/{messageId}`

### 13.1 Stream محادثات الزوار
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

### 13.2 Stream رسائل محادثة زائر
| الخاصية | القيمة |
|---|---|
| **الملف** | `VisitorMessagesFirebaseData.messagesStream()` |
| **الكنترولر** | `VisitorMessagesController` ← عند فتح محادثة زائر معين |

**المسار:** `visitor_conversations/{conversationId}/messages` orderBy `time` asc

---

### 13.3 إرسال رسالة لزائر
| الخاصية | القيمة |
|---|---|
| **الملف** | `VisitorMessagesFirebaseData.sendMessage()` |
| **الكنترولر** | `VisitorMessagesController.sendMessage()` ← زر إرسال |

**الحقول المكتوبة (batch write):**

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

### 13.4 تعليم محادثة زائر كمقروءة
| الخاصية | القيمة |
|---|---|
| **الملف** | `VisitorMessagesFirebaseData.markConversationRead()` |
| **الكنترولر** | `VisitorMessagesController` ← عند فتح المحادثة |

> يُعيِّن `unread_count = 0` في وثيقة المحادثة.

---

## 14. Notifications (Firebase)

> **Firestore Collection:** `notifications/{userId}/items/{notifId}`

### 14.1 Stream الإشعارات
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

### 14.2 تعليم إشعار كمقروء
| الخاصية | القيمة |
|---|---|
| **الملف** | `NotificationsFirebaseData.markRead()` |
| **الكنترولر** | `NotificationsController.markRead()` ← الضغط على إشعار |

> يُحدِّث `notifications/{userId}/items/{notifId}.is_read = true`.

---

### 14.3 تعليم جميع الإشعارات كمقروءة
| الخاصية | القيمة |
|---|---|
| **الملف** | `NotificationsFirebaseData.markAllRead()` |
| **الكنترولر** | `NotificationsController.markAllRead()` ← زر "تعليم الكل كمقروء" |

> يُحدِّث جميع الوثائق التي `is_read == false` باستخدام Firestore batch write.

---

## 15. Models

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

**Getters مساعدة:**
- `isUnauthorized` → `statusCode == 401`
- `isNotFound` → `statusCode == 404`
- `isServerError` → `statusCode >= 500`

---

### UserModel

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `int` | `id` |
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
| 7 | `price` | `double` | `price` | سعر الجناح (لليوم الواحد) |
| 8 | `startDate` | `String` | `start_date` | بداية نافذة الإتاحة / الحجز |
| 9 | `endDate` | `String` | `end_date` | نهاية نافذة الإتاحة / الحجز |
| 10 | `location` | `String` | `location` | الموقع داخل المعرض |
| 11 | `amenities` | `List<String>` | `amenities` | الحقوق الأساسية |
| 12 | `isFavorite` | `bool` | `is_favorite` | |
| 13 | `services` | `Map<String,double>` | `services` | الخدمات الإضافية المتاحة: اسم الخدمة → سعرها — ديناميكي من الـ API |
| — | **حقول الشركة المستأجرة** (تُملأ حين يكون الجناح محجوزاً) | | | |
| 14 | `companyName` | `String?` | `company_name` | اسم شركة المستأجر |
| 15 | `companyEmail` | `String?` | `company_email` | بريد شركة المستأجر |
| 16 | `companyInitials` | `String?` | `company_initials` | اختصار اسم الشركة |
| — | **حقول الحجز** (تُملأ من `/investor/bookings`) | | | |
| 17 | `bookingId` | `int` | `booking_id` | معرّف الحجز |
| 18 | `bookingNumber` | `String` | `booking_number` | رقم الحجز (BK-2026-001) |
| 19 | `bookedAt` | `String` | `booked_at` | تاريخ إجراء الحجز |
| 20 | `durationDays` | `int` | `duration_days` | المدة بالأيام (للقراءة فقط من الـ API — لا يُرسَل في الطلبات) |
| 21 | `servicesPrice` | `double` | `services_price` | سعر الخدمات الإضافية |
| 22 | `totalPrice` | `double` | `total_price` | الإجمالي |
| 23 | `paidAmount` | `double` | `paid_amount` | المدفوع |
| 24 | `remainingAmount` | `double` | `remaining_amount` | المتبقي |
| 25 | `bookedServices` | `List<String>` | `booked_services` | أسماء الخدمات المحجوزة |
| 26 | `notes` | `String` | `notes` | ملاحظات الحجز |

> ⚠️ **الخدمات الثابتة المُحذوفة:** `screenService` / `setupService` / `securityService` / `cleaningService` — استُبدلت بـ `services: Map<String,double>` الديناميكية.  
> `startDate` / `endDate` تؤدي دوراً مزدوجاً: نافذة الإتاحة للأجنحة المتاحة، ونافذة الحجز للأجنحة المحجوزة (من `/investor/bookings`).

---

### ExhibitionModel

| # | الحقل | النوع | JSON Key | ملاحظة |
|---|---|---|---|---|
| 1 | `id` | `int` | `id` | |
| 2 | `name` | `String` | `name` | |
| 3 | `description` | `String` | `description` | |
| 4 | `images` | `List<String>` | `images` | قائمة روابط الصور — يقبل أيضاً `image_url` (string قديم) ويحوّله لقائمة |
| 5 | `services` | `List<String>` | `services` | خدمات المعرض المتاحة (واي فاي، موقف، ...) |
| 6 | `mapJson` | `Map<String,dynamic>?` | `map_data` | بيانات الخريطة 3D المضمَّنة في رد التفاصيل |
| 7 | `sponsorEvents` | `List<ExhibitionSponsorEvent>` | `sponsor_events` | الفعاليات الإعلانية المضمَّنة في رد التفاصيل |
| 8 | `startDate` | `String` | `start_date` | |
| 9 | `endDate` | `String` | `end_date` | |
| 10 | `location` | `String` | `location` | |
| 11 | `city` | `String` | `city` | |
| 12 | `status` | `String` | `status` | `active` \| `upcoming` \| `ended` |
| 13 | `availableBooths` | `int` | `available_booths` | |
| 14 | `sectors` | `List<String>` | `sectors` | |
| 15 | `isFavorite` | `bool` | `is_favorite` | |

**Getters محسوبة:**
- `imageUrl` → أول عنصر في `images` أو `''` — للتوافق مع الكود القديم دون تعديله
- `statusLabel` → نص عربي: `active` → `'جارٍ'` \| `upcoming` → `'قادم'` \| غير ذلك → `'منتهٍ'`

---

### EventModel

| # | الحقل | النوع | JSON Key | ملاحظة |
|---|---|---|---|---|
| 1 | `id` | `int` | `id` | |
| 2 | `name` | `String` | `name` | |
| 3 | `type` | `String` | `type` | |
| 4 | `boothNumber` | `String` | `booth_number` | |
| 5 | `exhibitionName` | `String` | `exhibition_name` | |
| 6 | `date` | `String` | `date` | تاريخ الفعالية (للعرض من الـ API) |
| 7 | `startDate` | `String` | `start_date` | تاريخ بدء الفعالية `YYYY-MM-DD` — يُرسَل عند الإنشاء |
| 8 | `endDate` | `String` | `end_date` | تاريخ نهاية الفعالية `YYYY-MM-DD` — يُرسَل عند الإنشاء (= `start_date` لفعالية يوم واحد) |
| 9 | `time` | `String` | `time` | |
| 10 | `maxParticipants` | `int` | `max_participants` | |
| 11 | `registeredCount` | `int` | `registered_count` | |
| 12 | `status` | `String` | `status` | `upcoming` \| `active` \| `ended` |
| 13 | `description` | `String` | `description` | |
| 14 | `requiresBooking` | `bool` | `requires_booking` | |
| 15 | `isFavorite` | `bool` | `is_favorite` | |
| 16 | `place` | `String` | `place` | |
| 17 | `durationDays` | `int` | `duration_days` | افتراضي: 1 — من الرد فقط، **لا يُرسَل** عند الإنشاء |
| 18 | `hasBookableSeats` | `bool` | `has_bookable_seats` | |
| 19 | `totalSeats` | `int` | `total_seats` | |
| 20 | `bookedSeats` | `int` | `booked_seats` | |
| 21 | `soldTickets` | `int` | `sold_tickets` | |
| 22 | `ticketPrice` | `double` | `ticket_price` | |
| 23 | `isGeneralInvitation` | `bool` | `is_general_invitation` | افتراضي: true |
| 24 | `videoPromoUrl` | `String` | `video_promo_url` | |
| 25 | `companyImages` | `List<String>` | `company_images` | |
| 26 | `currentDay` | `int` | `current_day` | اليوم الحالي |
| 27 | `totalEventDays` | `int` | `total_event_days` | |
| 28 | `dailyAttendees` | `List<int>` | `daily_attendees` | |
| 29 | `scannedCount` | `int` | `scanned_count` | |

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


**`toJson()` يُرسَل عبر الموديل (4 حقول):** `event_id, selected_duration_label, selected_days, price`  
> الحقول الإضافية (`company_name`, `company_website`, `company_phone`, `product_names`, والملفات) تُرسَل مباشرةً من `EventsData.createSponsorship()` وليس عبر `toJson()`.

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
| 7 | `status` | `String` (mutable) | `status` | `pending` \| `approved` \| `rejected` |
| 8 | `qrCodeData` | `String?` (mutable) | `qr_code_data` | nullable |
| 9 | `ticketNumber` | `String?` (mutable) | `ticket_number` | nullable |

---

### ReportModel

| # | الحقل | النوع | JSON Key | ملاحظة |
|---|---|---|---|---|
| 1 | `id` | `String` | `id` | يُحوَّل بـ `toString()` |
| 2 | `title` | `String` | `title` | |
| 3 | `type` | `String` | `type` | `visitors` \| `performance` \| `events` \| `campaigns` \| `monthly` \| `compare` |
| 4 | `description` | `String` | `description` | |
| 5 | `period` | `String` | `period` | نص حر مثل `يوليو 2026` |
| 6 | `boothName` | `String` | `booth_name` | |
| 7 | `exhibitionName` | `String` | `exhibition_name` | |
| 8 | `createdAt` | `String` | `created_at` | صيغة `YYYY-MM-DD` — يُستخدم للفلترة بالتاريخ |
| 9 | `mainValue` | `double` | `main_value` | الرقم الرئيسي للتقرير (زوار، نقاط، إلخ) |
| 10 | `mainLabel` | `String` | `main_label` | وصف `mainValue` (مثال: `إجمالي الزوار`) |
| 11 | `trend` | `double` | `trend` | نسبة التغير % — يمكن أن تكون سالبة |
| 12 | `sparklineData` | `List<double>` | `sparkline_data` | نقاط الرسم البياني الصغير — تُستخدم أيضاً لبناء جدول البيانات في التفاصيل والـ PDF |

**قيم `type` وتأثيرها:**
| القيمة | ما يعرضه `ReportTypeHelper` |
|---|---|
| `visitors` | KPIs: إجمالي الزوار / زوار جدد / متوسط وقت الزيارة — جدول: يوم + زوار + ذروة الساعة + معدل الإعادة |
| `performance` | KPIs: مؤشر الأداء / عملاء محتملون / تحويلات — جدول: يوم + مؤشر الأداء + العملاء + التحويلات |
| `events` | KPIs: إجمالي المسجلين / الحضور الفعلي / تقييم الفعاليات — جدول: فعالية + مسجلون + حضور + تقييم |
| `campaigns` | KPIs: إجمالي الوصول / النقرات / التحويلات — جدول: حملة + وصول + نقرات + معدل النقر |
| `monthly` | KPIs: نسبة الإنجاز / التقييم الشامل / الترتيب — جدول: مؤشر + هدف + محقق + نسبة الإنجاز |
| `compare` | نفس `monthly` مع تسمية "المقارنة" |

---

### ExhibitionMapModel

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `exhibitionId` | `int` | `exhibition_id` |
| 2 | `exhibitionName` | `String` | `exhibition_name` |
| 3 | `gridWidth` | `int` | `grid_width` | (افتراضي: 12) |
| 4 | `gridDepth` | `int` | `grid_depth` | (افتراضي: 10) |
| 5 | `halls` | `List<MapHallModel>` | `halls` |

#### MapHallModel (nested)

| # | الحقل | النوع | JSON Key |
|---|---|---|---|
| 1 | `id` | `String` | `id` |
| 2 | `name` | `String` | `name` |
| 3 | `colorHex` | `String` | `color` | hex بدون `#` (افتراضي: `7A1FFF`) |
| 4 | `booths` | `List<MapBoothModel>` | `booths` |

**getter محسوب:** `color` → `Color` من `colorHex`

#### MapBoothModel (nested)

| # | الحقل | النوع | JSON Key | ملاحظة |
|---|---|---|---|---|
| 1 | `id` | `int` | `id` | |
| 2 | `number` | `String` | `number` | |
| 3 | `col` | `int` | `col` | |
| 4 | `row` | `int` | `row` | |
| 5 | `gridWidth` | `int` | `width` | |
| 6 | `gridDepth` | `int` | `depth` | |
| 7 | `height` | `double` | `height` | |
| 8 | `status` | `String` (mutable) | `status` | `available` \| `booked` |
| 9 | `price` | `double` | `price` | |
| 10 | `area` | `double` | `area` | |
| 11 | `hallId` | `String` | *(يُمرَّر من الأب `MapHallModel.id`)* | |
| 12 | `hallName` | `String` | *(يُمرَّر من الأب `MapHallModel.name`)* | |
| 13 | `amenities` | `List<String>` | `amenities` | |

**Getters محسوبة:** `isAvailable` → `status == 'available'` \| `isBooked` → `status == 'booked'`

---

### ConversationModel (Firebase)

| # | الحقل | النوع | Firestore Field | ملاحظة |
|---|---|---|---|---|
| 1 | `id` | `int` | doc.id | يُحوَّل من String عبر `_toInt()` → `int.tryParse` أو `hashCode` |
| 2 | `exhibitionId` | `int` | `exhibition_id` | |
| 3 | `exhibitionName` | `String` | `exhibition_name` | |
| 4 | `exhibitionInitials` | `String` | `exhibition_initials` | |
| 5 | `color` | `int` | `color` (hex string) | يُحوَّل من String hex لـ `int` |
| 6 | `messages` | `List<MessageModel>` | `messages[]` | |
| 7 | `unreadCount` | `int` (mutable) | `unread_count` | |

**Getters محسوبة:**
- `lastMessageObj` → آخر `MessageModel` في `messages` أو `null`
- `lastMessage` → `lastMessageObj?.text ?? ''`
- `lastTime` → `lastMessageObj?.time ?? ''`

---

### VisitorConversationModel (Firebase)

| # | الحقل | النوع | Firestore Field | ملاحظة |
|---|---|---|---|---|
| 1 | `id` | `int` | doc.id | يُحوَّل من String عبر `_toIntId()` |
| 2 | `visitorName` | `String` | `visitor_name` | |
| 3 | `visitorInitials` | `String` | `visitor_initials` | |
| 4 | `color` | `int` | `color` (hex string) | افتراضي: `0xFFFF1592` |
| 5 | `messages` | `List<MessageModel>` | `messages[]` | |
| 6 | `unreadCount` | `int` (mutable) | `unread_count` | |

**Getters محسوبة:**
- `lastMessageObj` → آخر `MessageModel` في `messages` أو `null`
- `lastMessage` → `lastMessageObj?.text ?? ''`
- `lastTime` → `lastMessageObj?.time ?? ''`

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
