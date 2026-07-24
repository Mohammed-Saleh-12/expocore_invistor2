# خطة العمل — تحسينات صفحة تفاصيل المعرض
# Work Plan: Exhibition Detail & Map Enhancements

> **التاريخ:** 2026-07-24  
> **الحالة:** جاهز للتنفيذ  

---

## 📋 تحليل المتطلبات

| # | المتطلب | الوضع الحالي | المطلوب |
|---|---------|-------------|---------|
| 1 | جلب أجنحة المعرض عند فتح صفحة التفاصيل | لا يوجد استدعاء | استدعاء `/booths?exhibition_id={id}` من `ExhibitionDetailController.onInit()` |
| 2 | الخريطة 3D من نفس طلب تفاصيل المعرض | استدعاء منفصل `/exhibitions/{id}/map` | تحليل `map_data` من response تفاصيل المعرض |
| 3 | ربط IDs الخريطة بأجنحة المعرض | بيانات ثابتة hardcoded في `BoothMapController` | ربط `MapBoothModel.id` بـ `BoothModel` من قائمة الأجنحة |
| 4 | خدمات الجناح ديناميكية من الـ API | 4 خدمات ثابتة بأسعار hardcoded | `BoothModel.services: Map<String,double>` → عرض ديناميكي في صفحة الحجز |
| 5 | الفعاليات الإعلانية من طلب تفاصيل المعرض | تُجلب من `EventsController` بشكل مستقل | تحليل `sponsor_events` من نفس response التفاصيل |
| 6 | خدمات المعرض من الـ API | قائمة ثابتة في الواجهة | `ExhibitionModel.services: List<String>` من الـ API |
| 7 | دعم أكثر من صورة للمعرض | `imageUrl: String` واحدة | `images: List<String>` + grid gallery + fullscreen viewer |

---

## 🏗️ هيكل التغييرات

```
التغييرات مرتبة حسب طبقة MVC:

Layer 1: Models          ← تحديث البيانات
Layer 2: Data Sources    ← تحديث الطلبات
Layer 3: Controllers     ← منطق العمل
Layer 4: Views           ← الواجهات (موبايل + ويب)
Layer 5: Widgets         ← مكونات مشتركة جديدة
```

---

## 📁 الملفات المتأثرة

### Layer 1 — Models

#### `lib/data/model/exhibition/exhibition_model.dart`
**التغييرات:**
- إضافة `images: List<String>` (قائمة الصور)
- إضافة `services: List<String>` (خدمات المعرض من الـ API)
- إضافة `mapJson: Map<String,dynamic>?` (بيانات الخريطة 3D)
- إضافة `sponsorEvents: List<ExhibitionSponsorEvent>` (الفعاليات الإعلانية)
- `imageUrl` يصبح getter يُعيد `images.first` للتوافق مع الكود الحالي
- `fromJson()` يُحلل كل الحقول الجديدة

#### `lib/data/model/booth/booth_model.dart`
**التغييرات:**
- إضافة `services: Map<String,double>` (اسم الخدمة → سعرها)
- إضافة `companyName: String?` ← من `booking.company_name`
- إضافة `companyEmail: String?` ← من `booking.company_email`
- إضافة `companyInitials: String?` ← من `booking.company_initials`
- حذف الحقول الثابتة: `screenService`, `setupService`, `securityService`, `cleaningService`

---

### Layer 2 — Data Sources

#### `lib/data/sourcedata/remote/Exhibitions/ExhibitionsData.dart`
**التغييرات:**
- `getExhibitionDetail(int id)` ← نفس الـ endpoint، لكن الـ response الآن يحوي:
  ```json
  {
    "id": 1,
    "name": "...",
    "images": ["url1", "url2"],
    "services": ["واي فاي", "موقف", "أمن"],
    "map_data": { "exhibition_id":1, "halls":[...] },
    "sponsor_events": [{ "id":1, "name":"..." }]
  }
  ```
  لا تغيير في الـ endpoint نفسه، فقط تحليل حقول إضافية

#### `lib/data/sourcedata/remote/Booths/BoothsData.dart`
**التغييرات:**
- إضافة `getExhibitionBooths(int exhibitionId)` ← يستدعي `GET /booths?exhibition_id={id}`

#### `lib/data/sourcedata/remote/Exhibitions/ExhibitionMapData.dart`
- **يُحذف** الاستدعاء المستقل (الخريطة تأتي مع التفاصيل)
- الملف يبقى لكن لا يُستدعى من `BoothMapController`

---

### Layer 3 — Controllers

