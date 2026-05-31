import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../data/model/event/event_model.dart';
import '../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../data/model/event/sponsorship_booking_model.dart';
import '../../data/model/event/ticket_request_model.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../linkapi.dart';

class EventsController extends GetxController {
  final _crud = Crud();

  // ── Investor's own events ────────────────────────────────────────────
  final myEvents                = <EventModel>[].obs;
  // ── Exhibition sponsor events ────────────────────────────────────────
  final exhibitionSponsorEvents = <ExhibitionSponsorEvent>[].obs;
  // ── My booked sponsorships ───────────────────────────────────────────
  final mySponsorshipBookings   = <SponsorshipBookingModel>[].obs;
  // ── Ticket requests (event id → list) ────────────────────────────────
  final ticketRequests          = <int, List<TicketRequestModel>>{}.obs;
  // ── Investor's booths ─────────────────────────────────────────────────
  final myBooths                = <BoothModel>[].obs;

  // ── UI state ─────────────────────────────────────────────────────────
  final selectedTab  = 0.obs;
  final isLoading    = false.obs;
  final isCreating   = false.obs;
  final isBooking    = false.obs;
  final status       = StatusRequest.none.obs;

  // ── Create-event form ─────────────────────────────────────────────────
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

  // ── Exhibition / booth selection ──────────────────────────────────────
  final selectedExhibitionName = ''.obs;
  final selectedBooth          = Rxn<BoothModel>();

  // ── Sponsorship booking form ──────────────────────────────────────────
  final selectedSponsorDuration = Rxn<SponsorDurationOption>();
  final companyNameCtrl  = TextEditingController();
  final companyWebCtrl   = TextEditingController();
  final companyPhoneCtrl = TextEditingController();
  final productNamesCtrl = TextEditingController();
  final sponsorFormKey   = GlobalKey<FormState>();

  final eventTypes = [
    'ورشة عمل', 'عرض مباشر', 'مسابقة', 'ندوة',
    'حفل', 'مقابلة', 'لقاء B2B', 'مؤتمر',
  ];

  List<String> get myExhibitionNames =>
      myBooths.map((b) => b.exhibitionName).toSet().toList();

  List<BoothModel> get boothsForSelectedExhibition => myBooths
      .where((b) => b.exhibitionName == selectedExhibitionName.value)
      .toList();

  List<ExhibitionSponsorEvent> get myExhibitionSponsorEvents =>
      exhibitionSponsorEvents.where((e) =>
          myBooths.any((b) => b.exhibitionName == e.exhibitionName)).toList();

  @override
  void onInit() {
    _loadAll();
    super.onInit();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    await Future.wait([
      _loadMyEvents(),
      _loadSponsorEvents(),
      _loadSponsorships(),
      _loadBooths(),
    ]);
    isLoading.value = false;
    _prefillCompanyInfo();
  }

  Future<void> _loadMyEvents() async {
    final result = await _crud.getData(AppLink.investorEvents);
    if (result['status'] == true) {
      myEvents.value = _asList(result['data'])
          .map((e) => EventModel.fromJson(e))
          .toList();
    } else {
      myEvents.value = DummyData.events
          .where((e) => e.boothNumber.isNotEmpty)
          .toList();
    }
  }

  Future<void> _loadSponsorEvents() async {
    final result = await _crud.getData(AppLink.exhibitionSponsorEvents);
    if (result['status'] == true) {
      exhibitionSponsorEvents.value = _asList(result['data'])
          .map((e) => ExhibitionSponsorEvent.fromJson(e))
          .toList();
    } else {
      exhibitionSponsorEvents.value = List.from(DummyData.exhibitionSponsorEvents);
    }
  }

  Future<void> _loadSponsorships() async {
    final result = await _crud.getData(AppLink.investorSponsorships);
    if (result['status'] == true) {
      mySponsorshipBookings.value = _asList(result['data'])
          .map((e) => SponsorshipBookingModel.fromJson(e))
          .toList();
    } else {
      mySponsorshipBookings.value = List.from(DummyData.sponsorshipBookings);
    }
  }

  Future<void> _loadBooths() async {
    final result = await _crud.getData(AppLink.investorBookings);
    if (result['status'] == true) {
      myBooths.value = _asList(result['data'])
          .map((e) => BoothModel.fromJson(e))
          .toList();
    } else {
      myBooths.value = List.from(DummyData.myBooths);
    }
  }

