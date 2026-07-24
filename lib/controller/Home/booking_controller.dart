import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/sourcedata/remote/Booking/BookingData.dart';

class BookingController extends GetxController {
  final BookingData _bookingData = BookingData(Crud());

  final booth        = Rx<BoothModel?>(null);
  final notesCtrl    = TextEditingController();
  final status       = StatusRequest.none.obs;
  final isSubmitting = false.obs;

  /// وضع الحجز: 'full' = الفترة كاملة | 'custom' = أيام محددة
  final bookingMode = 'full'.obs;

  /// نطاق الأيام المحدد في الوضع المخصص
  final customRangeStart = Rxn<DateTime>();
  final customRangeEnd   = Rxn<DateTime>();

  /// الخدمات الديناميكية — مُنشأة من booth.services عند setBooth
  final serviceSelections = <String, bool>{}.obs;

  VoidCallback? _onWebSuccess;

  // ── Available days (كل الأيام بين start_date و end_date للجناح) ──
  List<DateTime> get availableDays {
    final b = booth.value;
    if (b == null) return [];
    final s = DateTime.tryParse(b.startDate);
    final e = DateTime.tryParse(b.endDate);
    if (s == null || e == null || e.isBefore(s)) return [];
    final days = <DateTime>[];
    DateTime cur = s;
    while (!cur.isAfter(e)) {
      days.add(cur);
      cur = cur.add(const Duration(days: 1));
    }
    return days;
  }

  // ── تاريخ البداية الفعلي حسب الوضع ──────────────────────────
  String get effectiveStartDate {
    if (bookingMode.value == 'full') return booth.value?.startDate ?? '';
    final d = customRangeStart.value;
    return d == null ? '' : _fmtDate(d);
  }

  // ── تاريخ النهاية الفعلي حسب الوضع ──────────────────────────
  String get effectiveEndDate {
    if (bookingMode.value == 'full') return booth.value?.endDate ?? '';
    final e = customRangeEnd.value;
    final s = customRangeStart.value;
    if (e != null) return _fmtDate(e);
    if (s != null) return _fmtDate(s); // يوم واحد فقط
    return '';
  }

  // ── عدد الأيام الفعلية ────────────────────────────────────────
  int get effectiveDuration {
    final s = DateTime.tryParse(effectiveStartDate);
    final e = DateTime.tryParse(effectiveEndDate);
    if (s == null || e == null) return 0;
    return e.difference(s).inDays + 1;
  }

  /// هل اليوم ضمن النطاق المحدد (للعرض البصري)؟
  bool isDayInRange(DateTime day) {
    final s = customRangeStart.value;
    final e = customRangeEnd.value;
    if (s == null) return false;
    final d = DateTime(day.year, day.month, day.day);
    final start = DateTime(s.year, s.month, s.day);
    if (e == null) return d == start;
    final end = DateTime(e.year, e.month, e.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  bool isDayRangeStart(DateTime day) {
    final s = customRangeStart.value;
    if (s == null) return false;
    return _sameDay(day, s);
  }

  bool isDayRangeEnd(DateTime day) {
    final e = customRangeEnd.value;
    if (e == null) return false;
    return _sameDay(day, e);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// النقر على يوم في الوضع المخصص — يفرض التتالي تلقائياً
  void tapDay(DateTime day) {
    final s = customRangeStart.value;
    if (s == null || (customRangeEnd.value != null)) {
      // بداية تحديد جديد
      customRangeStart.value = day;
      customRangeEnd.value   = null;
    } else {
      // البداية محددة، نحتاج نهاية
      if (_sameDay(day, s) || day.isAfter(s)) {
        customRangeEnd.value = day;
      } else {
        // اليوم قبل البداية — نعيد التحديد من هذا اليوم
        customRangeStart.value = day;
        customRangeEnd.value   = null;
      }
    }
    // تحديث الـ UI
    customRangeStart.refresh();
    customRangeEnd.refresh();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── إعداد وضع الحجز ──────────────────────────────────────────
  void setBookingMode(String mode) {
    bookingMode.value        = mode;
    customRangeStart.value   = null;
    customRangeEnd.value     = null;
  }

  // ── Total price (ديناميكي) ────────────────────────────────────
  double get total {
    final base     = (booth.value?.price ?? 0) * effectiveDuration;
    final services = booth.value?.services ?? {};
    double extras  = 0;
    for (final entry in serviceSelections.entries) {
      if (entry.value && services.containsKey(entry.key)) {
        extras += services[entry.key]!;
      }
    }
    return base + extras;
  }

  // ── Set booth + init service selections ──────────────────────
  void setBooth(BoothModel b) {
    booth.value = b;
    _initServices(b);
  }

  /// تهيئة كاملة (تُستخدم من الويب أو عند إعادة الفتح)
  void resetForBooth(BoothModel b, {VoidCallback? onSuccess}) {
    booth.value            = b;
    bookingMode.value      = 'full';
    customRangeStart.value = null;
    customRangeEnd.value   = null;
    status.value           = StatusRequest.none;
    notesCtrl.clear();
    _onWebSuccess = onSuccess;
    _initServices(b);
  }

  /// لتوافق الكود القديم من الويب
  void resetForWeb(BoothModel b, VoidCallback onSuccess) =>
      resetForBooth(b, onSuccess: onSuccess);

  void _initServices(BoothModel b) {
    serviceSelections.clear();
    for (final key in b.services.keys) {
      serviceSelections[key] = false;
    }
  }

  /// تبديل حالة خدمة
  void toggleService(String name) {
    serviceSelections[name] = !(serviceSelections[name] ?? false);
  }

  // ── Submit booking ────────────────────────────────────────────
  Future<void> submitBooking() async {
    final b = booth.value;
    if (b == null) return;

    // التحقق من تحديد التواريخ في الوضع المخصص
    if (bookingMode.value == 'custom') {
      if (customRangeStart.value == null) {
        Get.snackbar('تنبيه', 'يرجى تحديد يوم البداية',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      // إذا لم تُحدد نهاية نعتبرها نفس البداية (يوم واحد)
      customRangeEnd.value ??= customRangeStart.value;
    }

    final sDate = effectiveStartDate;
    final eDate = effectiveEndDate;
    if (sDate.isEmpty || eDate.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى تحديد تواريخ الحجز',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    status.value       = StatusRequest.loading;
    isSubmitting.value = true;

    final result = await _bookingData.bookBooth(
      boothId:    b.id,
      startDate:  sDate,
      endDate:    eDate,
      notes:      notesCtrl.text.trim(),
      services:   Map<String, bool>.from(serviceSelections),
      totalPrice: total,
    );

    if (result['status'] == true) {
      status.value = StatusRequest.success;
      if (Get.key.currentState?.canPop() ?? false) Get.back();
      Future.delayed(const Duration(milliseconds: 400), () {
        _onWebSuccess?.call();
        _onWebSuccess = null;
      });
      Get.snackbar('booking_submitted_title'.tr, 'booking_submitted_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      status.value = StatusRequest.failure;
      Get.snackbar('error'.tr, result['message'] ?? 'booking_failed_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
    isSubmitting.value = false;
  }

  Future<void> cancelBooking(int bookingId) async {
    final result = await _bookingData.cancelBooking(bookingId);
    if (result['status'] == true) {
      Get.snackbar('booking_cancelled_title'.tr, 'booking_cancelled_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('error'.tr, result['message'] ?? 'booking_cancel_fail_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    notesCtrl.dispose();
    super.onClose();
  }
}