#### `lib/controller/Home/exhibition_detail_controller.dart` ← رئيسي
**التغييرات:**
```dart
// onInit() يستدعي طلبين متوازيين:
// 1. getExhibitionDetail(id) → يحفظ exhibition (مع map + events + services)
// 2. getExhibitionBooths(id) → يحفظ exhibitionBooths: List<BoothModel>

final isLoading = true.obs;
final exhibitionBooths = <BoothModel>[].obs;  // ← جديد
// بعد التحميل: يمرر mapJson لـ BoothMapController
```

#### `lib/controller/Home/booth_map_controller.dart`
**التغييرات:**
- حذف `ExhibitionMapData` (الخريطة تأتي من `ExhibitionDetailController`)
- إضافة `setMapData(Map<String,dynamic> mapJson, List<BoothModel> booths)`
- حذف `bookedCompanies` الثابتة
- إضافة `linkedBooth(MapBoothModel mapBooth) → BoothModel?` 
  - يبحث في `exhibitionBooths` عن booth بنفس الـ id
- `companyForBooth()` يُعيد بيانات من `BoothModel.companyName` الحقيقية
- `proceedToBooking()` يمرر `BoothModel` الكامل (مع services الديناميكية)

#### `lib/controller/Home/booking_controller.dart`
**التغييرات:**
- حذف `screenService`, `setupService`, `securitySvc`, `cleaningService` الثابتة
- إضافة `selectedServices: Map<String, RxBool>` ← ديناميكي من `booth.services`
- `total` يُحسب من `selectedServices` × أسعارها من `booth.services`
- `submitBooking()` يرسل `services: Map<String,bool>` بدلاً من 4 حقول ثابتة

---

### Layer 4 — Views

#### `lib/view/screen/Home/exhibitions/exhibition_detail_view.dart` (موبايل)
**التغييرات:**
- `SliverAppBar` ← يعرض أول صورة كـ hero (لا تغيير مرئي)
- `_servicesTab()` ← يقرأ من `exhibition.services` بدلاً من hardcoded
- إضافة `_imagesSection()` ← شبكة صور Grid (قبل الـ TabBar)
- عند الضغط على صورة ← `ExhibitionImageViewer` (fullscreen)
- `_eventsTab()` ← يقرأ من `ctrl.exhibition.sponsorEvents` بدلاً من `EventsController`

#### `lib/view/screen/Home/booths/booking_request_view.dart` (موبايل)
**التغييرات:**
- `_serviceCheck()` ← يُولَّد ديناميكياً من `controller.selectedServices`
- `_costSummary()` ← يقرأ الأسعار من `booth.services[name]`

#### `lib/web/view/pages/web_exhibitions_page.dart` / web detail
**نفس تغييرات الموبايل:** services ديناميكية + gallery

#### `lib/web/view/pages/web_booking_request_page.dart`
**نفس تغييرات الموبايل:** services ديناميكية

#### Exhibition Cards (الكروت)
- `exhibition.imageUrl` ← يُعيد `images.first` تلقائياً (getter) → لا تغيير في الكروت

---

### Layer 5 — Widgets جديدة

#### `lib/view/widget/Home/exhibition_image_gallery.dart` ← جديد
```
- ExhibitionImageGallery (widget مشترك للموبايل والويب)
  - عرض الصور كـ Staggered Grid (أحجام مختلفة)
  - أول صورة كبيرة، باقي الصور متوسطة/صغيرة
  - عند الضغط → ExhibitionImageViewer (fullscreen)

- ExhibitionImageViewer (fullscreen dialog/route)
  - PageView للتمرير بين الصور
  - زر إغلاق
  - مؤشر الصفحة الحالية (dots)
  - دعم Swipe للإغلاق
```

---

## 🔄 تدفق البيانات بعد التغيير

