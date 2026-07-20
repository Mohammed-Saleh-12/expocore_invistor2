import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../data/model/event/event_model.dart';
import '../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../data/model/event/sponsorship_booking_model.dart';
import '../../data/model/event/ticket_request_model.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/sourcedata/remote/Booths/BoothsData.dart';
import '../../data/sourcedata/remote/Events/EventsData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class ProductItem {
  final TextEditingController nameCtrl;
  XFile?     xFile;
  Uint8List? imageBytes;
  ProductItem() : nameCtrl = TextEditingController();
  void dispose() => nameCtrl.dispose();
}

class EventsController extends GetxController {
  final EventsData _eventsData = EventsData(Crud());
  final BoothsData _boothsData = BoothsData(Crud());

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
  final stepIndex    = 0.obs;

  // ── Create-event form ─────────────────────────────────────────────────
  final nameCtrl            = TextEditingController();
  final descCtrl            = TextEditingController();
  final maxCtrl             = TextEditingController();
  final seatsCtrl           = TextEditingController();
  final ticketPriceCtrl     = TextEditingController();
  final videoPromoCtrl      = TextEditingController();
  final freeLimitCtrl       = TextEditingController(); // حد التذاكر الحرة
  final formKey             = GlobalKey<FormState>();

  // ── Media ─────────────────────────────────────────────────────────────
  final pickedImages        = <File>[].obs;
  final _picker             = ImagePicker();
  static const int _maxImages = 6;

  Future<void> pickImages() async {
    if (pickedImages.length >= _maxImages) {
      _warn('event_max_images_warn'.trParams({'count': '$_maxImages'})); return;
    }
    final remaining = _maxImages - pickedImages.length;
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    final limited = picked.take(remaining).map((x) => File(x.path)).toList();
    pickedImages.addAll(limited);
  }

  void removeImage(int index) {
    if (index < pickedImages.length) pickedImages.removeAt(index);
  }
  final selectedType        = ''.obs;
  final selectedDate        = ''.obs;
  final selectedEndDate     = ''.obs;
  final selectedTime        = ''.obs;
  final selectedDuration    = 1.obs;
  final hasBookableSeats    = false.obs;
  final isGeneralInvite     = true.obs;

  /// نوع التذكرة: 'general' | 'paid' | 'free_limited'
  final ticketType          = 'general'.obs;

  // ── Exhibition / booth selection ──────────────────────────────────────
  final selectedExhibitionName = ''.obs;
  final selectedBooth          = Rxn<BoothModel>();

  // ── Sponsorship booking form ──────────────────────────────────────────
  final selectedSponsorDuration = Rxn<SponsorDurationOption>();
  final companyNameCtrl  = TextEditingController();
  final companyWebCtrl   = TextEditingController();
  final companyPhoneCtrl = TextEditingController();
  final sponsorFormKey   = GlobalKey<FormState>();

  // ── Product items (image + name each) ────────────────────────────────
  final productItems = <ProductItem>[].obs;

  void addProductItem() {
    if (productItems.length >= 10) return;
    productItems.add(ProductItem());
  }

  void removeProductItem(int i) {
    if (i < productItems.length) {
      productItems[i].dispose();
      productItems.removeAt(i);
    }
  }

