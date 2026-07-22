import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/web_section.dart';
import '../models/web_detail_request.dart';
import '../../controller/Home/booth_management_controller.dart';
import '../../controller/Home/booking_controller.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/model/event/event_model.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/report/report_model.dart';
import '../../data/model/event/sponsorship_booking_model.dart';
import '../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../controller/Home/messages_controller.dart';

class WebNavController extends GetxController {
  static WebNavController get to => Get.isRegistered<WebNavController>()
      ? Get.find<WebNavController>()
      : Get.put(WebNavController(), permanent: true);

  final selected = 0.obs;
  final messagesTab = 0.obs;

  static const sections = <WebSection>[
    WebSection(icon: Icons.dashboard_rounded, label: 'nav_home'),
    WebSection(icon: Icons.storefront_rounded, label: 'nav_exhibitions'),
    WebSection(icon: Icons.grid_view_rounded, label: 'nav_my_booths'),
    WebSection(icon: Icons.event_rounded, label: 'nav_events'),
    WebSection(
      icon: Icons.add_circle_outline_rounded,
      label: 'detail_create_event',
    ),
    WebSection(
      icon: Icons.workspace_premium_rounded,
      label: 'nav_sponsorships',
    ),
    WebSection(icon: Icons.bar_chart_rounded, label: 'nav_reports'),
    WebSection(icon: Icons.chat_bubble_rounded, label: 'nav_messages'),
    WebSection(icon: Icons.favorite_rounded, label: 'nav_favorites'),
    WebSection(icon: Icons.settings_rounded, label: 'nav_settings'),
  ];

  final detail = Rxn<WebDetailRequest>();

  void select(int index) {
    detail.value = null;
    selected.value = index;
  }

  void openExhibition(ExhibitionModel e) =>
      detail.value = WebDetailRequest(WebDetailType.exhibition, data: e);

  void openBooth(BoothModel b, {ReportModel? report}) => detail.value =
      WebDetailRequest(WebDetailType.booth, data: b, extra: report);

  void openBoothManagement(BoothModel b) {
    final c = Get.isRegistered<BoothManagementController>()
        ? Get.find<BoothManagementController>()
        : Get.put(BoothManagementController());
    c.webInit(b);
    detail.value = WebDetailRequest(WebDetailType.boothManagement, data: b);
  }

  void openBookingRequest(BoothModel b) {
    final c = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : Get.put(BookingController());
    c.resetForWeb(b, closeDetail);
    detail.value = WebDetailRequest(WebDetailType.bookingRequest, data: b);
  }

  void openBookingDetail(BoothModel b) =>
      detail.value = WebDetailRequest(WebDetailType.bookingDetail, data: b);

  void openEvent(EventModel e) =>
      detail.value = WebDetailRequest(WebDetailType.event, data: e);

  void openReport(ReportModel r) {
    selected.value = sections.indexWhere((s) => s.label == 'nav_reports');
    detail.value = WebDetailRequest(WebDetailType.report, data: r);
  }

  void openMessagesForExhibition(String exhibitionName) {
    Get.find<MessagesController>().prepareConversationForExhibition(exhibitionName);
    detail.value = null;
    selected.value = sections.indexWhere((s) => s.label == 'nav_messages');
  }

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

  void openMap() => detail.value = const WebDetailRequest(WebDetailType.map);

  void openExhibitionEvents() =>
      detail.value = const WebDetailRequest(WebDetailType.exhibitionEvents);

  void openAccountDetail() =>
      detail.value = const WebDetailRequest(WebDetailType.accountDetail);

  void closeDetail() => detail.value = null;

  WebSection get current => sections[selected.value];

  String get currentTitle {
    switch (detail.value?.type) {
      case WebDetailType.exhibition:
        return 'detail_exhibition'.tr;
      case WebDetailType.booth:
        return 'detail_booth'.tr;
      case WebDetailType.boothManagement:
        return 'detail_booth_management'.tr;
      case WebDetailType.bookingRequest:
        return 'detail_booking_request'.tr;
      case WebDetailType.bookingDetail:
        return 'detail_booking_detail'.tr;
      case WebDetailType.event:
        return 'detail_event'.tr;
      case WebDetailType.report:
        return 'detail_report'.tr;
      case WebDetailType.createEvent:
        return 'detail_create_event'.tr;
      case WebDetailType.ticketRequests:
        return 'detail_ticket_requests'.tr;
      case WebDetailType.sponsorship:
        return 'detail_sponsorship'.tr;
      case WebDetailType.scanner:
        return 'detail_scanner'.tr;
      case WebDetailType.notifications:
        return 'detail_notifications'.tr;
      case WebDetailType.sponsorEvent:
        return 'detail_sponsor_event'.tr;
      case WebDetailType.map:
        return 'detail_map'.tr;
      case WebDetailType.exhibitionEvents:
        return 'فعاليات المعارض الإعلانية';
      case WebDetailType.accountDetail:
        return 'تفاصيل الحساب';
      case null:
        return current.label.tr;
    }
  }
}