```
فتح صفحة تفاصيل المعرض
         ↓
ExhibitionDetailController.onInit()
    ├── [طلب 1] getExhibitionDetail(id)
    │       ↓ Response يحوي:
    │       ├── exhibition info (name, dates, ...)
    │       ├── images: ["url1", "url2", "url3"]
    │       ├── services: ["واي فاي", "موقف", "أمن"]
    │       ├── map_data: { halls: [...] }  ← بيانات الخريطة 3D
    │       └── sponsor_events: [...]
    │
    └── [طلب 2] getExhibitionBooths(id) → GET /booths?exhibition_id={id}
            ↓ Response يحوي قائمة BoothModel:
            └── كل booth يحوي:
                ├── id, number, area, price
                ├── services: {"واي فاي إضافي": 200, "شاشة عرض": 500}
                ├── status: "available" | "booked"
                └── إذا booked: companyName, companyEmail, companyInitials

         ↓ بعد اكتمال الطلبين:
ExhibitionDetailController يمرر لـ BoothMapController:
    ├── mapJson (بيانات الخريطة)
    └── exhibitionBooths (قائمة الأجنحة مع تفاصيلها)

         ↓ عند فتح الخريطة:
BoothMapController.loadFromDetailData(mapJson, booths)
    ├── يبني ExhibitionMapModel من mapJson
    └── يبني خريطة id → BoothModel للربط السريع

         ↓ عند الضغط على جناح في الخريطة:
BoothMapController.onBoothTapped(mapBooth)
    ├── يجد BoothModel المقابل عبر id
    ├── إذا booked → يعرض Dialog مع companyName/email (من الـ API)
    └── إذا available → يعرض BottomSheet + تفاصيل الجناح
              ↓ زر الحجز
         BookingController.resetForBooth(boothModel)
              ↓
         BookingRequestView يعرض:
              ├── خدمات ديناميكية من booth.services
              └── السعر الإجمالي يُحسب ديناميكياً
```

---

## ⚙️ ترتيب التنفيذ

```
المرحلة 1: Models (لا تبعيات خارجية)
  ├── 1.1 ExhibitionModel → images, services, mapJson, sponsorEvents
  └── 1.2 BoothModel → services (Map), company fields, حذف hardcoded services

المرحلة 2: Data Sources
  ├── 2.1 BoothsData.getExhibitionBooths()
  └── 2.2 ExhibitionsData.getExhibitionDetail() ← تحليل الحقول الجديدة

المرحلة 3: Controllers
  ├── 3.1 ExhibitionDetailController ← استدعاء الطلبين + تمرير البيانات للخريطة
  ├── 3.2 BoothMapController ← حذف API call، ربط الأجنحة، بيانات الشركات من الـ API
  └── 3.3 BookingController ← خدمات ديناميكية

المرحلة 4: Widget مشترك
  └── 4.1 ExhibitionImageGallery + ExhibitionImageViewer

المرحلة 5: Views
  ├── 5.1 ExhibitionDetailView (موبايل) ← gallery + dynamic services + events
  ├── 5.2 BookingRequestView (موبايل) ← dynamic services
  ├── 5.3 Web exhibition detail ← نفس تغييرات الموبايل
  └── 5.4 Web booking request ← نفس تغييرات الموبايل
```

---

## 📐 شكل Firestore/API المتوقع

### `GET /exhibitions/{id}` Response:
```json
{
  "id": 1,
  "name": "معرض التقنية 2026",
  "images": [
    "https://cdn.example.com/ex1-hero.jpg",
    "https://cdn.example.com/ex1-hall-a.jpg",
    "https://cdn.example.com/ex1-hall-b.jpg"
  ],
  "services": ["واي فاي مجاني", "موقف سيارات", "أمن 24/7", "استقبال", "مطاعم"],
  "map_data": {
    "exhibition_id": 1,
    "grid_width": 13,
    "grid_depth": 10,
    "halls": [
      {
        "id": "A", "name": "القاعة أ", "color": "7A1FFF",
        "booths": [{ "id": 1, "number": "A01", "col": 0, "row": 0, ... }]
      }
    ]
  },
  "sponsor_events": [
    { "id": 10, "name": "فعالية إعلانية", "type": "banner", ... }
  ]
}
```

### `GET /booths?exhibition_id={id}` Response:
```json
{
  "data": [
    {
      "id": 1,
      "number": "A01",
      "status": "available",
      "price": 18000,
      "area": 400,
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

---

## ⚠️ قرارات تصميمية مهمة

| القرار | السبب |
|--------|-------|
| `imageUrl` يبقى getter يُعيد `images.first` | حفاظ على التوافق مع جميع الكروت الحالية دون تعديلها |
| `ExhibitionDetailController` هو من يمرر الخريطة لـ `BoothMapController` | تجنب طلب API إضافي وتحقيق الاتساق بين بيانات الأجنحة والخريطة |
| الخدمات في الحجز كـ `Map<String,double>` وليس `List` | يسمح بجلب السعر مباشرة من الاسم |
| `ExhibitionImageGallery` widget مستقل ومشترك | يُستخدم في الموبايل والويب معاً بدون تكرار |
| الـ fallback للبيانات الثابتة يبقى في كل controller | في حالة فشل الـ API لا ينكسر التطبيق |
```
