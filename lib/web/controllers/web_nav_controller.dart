import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/web_section.dart';
import '../models/web_detail_request.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/model/event/event_model.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/report/report_model.dart';
import '../../data/model/event/sponsorship_booking_model.dart';
import '../../data/model/event/exhibition_sponsor_event_model.dart';

// ════════════════════════════════════════════════════════════
//  CONTROLLER  —  WebNavController
//  يدير تنقّل أقسام نسخة الويب
// ════════════════════════════════════════════════════════════
class WebNavController extends GetxController {
  /// accessor آمن — يُنشئ الكنترولر عند أول استخدام
  static WebNavController get to => Get.isRegistered<WebNavController>()
      ? Get.find<WebNavController>()
      : Get.put(WebNavController(), permanent: true);

  final selected    = 0.obs;
  final messagesTab = 0.obs;   // حالة تبويب الرسائل (مسؤولية الكنترولر)

  // ── أقسام الموقع (بيانات التنقّل) ─────────────────────────
  final sections = const <WebSection>[
    WebSection(icon: Icons.dashboard_rounded,    label: 'الرئيسية'),       // 0
    WebSection(icon: Icons.storefront_rounded,   label: 'المعارض'),         // 1
    WebSection(icon: Icons.grid_view_rounded,    label: 'أجنحتي'),          // 2
    WebSection(icon: Icons.event_rounded,        label: 'الفعاليات'),       // 3
    WebSection(icon: Icons.workspace_premium_rounded, label: 'رعاياتي'),    // 4
    WebSection(icon: Icons.bar_chart_rounded,    label: 'التقارير'),        // 5
    WebSection(icon: Icons.chat_bubble_rounded,  label: 'الرسائل'),         // 6
    WebSection(icon: Icons.favorite_rounded,     label: 'المفضلة'),         // 7
    WebSection(icon: Icons.settings_rounded,     label: 'الإعدادات'),       // 8
  ];

  // ── الصفحة الداخلية المعروضة (تفاصيل) ─────────────────────
  final detail = Rxn<WebDetailRequest>();

  void select(int index) {
    detail.value = null;       // إغلاق أي تفاصيل عند تبديل القسم
    selected.value = index;
  }

  // ── فتح الصفحات الداخلية المخصصة ──────────────────────────
  void openExhibition(ExhibitionModel e) =>
      detail.value = WebDetailRequest(WebDetailType.exhibition, data: e);

  void openBooth(BoothModel b, {ReportModel? report}) =>
      detail.value = WebDetailRequest(WebDetailType.booth, data: b, extra: report);

  void openEvent(EventModel e) =>
      detail.value = WebDetailRequest(WebDetailType.event, data: e);

  void openReport(ReportModel r) =>
      detail.value = WebDetailRequest(WebDetailType.report, data: r);

  void openCreateEvent() =>
      detail.value = const WebDetailRequest(WebDetailType.createEvent);

  void openTicketRequests(EventModel e) =>
      detail.value = WebDetailRequest(WebDetailType.ticketRequests, data: e);

  void openSponsorship(SponsorshipBookingModel s) =>
      detail.value = WebDetailRequest(WebDetailType.sponsorship, data: s);

  void openScanner() =>
      detail.value = const WebDetailRequest(WebDetailType.scanner);

  void openNotifications() =>
      detail.value = const WebDetailRequest(WebDetailType.notifications);

  void openSponsorEvent(ExhibitionSponsorEvent e) =>
      detail.value = WebDetailRequest(WebDetailType.sponsorEvent, data: e);

  void openMap() =>
      detail.value = const WebDetailRequest(WebDetailType.map);

  void closeDetail() => detail.value = null;

  WebSection get current => sections[selected.value];

  String get currentTitle {
    switch (detail.value?.type) {
      case WebDetailType.exhibition:  return 'تفاصيل المعرض';
      case WebDetailType.booth:       return 'تفاصيل الجناح';
      case WebDetailType.event:       return 'تفاصيل الفعالية';
      case WebDetailType.report:      return 'التقرير';
      case WebDetailType.createEvent: return 'نشر فعالية';
      case WebDetailType.ticketRequests: return 'طلبات التذاكر';
      case WebDetailType.sponsorship:    return 'تفاصيل الرعاية';
      case WebDetailType.scanner:        return 'مسح QR / باركود';
      case WebDetailType.notifications:  return 'الإشعارات';
      case WebDetailType.sponsorEvent:   return 'رعاية الفعالية';
      case WebDetailType.map:            return 'خريطة المعرض 3D';
      case null:                      return current.label;
    }
  }
}