  Future<void> _loadTicketRequests(int eventId) async {
    final result = await _crud.getData(AppLink.eventTicketRequests(eventId));
    if (result['status'] == true) {
      ticketRequests[eventId] = _asList(result['data'])
          .map((e) => TicketRequestModel.fromJson(e))
          .toList();
      ticketRequests.refresh();
    } else {
      ticketRequests[eventId] = List.from(DummyData.ticketRequests[eventId] ?? []);
      ticketRequests.refresh();
    }
  }

  void _prefillCompanyInfo() {
    if (companyNameCtrl.text.isEmpty) companyNameCtrl.text  = 'شركة التقنية المتقدمة';
    if (companyWebCtrl.text.isEmpty)  companyWebCtrl.text   = 'https://techadvanced.sa';
    if (companyPhoneCtrl.text.isEmpty) companyPhoneCtrl.text = '+966501234567';
  }

  // ── Create investor event ─────────────────────────────────────────────
  Future<void> createEvent() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedType.value.isEmpty) {
      _warn('يرجى اختيار نوع الفعالية'); return;
    }
    if (selectedExhibitionName.value.isEmpty) {
      _warn('يرجى اختيار المعرض'); return;
    }
    if (selectedBooth.value == null) {
      _warn('يرجى اختيار الجناح'); return;
    }

    isCreating.value = true;
    status.value = StatusRequest.loading;

    final b = selectedBooth.value!;
    final result = await _crud.postData(AppLink.investorEvents, {
      'name':                nameCtrl.text.trim(),
      'type':                selectedType.value,
      'booth_id':            b.id,
      'booth_number':        b.number,
      'exhibition_name':     selectedExhibitionName.value,
      'date':                selectedDate.value.isEmpty ? '2026-07-18' : selectedDate.value,
      'time':                selectedTime.value.isEmpty ? '10:00' : selectedTime.value,
      'max_participants':    int.tryParse(maxCtrl.text) ?? 100,
      'description':         descCtrl.text.trim(),
      'requires_booking':    hasBookableSeats.value,
      'duration_days':       selectedDuration.value,
      'has_bookable_seats':  hasBookableSeats.value,
      'total_seats':         int.tryParse(seatsCtrl.text) ?? 0,
      'ticket_price':        double.tryParse(ticketPriceCtrl.text) ?? 0,
      'is_general_invitation': isGeneralInvite.value,
      'video_promo_url':     videoPromoCtrl.text.trim(),
    });

    if (result['status'] == true) {
      status.value = StatusRequest.success;
      await _loadMyEvents();
      _resetCreateForm();
      Get.back();
      Get.snackbar('تم النشر', 'تم نشر الفعالية بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      status.value = StatusRequest.failure;
      _warn(result['message'] ?? 'فشل نشر الفعالية');
    }
    isCreating.value = false;
  }

  // ── Book a sponsorship slot ───────────────────────────────────────────
  Future<void> bookSponsorship(ExhibitionSponsorEvent event) async {
    if (selectedSponsorDuration.value == null) {
      _warn('يرجى اختيار مدة المشاركة'); return;
    }
    isBooking.value = true;

    final dur = selectedSponsorDuration.value!;
    final result = await _crud.postData(AppLink.investorSponsorships, {
      'event_id':               event.id,
      'selected_duration_label': dur.label,
      'selected_days':          dur.days,
      'price':                  dur.price,
      'company_name':           companyNameCtrl.text.trim(),
      'company_website':        companyWebCtrl.text.trim(),
      'company_phone':          companyPhoneCtrl.text.trim(),
      'product_names':          productNamesCtrl.text.trim(),
    });

    if (result['status'] == true) {
      await _loadSponsorships();
    } else {
      final booking = SponsorshipBookingModel(
        id:                    mySponsorshipBookings.length + 2000,
        eventId:               event.id,
        eventName:             event.name,
        eventType:             event.type,
        exhibitionName:        event.exhibitionName,
        date:                  event.date,
        place:                 event.place,
        time:                  event.startTime,
        selectedDurationLabel: dur.label,
        selectedDays:          dur.days,
        price:                 dur.price,
        status:                'pending',
        bookedAt:              '2026-07-01',
      );
      mySponsorshipBookings.add(booking);
    }

    isBooking.value = false;
    selectedSponsorDuration.value = null;
    Get.back();
    Get.snackbar('تم الحجز', 'تم إرسال طلب الرعاية للفعالية "${event.name}"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF));
  }

  // ── Ticket requests ───────────────────────────────────────────────────
  List<TicketRequestModel> getTicketRequests(int eventId) {
    if (!ticketRequests.containsKey(eventId)) {
      _loadTicketRequests(eventId);
    }
    return ticketRequests[eventId] ?? [];
  }

  Future<void> approveTicketRequest(TicketRequestModel req) async {
    final result = await _crud.patchData(
      AppLink.ticketRequestAction(req.eventId, req.id),
      {'action': 'approve'},
    );
    if (result['status'] == true) {
      final d = _body(result['data']);
      req.status       = d['status'] ?? 'approved';
      req.ticketNumber = d['ticket_number'] ?? 'ECT-${req.id.toString().padLeft(3, '0')}';
      req.qrCodeData   = d['qr_code_data'] ?? '${req.ticketNumber}-2026';
    } else {
      req.status       = 'approved';
      req.ticketNumber = 'ECT-${req.id.toString().padLeft(3, '0')}';
      req.qrCodeData   = '${req.ticketNumber}-2026';
    }
    ticketRequests.refresh();
    Get.snackbar('تم القبول', 'تم قبول طلب ${req.requesterName} وتوليد تذكرة QR',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF));
  }

  Future<void> rejectTicketRequest(TicketRequestModel req) async {
    await _crud.patchData(
      AppLink.ticketRequestAction(req.eventId, req.id),
      {'action': 'reject'},
    );
    req.status = 'rejected';
    ticketRequests.refresh();
    Get.snackbar('تم الرفض', 'تم رفض طلب ${req.requesterName}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: const Color(0xFFFFFFFF));
  }

  int pendingRequestsCount(int eventId) =>
      getTicketRequests(eventId).where((r) => r.status == 'pending').length;

  // ── Helpers ───────────────────────────────────────────────────────────
  void toggleSponsorFavorite(ExhibitionSponsorEvent e) {
    final wasFav = e.isFavorite;
    e.isFavorite = !wasFav;
    exhibitionSponsorEvents.refresh();
    if (wasFav) {
      _crud.deleteData(AppLink.favoriteEvent(e.id));
    } else {
      _crud.postData(AppLink.favoriteEvent(e.id), {});
    }
  }

  String statusLabel(String s) {
    const map = {
      'approved': 'مقبول', 'pending': 'قيد المراجعة',
      'rejected': 'مرفوض', 'active': 'نشط', 'ended': 'منتهٍ',
      'upcoming': 'قادم',
    };
    return map[s] ?? s;
  }

  Color statusColor(String s) {
    switch (s) {
      case 'approved': case 'active': return const Color(0xFF4CAF50);
      case 'pending':                 return const Color(0xFFF7941D);
      default:                        return const Color(0xFF888888);
    }
  }

  void _warn(String msg) => Get.snackbar('تنبيه', msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF7941D),
      colorText: const Color(0xFFFFFFFF));

  void _resetCreateForm() {
    nameCtrl.clear(); descCtrl.clear(); maxCtrl.clear();
    seatsCtrl.clear(); ticketPriceCtrl.clear(); videoPromoCtrl.clear();
    selectedType.value = ''; selectedDate.value = ''; selectedTime.value = '';
    selectedDuration.value = 1; hasBookableSeats.value = false;
    isGeneralInvite.value = true; selectedExhibitionName.value = '';
    selectedBooth.value = null;
  }

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  dynamic _body(dynamic data) =>
      (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});

  @override
  void onClose() {
    nameCtrl.dispose(); descCtrl.dispose(); maxCtrl.dispose();
    seatsCtrl.dispose(); ticketPriceCtrl.dispose(); videoPromoCtrl.dispose();
    companyNameCtrl.dispose(); companyWebCtrl.dispose();
    companyPhoneCtrl.dispose(); productNamesCtrl.dispose();
    super.onClose();
  }
}
