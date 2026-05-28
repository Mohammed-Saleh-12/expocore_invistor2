import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/event/event_model.dart';
import '../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../data/model/event/sponsorship_booking_model.dart';
import '../../data/model/event/ticket_request_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class EventsController extends GetxController {
  // ── Investor's own events (for their booth) ──────────────────────────
  final myEvents             = <EventModel>[].obs;

  // ── Exhibition sponsor events (announced by exhibition management) ───
  final exhibitionSponsorEvents = <ExhibitionSponsorEvent>[].obs;

  // ── My booked sponsorships ───────────────────────────────────────────
  final mySponsorshipBookings = <SponsorshipBookingModel>[].obs;

  // ── Ticket requests (event id → list) ───────────────────────────────
  final ticketRequests = <int, List<TicketRequestModel>>{}.obs;

  // ── UI state ─────────────────────────────────────────────────────────
  final selectedTab      = 0.obs;
  final isCreating       = false.obs;
  final isBooking        = false.obs;

  // ── Create-event form ────────────────────────────────────────────────
  final nameCtrl         = TextEditingController();
  final descCtrl         = TextEditingController();
  final maxCtrl          = TextEditingController();
  final seatsCtrl        = TextEditingController();
  final ticketPriceCtrl  = TextEditingController();
  final videoPromoCtrl   = TextEditingController();
  final formKey          = GlobalKey<FormState>();
  final selectedType     = ''.obs;
  final selectedDate     = ''.obs;
  final selectedTime     = ''.obs;
  final selectedDuration = 1.obs;
  final hasBookableSeats = false.obs;
  final isGeneralInvite  = true.obs;

  final eventTypes = [
    'ورشة عمل', 'عرض مباشر', 'مسابقة', 'ندوة',
    'حفل', 'مقابلة', 'لقاء B2B', 'مؤتمر',
  ];

  // ── Sponsorship booking form ─────────────────────────────────────────
  final selectedSponsorDuration = Rxn<SponsorDurationOption>();
  final companyNameCtrl    = TextEditingController();
  final companyWebCtrl     = TextEditingController();
  final companyPhoneCtrl   = TextEditingController();
  final productNamesCtrl   = TextEditingController();
  final sponsorFormKey     = GlobalKey<FormState>();

  @override
  void onInit() {
    myEvents.value                = DummyData.events
        .where((e) => e.boothNumber.isNotEmpty)
        .toList();
    exhibitionSponsorEvents.value = List.from(DummyData.exhibitionSponsorEvents);
    mySponsorshipBookings.value   = List.from(DummyData.sponsorshipBookings);
    ticketRequests.value          = Map.from(DummyData.ticketRequests);

    // Pre-fill company info
    companyNameCtrl.text  = 'شركة التقنية المتقدمة';
    companyWebCtrl.text   = 'https://techadvanced.sa';
    companyPhoneCtrl.text = '+966501234567';
    super.onInit();
  }

  // ── Create investor event ────────────────────────────────────────────
  Future<void> createEvent() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedType.value.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى اختيار نوع الفعالية',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF7941D),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    isCreating.value = true;
    await Future.delayed(const Duration(seconds: 1));

    final newEvent = EventModel(
      id: myEvents.length + 100,
      name: nameCtrl.text.trim(),
      type: selectedType.value,
      boothNumber: 'B12',
      exhibitionName: 'معرض التقنية 2026',
      date: selectedDate.value.isEmpty ? '2026-07-18' : selectedDate.value,
      time: selectedTime.value.isEmpty ? '10:00' : selectedTime.value,
      maxParticipants: int.tryParse(maxCtrl.text) ?? 100,
      registeredCount: 0,
      status: 'upcoming',
      description: descCtrl.text.trim(),
      requiresBooking: hasBookableSeats.value,
      place: 'جناح B12',
      durationDays: selectedDuration.value,
      hasBookableSeats: hasBookableSeats.value,
      totalSeats: int.tryParse(seatsCtrl.text) ?? 0,
      ticketPrice: double.tryParse(ticketPriceCtrl.text) ?? 0,
      isGeneralInvitation: isGeneralInvite.value,
      videoPromoUrl: videoPromoCtrl.text.trim(),
      currentDay: 0,
      totalEventDays: selectedDuration.value,
      dailyAttendees: [],
      scannedCount: 0,
    );

    myEvents.add(newEvent);
    isCreating.value = false;
    _resetCreateForm();
    Get.back();
    Get.snackbar(
      'تم النشر',
      'تم نشر الفعالية "${newEvent.name}" بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  void _resetCreateForm() {
    nameCtrl.clear();
    descCtrl.clear();
    maxCtrl.clear();
    seatsCtrl.clear();
    ticketPriceCtrl.clear();
    videoPromoCtrl.clear();
    selectedType.value = '';
    selectedDate.value = '';
    selectedTime.value = '';
    selectedDuration.value = 1;
    hasBookableSeats.value = false;
    isGeneralInvite.value = true;
  }

  // ── Book a sponsorship slot ──────────────────────────────────────────
  Future<void> bookSponsorship(ExhibitionSponsorEvent event) async {
    if (selectedSponsorDuration.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار مدة المشاركة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF7941D),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    isBooking.value = true;
    await Future.delayed(const Duration(seconds: 1));

    final dur = selectedSponsorDuration.value!;
    final booking = SponsorshipBookingModel(
      id: mySponsorshipBookings.length + 2000,
      eventId: event.id,
      eventName: event.name,
      eventType: event.type,
      exhibitionName: event.exhibitionName,
      date: event.date,
      place: event.place,
      time: event.startTime,
      selectedDurationLabel: dur.label,
      selectedDays: dur.days,
      price: dur.price,
      status: 'pending',
      bookedAt: '2026-07-01',
      dailyVisitors: List.filled(dur.days, 0),
      currentDay: 0,
      totalDays: dur.days,
    );

    mySponsorshipBookings.add(booking);
    isBooking.value = false;
    selectedSponsorDuration.value = null;
    Get.back();
    Get.snackbar(
      'تم الحجز',
      'تم إرسال طلب الرعاية للفعالية "${event.name}"',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  // ── Ticket request management ────────────────────────────────────────
  List<TicketRequestModel> getTicketRequests(int eventId) {
    return ticketRequests[eventId] ?? [];
  }

  void approveTicketRequest(TicketRequestModel req) {
    req.status = 'approved';
    req.ticketNumber = 'ECT-${req.id.toString().padLeft(3, '0')}';
    req.qrCodeData = '${req.ticketNumber}-2026';
    ticketRequests.refresh();
    Get.snackbar(
      'تم القبول',
      'تم قبول طلب ${req.requesterName} وتوليد تذكرة QR',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  void rejectTicketRequest(TicketRequestModel req) {
    req.status = 'rejected';
    ticketRequests.refresh();
    Get.snackbar(
      'تم الرفض',
      'تم رفض طلب ${req.requesterName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE53935),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  int pendingRequestsCount(int eventId) {
    return getTicketRequests(eventId)
        .where((r) => r.status == 'pending')
        .length;
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  void toggleSponsorFavorite(ExhibitionSponsorEvent e) {
    e.isFavorite = !e.isFavorite;
    exhibitionSponsorEvents.refresh();
  }

  String statusLabel(String status) {
    switch (status) {
      case 'approved': return 'مقبول';
      case 'pending':  return 'قيد المراجعة';
      case 'rejected': return 'مرفوض';
      case 'active':   return 'نشط';
      case 'ended':    return 'منتهٍ';
      default:         return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'approved':
      case 'active':   return const Color(0xFF4CAF50);
      case 'pending':  return const Color(0xFFF7941D);
      case 'rejected':
      case 'ended':    return const Color(0xFF888888);
      default:         return const Color(0xFF888888);
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    maxCtrl.dispose();
    seatsCtrl.dispose();
    ticketPriceCtrl.dispose();
    videoPromoCtrl.dispose();
    companyNameCtrl.dispose();
    companyWebCtrl.dispose();
    companyPhoneCtrl.dispose();
    productNamesCtrl.dispose();
    super.onClose();
  }
}