  Future<void> pickProductImage(int i) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    productItems[i].xFile = picked;
    productItems[i].imageBytes = await picked.readAsBytes();
    productItems.refresh();
  }

  // ── Sponsorship media (cross-platform XFile) ──────────────────────────
  final logoXFile      = Rxn<XFile>();
  final adXFiles       = <XFile>[].obs;
  final posterXFiles   = <XFile>[].obs;

  // Cached bytes for fast redisplay without re-reading
  final _logoBytes    = Rxn<Uint8List>();
  final _adBytes      = <Uint8List>[].obs;
  final _posterBytes  = <Uint8List>[].obs;

  Uint8List? get logoBytes => _logoBytes.value;
  List<Uint8List> get adBytes => _adBytes;
  List<Uint8List> get posterBytes => _posterBytes;

  Future<void> pickLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    logoXFile.value = picked;
    _logoBytes.value = await picked.readAsBytes();
  }

  void removeLogo() {
    logoXFile.value = null;
    _logoBytes.value = null;
  }

  Future<void> pickAdImages() async {
    const max = 6;
    if (adXFiles.length >= max) { _warn('الحد الأقصى للصور الإعلانية هو $max'); return; }
    final remaining = max - adXFiles.length;
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    final limited = picked.take(remaining).toList();
    for (final f in limited) {
      adXFiles.add(f);
      _adBytes.add(await f.readAsBytes());
    }
  }

  void removeAdFile(int i) {
    if (i < adXFiles.length) { adXFiles.removeAt(i); _adBytes.removeAt(i); }
  }

  Future<void> pickPosterImages() async {
    const max = 4;
    if (posterXFiles.length >= max) { _warn('الحد الأقصى للملصقات هو $max'); return; }
    final remaining = max - posterXFiles.length;
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    final limited = picked.take(remaining).toList();
    for (final f in limited) {
      posterXFiles.add(f);
      _posterBytes.add(await f.readAsBytes());
    }
  }

  void removePosterFile(int i) {
    if (i < posterXFiles.length) { posterXFiles.removeAt(i); _posterBytes.removeAt(i); }
  }

  void _resetSponsorMedia() {
    logoXFile.value = null; _logoBytes.value = null;
    adXFiles.clear(); _adBytes.clear();
    posterXFiles.clear(); _posterBytes.clear();
    for (final p in productItems) p.dispose();
    productItems.clear();
  }

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
    final result = await _eventsData.getInvestorEvents();
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
    final result = await _eventsData.getSponsorEvents();
    if (result['status'] == true) {
      exhibitionSponsorEvents.value = _asList(result['data'])
          .map((e) => ExhibitionSponsorEvent.fromJson(e))
          .toList();
    } else {
      exhibitionSponsorEvents.value = List.from(DummyData.exhibitionSponsorEvents);
    }
  }

  Future<void> _loadSponsorships() async {
    final result = await _eventsData.getSponsorships();
    if (result['status'] == true) {
      mySponsorshipBookings.value = _asList(result['data'])
          .map((e) => SponsorshipBookingModel.fromJson(e))
          .toList();
    } else {
      mySponsorshipBookings.value = List.from(DummyData.sponsorshipBookings);
    }
  }

  Future<void> _loadBooths() async {
    final result = await _boothsData.getMyBookings();
    if (result['status'] == true) {
      myBooths.value = _asList(result['data'])
          .map((e) => BoothModel.fromJson(e))
          .toList();
    } else {
      myBooths.value = List.from(DummyData.myBooths);
    }
  }

  Future<void> _loadTicketRequests(int eventId) async {
    final result = await _eventsData.getTicketRequests(eventId);
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

  // ── Create investor event (الجوال: ينشر ثم يرجع) ──────────────────────
  Future<void> createEvent() async {
    final ok = await submitEvent();
    if (ok) Get.back();
  }

  // ── نشر الفعالية (مشترك بين الجوال والويب — نفس الـ API) ───────────────
  Future<bool> submitEvent() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) return false;
    if (selectedType.value.isEmpty) {
      _warn('event_type_required'.tr); return false;
    }
    if (selectedExhibitionName.value.isEmpty) {
      _warn('event_exhibition_required'.tr); return false;
    }
    if (selectedBooth.value == null) {
      _warn('event_booth_required'.tr); return false;
    }

    isCreating.value = true;
    status.value = StatusRequest.loading;

    final b = selectedBooth.value!;
    final result = await _eventsData.createInvestorEvent(
      name: nameCtrl.text.trim(),
      type: selectedType.value,
      boothId: b.id,
      boothNumber: b.number,
      exhibitionName: selectedExhibitionName.value,
      date: selectedDate.value.isEmpty ? '2026-07-18' : selectedDate.value,
      time: selectedTime.value.isEmpty ? '10:00' : selectedTime.value,
      maxParticipants: int.tryParse(maxCtrl.text) ?? 100,
      description: descCtrl.text.trim(),
      requiresBooking: ticketType.value != 'general',
      durationDays: selectedDuration.value,
      hasBookableSeats: ticketType.value == 'paid',
      totalSeats: int.tryParse(seatsCtrl.text) ?? 0,
      ticketPrice: ticketType.value == 'paid'
          ? (double.tryParse(ticketPriceCtrl.text) ?? 0)
          : 0,
      isGeneralInvitation: ticketType.value == 'general',
      ticketType: ticketType.value,
      freeTicketLimit: ticketType.value == 'free_limited'
          ? (int.tryParse(freeLimitCtrl.text) ?? 100)
          : 0,
      videoPromoUrl: videoPromoCtrl.text.trim(),
    );

    bool success = false;
    if (result['status'] == true) {
      status.value = StatusRequest.success;
      await _loadMyEvents();
      _resetCreateForm();
      success = true;
      Get.snackbar('event_published_title'.tr, 'event_published_msg'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      status.value = StatusRequest.failure;
      _warn(result['message'] ?? 'event_publish_fail_msg'.tr);
    }
    isCreating.value = false;
    return success;
  }

  // ── نشر فعالية سريعة من الويب ─────────────────────────────────────────
  void addQuickWebEvent({
    required String name,
    required String type,
    required String date,
    required String description,
    required int    maxParticipants,
  }) {
    final ev = EventModel(
      id:              DateTime.now().millisecondsSinceEpoch % 100000,
      name:            name,
      type:            type,
      boothNumber:     myBooths.isNotEmpty ? myBooths.first.number : '',
      exhibitionName:  myBooths.isNotEmpty ? myBooths.first.exhibitionName : '',
      date:            date,
      time:            '10:00',
      maxParticipants: maxParticipants,
      registeredCount: 0,
      status:          'upcoming',
      description:     description,
      requiresBooking: false,
    );
    myEvents.insert(0, ev);
    Get.snackbar('event_published_title'.tr,
        'sponsorship_booked_msg'.trParams({'name': name}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF));
  }

  // ── Book sponsorship (الجوال: يحجز ثم يرجع) ───────────────────────────
  Future<void> bookSponsorship(ExhibitionSponsorEvent event) async {
    final ok = await submitSponsorship(event);
    if (ok) Get.back();
  }

  // ── حجز الرعاية (مشترك ويب/جوال — نفس الـ API، بدون تنقّل) ────────────
  Future<bool> submitSponsorship(ExhibitionSponsorEvent event) async {
    if (selectedSponsorDuration.value == null) {
      _warn('event_sponsor_duration_required'.tr); return false;
    }
    isBooking.value = true;

    final dur = selectedSponsorDuration.value!;
    final result = await _eventsData.createSponsorship(
      eventId: event.id,
      selectedDurationLabel: dur.label,
      selectedDays: dur.days,
      price: dur.price,
      companyName: companyNameCtrl.text.trim(),
      companyWebsite: companyWebCtrl.text.trim(),
      companyPhone: companyPhoneCtrl.text.trim(),
      productNames: productItems
          .map((p) => p.nameCtrl.text.trim())
          .where((n) => n.isNotEmpty)
          .join(', '),
    );

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
    _resetSponsorMedia();
    Get.snackbar('sponsorship_booked_title'.tr,
        'sponsorship_booked_msg'.trParams({'name': event.name}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF));
    return true;
  }

  // ── Ticket requests ───────────────────────────────────────────────────
  List<TicketRequestModel> getTicketRequests(int eventId) {
    if (!ticketRequests.containsKey(eventId)) {
      _loadTicketRequests(eventId);
    }
    return ticketRequests[eventId] ?? [];
  }

  Future<void> approveTicketRequest(TicketRequestModel req) async {
    final result = await _eventsData.ticketRequestAction(
      req.eventId,
      req.id,
      'approve',
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
    Get.snackbar('ticket_approved_title'.tr,
        'ticket_approved_msg'.trParams({'name': req.requesterName}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF));
  }

  Future<void> rejectTicketRequest(TicketRequestModel req) async {
    await _eventsData.ticketRequestAction(req.eventId, req.id, 'reject');
    req.status = 'rejected';
    ticketRequests.refresh();
    Get.snackbar('ticket_rejected_title'.tr,
        'ticket_rejected_msg'.trParams({'name': req.requesterName}),
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
      _eventsData.removeFavoriteEvent(e.id);
    } else {
      _eventsData.addFavoriteEvent(e.id);
    }
  }

  String statusLabel(String s) {
    const map = {
      'approved': 'مقبول', 'pending': 'قيد المراجعة',
      'rejected': 'مرفوض', 'active': 'نشط', 'ended': 'منتهٍ',
      'upcoming': 'قادم',
    };
    final arabic = map[s] ?? s;
    return arabic.tr;
  }

  Color statusColor(String s) {
    switch (s) {
      case 'approved': case 'active': return const Color(0xFF4CAF50);
      case 'pending':                 return const Color(0xFFF7941D);
      default:                        return const Color(0xFF888888);
    }
  }

  void _warn(String msg) => Get.snackbar('snack_warning'.tr, msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF7941D),
      colorText: const Color(0xFFFFFFFF));

  void _resetCreateForm() {
    nameCtrl.clear(); descCtrl.clear(); maxCtrl.clear();
    seatsCtrl.clear(); ticketPriceCtrl.clear(); videoPromoCtrl.clear();
    freeLimitCtrl.clear(); pickedImages.clear();
    selectedType.value = ''; selectedDate.value = ''; selectedEndDate.value = '';
    selectedTime.value = '';
    selectedDuration.value = 1; hasBookableSeats.value = false;
    isGeneralInvite.value = true; ticketType.value = 'general';
    selectedExhibitionName.value = ''; selectedBooth.value = null;
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
    freeLimitCtrl.dispose();
    companyNameCtrl.dispose(); companyWebCtrl.dispose();
    companyPhoneCtrl.dispose();
    _resetSponsorMedia();
    super.onClose();
  }
}
