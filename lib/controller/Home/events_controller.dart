import 'dart:async';
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
import '../../data/sourcedata/remote/Favorites/FavoritesData.dart';
import '../../data/sourcedata/remote/Profile/ProfileData.dart';
import '../../data/sourcedata/remote/Exhibitions/ExhibitionsData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../core/services/services.dart';
import 'favorites_controller.dart';

class ProductItem {
  final TextEditingController nameCtrl;
  XFile? xFile;
  Uint8List? imageBytes;
  ProductItem() : nameCtrl = TextEditingController();
  void dispose() => nameCtrl.dispose();
}

class EventsController extends GetxController {
  final EventsData _eventsData = EventsData(Crud());
  final BoothsData _boothsData = BoothsData(Crud());
  final ProfileData _profileData = ProfileData(Crud());
  final ExhibitionsData _exhibitionsData = ExhibitionsData(Crud());
  final _exhibitionNameRequests = <int, Future<String?>>{};

  // ── Investor's own events ────────────────────────────────────────────
  final myEvents = <EventModel>[].obs;
  // ── Exhibition sponsor events ────────────────────────────────────────
  final exhibitionSponsorEvents = <ExhibitionSponsorEvent>[].obs;
  // ── My booked sponsorships ───────────────────────────────────────────
  final mySponsorshipBookings = <SponsorshipBookingModel>[].obs;
  // ── Ticket requests (event id → list) ────────────────────────────────
  final ticketRequests = <int, List<TicketRequestModel>>{}.obs;
  // ── Investor's booths ─────────────────────────────────────────────────
  final myBooths = <BoothModel>[].obs;

  // ── UI state ─────────────────────────────────────────────────────────
  final selectedTab = 0.obs;
  final isLoading = false.obs;
  final isLoadingSponsorEvents = false.obs;
  final isCreating = false.obs;
  final isBooking = false.obs;
  final status = StatusRequest.none.obs;
  final stepIndex = 0.obs;

  // ── Create-event form ─────────────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final maxCtrl = TextEditingController();
  final seatsCtrl = TextEditingController();
  final ticketPriceCtrl = TextEditingController();
  final videoPromoCtrl = TextEditingController();
  final freeLimitCtrl = TextEditingController(); // حد التذاكر الحرة
  final formKey = GlobalKey<FormState>();

  // ── Media ─────────────────────────────────────────────────────────────
  final pickedImages = <XFile>[].obs; // XFile يعمل على الويب والجوال
  final _picker = ImagePicker();
  static const int _maxImages = 6;

  Future<void> pickImages() async {
    if (pickedImages.length >= _maxImages) {
      _warn('event_max_images_warn'.trParams({'count': '$_maxImages'}));
      return;
    }
    final remaining = _maxImages - pickedImages.length;
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    // احتفظ بـ XFile مباشرةً (يعمل على الويب والجوال)
    pickedImages.addAll(picked.take(remaining));
  }

  void removeImage(int index) {
    if (index < pickedImages.length) pickedImages.removeAt(index);
  }

  final selectedType = ''.obs;
  final selectedDate = ''.obs; // تاريخ بداية الفعالية 'YYYY-MM-DD'
  final selectedEndDate = ''.obs; // تاريخ نهاية الفعالية 'YYYY-MM-DD'
  final selectedTime = ''.obs;
  final hasBookableSeats = false.obs;
  final isGeneralInvite = true.obs;

  // عدد أيام الفعالية (محسوب تلقائياً من تاريخ البداية والنهاية)
  int get eventDurationDays {
    final s = DateTime.tryParse(selectedDate.value);
    final e = DateTime.tryParse(selectedEndDate.value);
    if (s == null || e == null) return 0;
    final diff = e.difference(s).inDays + 1;
    return diff < 1 ? 1 : diff;
  }

  /// قائمة بتواريخ أيام فترة حجز الجناح المختار (اليوم 1، اليوم 2، ...)
  /// يُعيد قائمة فارغة إذا لم يُختر جناح أو كانت تواريخه غير صالحة.
  List<DateTime> get boothDayDates {
    final booth = selectedBooth.value;
    if (booth == null) return [];
    final start = DateTime.tryParse(booth.startDate);
    final end = DateTime.tryParse(booth.endDate);
    if (start == null || end == null) return [];
    final days = <DateTime>[];
    var current = start;
    while (!current.isAfter(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  /// نوع التذكرة: 'general' | 'paid' | 'free_limited'
  final ticketType = 'general'.obs;

  // ── Exhibition / booth selection ──────────────────────────────────────
  final selectedExhibitionName = ''.obs;
  final selectedBooth = Rxn<BoothModel>();

  // ── Web: sponsor-events search & filter ──────────────────────────────
  final sponsorSearchCtrl = TextEditingController();
  Timer? _sponsorSearchDebounce;
  final sponsorTypeFilter = 'الكل'.obs;

  /// RangeValues(0,0) = unset (full range)
  final sponsorPriceRange = const RangeValues(0, 0).obs;
  final sponsorDateStart = ''.obs; // 'YYYY-MM-DD' or ''
  final sponsorDateEnd = ''.obs; // 'YYYY-MM-DD' or ''

  /// Maximum price across all duration options (used as slider ceiling)
  double get sponsorComputedMaxPrice {
    if (exhibitionSponsorEvents.isEmpty) return 10000;
    double max = 0;
    for (final e in exhibitionSponsorEvents) {
      for (final d in e.durationOptions) {
        if (d.price > max) max = d.price;
      }
    }
    return max == 0 ? 10000 : max;
  }

  bool get _isPriceFiltered {
    final r = sponsorPriceRange.value;
    final top = sponsorComputedMaxPrice;
    return r.start > 0 || (r.end > 0 && r.end < top);
  }

  /// الفلترة المحلية: السعر فقط (النص + النوع + التاريخ تأتي مفلترةً من الـ API)
  List<ExhibitionSponsorEvent> get filteredSponsorEvents {
    if (!_isPriceFiltered) return exhibitionSponsorEvents.toList();
    final top = sponsorComputedMaxPrice;
    final r = sponsorPriceRange.value;
    final priceMin = r.start;
    final priceMax = (r.start == 0 && r.end == 0) ? top : r.end;
    return exhibitionSponsorEvents.where((e) {
      final eventMin = e.durationOptions.isNotEmpty
          ? e.durationOptions
                .map((d) => d.price)
                .reduce((a, b) => a < b ? a : b)
          : 0.0;
      return eventMin >= priceMin && eventMin <= priceMax;
    }).toList();
  }

  List<String> get availableSponsorTypes => [
    'الكل',
    ...exhibitionSponsorEvents.map((e) => e.type).toSet().toList(),
  ];

  int get sponsorActiveFilterCount =>
      (sponsorTypeFilter.value != 'الكل' ? 1 : 0) +
      (_isPriceFiltered ? 1 : 0) +
      (sponsorDateStart.value.isNotEmpty || sponsorDateEnd.value.isNotEmpty
          ? 1
          : 0);

  void onSponsorSearch(String _) {
    exhibitionSponsorEvents.refresh(); // فوري (فلترة السعر المحلية)
    _sponsorSearchDebounce?.cancel();
    _sponsorSearchDebounce = Timer(const Duration(milliseconds: 400), () {
      refreshSponsorEvents(); // API call بعد 400ms
    });
  }

  void setSponsorType(String v) {
    sponsorTypeFilter.value = v;
    refreshSponsorEvents();
  }

  void setSponsorPriceRange(RangeValues v) {
    sponsorPriceRange.value = v;
    exhibitionSponsorEvents.refresh();
  }

  void setSponsorDateStart(String v) {
    sponsorDateStart.value = v;
    refreshSponsorEvents();
  }

  void setSponsorDateEnd(String v) {
    sponsorDateEnd.value = v;
    refreshSponsorEvents();
  }

  void clearSponsorFilters() {
    sponsorTypeFilter.value = 'الكل';
    sponsorPriceRange.value = const RangeValues(0, 0);
    sponsorDateStart.value = '';
    sponsorDateEnd.value = '';
    sponsorSearchCtrl.clear();
    refreshSponsorEvents();
  }

  // ── Sponsorship booking form ──────────────────────────────────────────
  final selectedSponsorDuration = Rxn<SponsorDurationOption>();
  final companyNameCtrl = TextEditingController();
  final companyWebCtrl = TextEditingController();
  final companyPhoneCtrl = TextEditingController();
  final sponsorFormKey = GlobalKey<FormState>();

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
  final logoXFile = Rxn<XFile>();
  final adXFiles = <XFile>[].obs;
  final posterXFiles = <XFile>[].obs;

  // Cached bytes for fast redisplay without re-reading
  final _logoBytes = Rxn<Uint8List>();
  final _adBytes = <Uint8List>[].obs;
  final _posterBytes = <Uint8List>[].obs;

  Uint8List? get logoBytes => _logoBytes.value;
  List<Uint8List> get adBytes => _adBytes;
  List<Uint8List> get posterBytes => _posterBytes;

  Future<void> pickLogo() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
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
    if (adXFiles.length >= max) {
      _warn('الحد الأقصى للصور الإعلانية هو $max');
      return;
    }
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
    if (i < adXFiles.length) {
      adXFiles.removeAt(i);
      _adBytes.removeAt(i);
    }
  }

  Future<void> pickPosterImages() async {
    const max = 4;
    if (posterXFiles.length >= max) {
      _warn('الحد الأقصى للملصقات هو $max');
      return;
    }
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
    if (i < posterXFiles.length) {
      posterXFiles.removeAt(i);
      _posterBytes.removeAt(i);
    }
  }

  void _resetSponsorMedia() {
    logoXFile.value = null;
    _logoBytes.value = null;
    adXFiles.clear();
    _adBytes.clear();
    posterXFiles.clear();
    _posterBytes.clear();
    for (final p in productItems) p.dispose();
    productItems.clear();
  }

  final eventTypes = [
    'ورشة عمل',
    'عرض مباشر',
    'مسابقة',
    'ندوة',
    'حفل',
    'مقابلة',
    'لقاء B2B',
    'مؤتمر',
  ];

  List<String> get myExhibitionNames =>
      myBooths.map((b) => b.exhibitionName).toSet().toList();

  List<BoothModel> get boothsForSelectedExhibition => myBooths
      .where((b) => b.exhibitionName == selectedExhibitionName.value)
      .toList();

  List<ExhibitionSponsorEvent> get myExhibitionSponsorEvents =>
      exhibitionSponsorEvents
          .where(
            (e) => myBooths.any((b) => b.exhibitionName == e.exhibitionName),
          )
          .toList();

  Future<String?> getExhibitionName(int exhibitionId) {
    if (exhibitionId <= 0) return Future.value(null);
    return _exhibitionNameRequests.putIfAbsent(exhibitionId, () async {
      final result = await _exhibitionsData.getExhibitionDetail(exhibitionId);
      if (result['status'] != true) return null;
      final body = result['data'];
      final data = body is Map && body['data'] is Map ? body['data'] : body;
      if (data is! Map) return null;
      final exhibition = data['exhibition'];
      final name =
          data['name'] ??
          data['exhibition_name'] ??
          data['exhibitionName'] ??
          (exhibition is Map ? exhibition['name'] : null);
      final value = name?.toString().trim() ?? '';
      return value.isEmpty ? null : value;
    });
  }

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
      _loadCompanyInfo(),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadMyEvents() async {
    final result = await _eventsData.getInvestorEvents();
    if (result['status'] == true) {
      myEvents.value = _asList(
        result['data'],
      ).map((e) => EventModel.fromJson(e)).toList();
    } else {
      myEvents.value = DummyData.events
          .where((e) => e.boothNumber.isNotEmpty)
          .toList();
    }
  }

  Future<void> _loadSponsorEvents({int page = 1}) async {
    isLoadingSponsorEvents.value = true;
    final result = await _eventsData.getSponsorEvents(
      page: page,
      perPage: 20,
      type: sponsorTypeFilter.value == 'الكل' ? null : sponsorTypeFilter.value,
      dateStart: sponsorDateStart.value.isEmpty ? null : sponsorDateStart.value,
      dateEnd: sponsorDateEnd.value.isEmpty ? null : sponsorDateEnd.value,
      search: sponsorSearchCtrl.text.trim().isEmpty
          ? null
          : sponsorSearchCtrl.text.trim(),
    );
    if (result['status'] == true) {
      final body = result['data'];
      final list = _asList(body is Map ? (body['data'] ?? body) : body);
      debugPrint(
        '[SponsorEvents] response=${body.runtimeType}, items=${list.length}',
      );
      for (final item in list) {
        if (item is Map) {
          debugPrint(
            '[SponsorEvents] id=${item['id']} options=${item['duration_options'] ?? item['durationOptions']}',
          );
        }
      }
      if (page == 1) {
        exhibitionSponsorEvents.value = list
            .map((e) => ExhibitionSponsorEvent.fromJson(e))
            .toList();
        debugPrint(
          '[SponsorEvents] parsed=${exhibitionSponsorEvents.length}, options=${exhibitionSponsorEvents.isEmpty ? 0 : exhibitionSponsorEvents.first.durationOptions.length}',
        );
      } else {
        exhibitionSponsorEvents.addAll(
          list.map((e) => ExhibitionSponsorEvent.fromJson(e)),
        );
      }
      // تحديث totalPages إذا وُجدت البيانات
      if (body is Map) {
        final meta = body['meta'] ?? body['pagination'] ?? {};
        _sponsorTotalPages = meta['last_page'] ?? meta['total_pages'] ?? 1;
      }
    } else {
      if (page == 1) {
        exhibitionSponsorEvents.value = List.from(
          DummyData.exhibitionSponsorEvents,
        );
      }
    }
    isLoadingSponsorEvents.value = false;
  }

  // ── Sponsor Events Pagination ──────────────────────────────────────────
  int _sponsorCurrentPage = 1;
  int _sponsorTotalPages = 1;
  bool get hasSponsorMore => _sponsorCurrentPage < _sponsorTotalPages;
  final isLoadingSponsorMore = false.obs;

  Future<void> loadMoreSponsorEvents() async {
    if (!hasSponsorMore || isLoadingSponsorMore.value) return;
    isLoadingSponsorMore.value = true;
    _sponsorCurrentPage++;
    await _loadSponsorEvents(page: _sponsorCurrentPage);
    isLoadingSponsorMore.value = false;
  }

  Future<void> refreshSponsorEvents() async {
    _sponsorCurrentPage = 1;
    await _loadSponsorEvents(page: 1);
  }

  Future<void> _loadSponsorships() async {
    final result = await _eventsData.getSponsorships();
    if (result['status'] == true) {
      mySponsorshipBookings.value = _asList(
        result['data'],
      ).map((e) => SponsorshipBookingModel.fromJson(e)).toList();
    } else {
      mySponsorshipBookings.value = List.from(DummyData.sponsorshipBookings);
    }
  }

  SponsorshipBookingModel? sponsorshipForEvent(int eventId) {
    for (final booking in mySponsorshipBookings) {
      if (booking.eventId == eventId) return booking;
    }
    return null;
  }

  Future<void> _loadBooths() async {
    final result = await _boothsData.getMyBookings();
    if (result['status'] == true) {
      myBooths.value = _asList(
        result['data'],
      ).map((e) => BoothModel.fromJson(e)).toList();
    } else {
      myBooths.value = List.from(DummyData.myBooths);
    }
  }

  Future<void> _loadTicketRequests(int eventId) async {
    final result = await _eventsData.getTicketRequests(eventId);
    if (result['status'] == true) {
      ticketRequests[eventId] = _asList(
        result['data'],
      ).map((e) => TicketRequestModel.fromJson(e)).toList();
      ticketRequests.refresh();
    } else {
      ticketRequests[eventId] = List.from(
        DummyData.ticketRequests[eventId] ?? [],
      );
      ticketRequests.refresh();
    }
  }

  Future<void> _loadCompanyInfo() async {
    final result = await _profileData.getProfile();
    if (result['status'] == true) {
      final data = result['data'];
      final profile = data is Map && data['data'] is Map
          ? Map<String, dynamic>.from(data['data'])
          : data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      companyNameCtrl.text = (profile['company_name'] ?? profile['name'] ?? '')
          .toString();
      companyWebCtrl.text = (profile['website'] ?? profile['web_site'] ?? '')
          .toString();
      companyPhoneCtrl.text = (profile['phone'] ?? profile['mobile'] ?? '')
          .toString();
      return;
    }

    final storedCompany = Get.find<Services>().companyName;
    if (storedCompany.isNotEmpty) companyNameCtrl.text = storedCompany;
  }

  // ── Create investor event (الجوال: ينشر ثم يرجع) ──────────────────────
  Future<void> createEvent() async {
    final ok = await submitEvent();
    if (ok) Get.back();
  }

  // ── نشر الفعالية (مشترك بين الجوال والويب — نفس الـ API) ───────────────
  Future<bool> submitEvent() async {
    if (formKey.currentState != null && !formKey.currentState!.validate())
      return false;
    if (selectedType.value.isEmpty) {
      _warn('event_type_required'.tr);
      return false;
    }
    if (selectedExhibitionName.value.isEmpty) {
      _warn('event_exhibition_required'.tr);
      return false;
    }
    if (selectedBooth.value == null) {
      _warn('event_booth_required'.tr);
      return false;
    }

    // التحقق من تحديد تاريخي البداية والنهاية
    if (selectedDate.value.isEmpty) {
      _warn('يرجى تحديد تاريخ بداية الفعالية');
      return false;
    }
    if (selectedEndDate.value.isEmpty) {
      // إذا لم يُحدد تاريخ النهاية نعتبر الفعالية يوم واحد
      selectedEndDate.value = selectedDate.value;
    }

    // التحقق أن النهاية ليست قبل البداية
    final sDate = DateTime.tryParse(selectedDate.value);
    final eDate = DateTime.tryParse(selectedEndDate.value);
    if (sDate != null && eDate != null && eDate.isBefore(sDate)) {
      _warn('تاريخ النهاية يجب أن يكون بعد تاريخ البداية أو مساوياً له');
      return false;
    }

    // التحقق أن التواريخ ضمن فترة حجز الجناح
    final b = selectedBooth.value!;
    if (b.startDate.isNotEmpty && b.endDate.isNotEmpty) {
      final boothStart = DateTime.tryParse(b.startDate);
      final boothEnd = DateTime.tryParse(b.endDate);
      if (boothStart != null && boothEnd != null) {
        if (sDate != null && sDate.isBefore(boothStart)) {
          _warn(
            'تاريخ بداية الفعالية قبل بداية فترة حجز الجناح (${b.startDate})',
          );
          return false;
        }
        if (eDate != null && eDate.isAfter(boothEnd)) {
          _warn(
            'تاريخ نهاية الفعالية بعد نهاية فترة حجز الجناح (${b.endDate})',
          );
          return false;
        }
      }
    }

    isCreating.value = true;
    status.value = StatusRequest.loading;

    final result = await _eventsData.createInvestorEvent(
      name: nameCtrl.text.trim(),
      type: selectedType.value,
      boothId: b.id,
      boothNumber: b.number,
      exhibitionName: selectedExhibitionName.value,
      startDate: selectedDate.value,
      endDate: selectedEndDate.value,
      time: selectedTime.value.isEmpty ? '10:00' : selectedTime.value,
      maxParticipants: int.tryParse(maxCtrl.text) ?? 100,
      description: descCtrl.text.trim(),
      requiresBooking: ticketType.value != 'general',
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
      images: pickedImages.toList(), // ← multipart upload
    );

    bool success = false;
    if (result['status'] == true) {
      status.value = StatusRequest.success;
      await _loadMyEvents();
      _resetCreateForm();
      success = true;
      Get.snackbar(
        'event_published_title'.tr,
        'event_published_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );
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
    required int maxParticipants,
  }) {
    final ev = EventModel(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      name: name,
      type: type,
      boothNumber: myBooths.isNotEmpty ? myBooths.first.number : '',
      exhibitionName: myBooths.isNotEmpty ? myBooths.first.exhibitionName : '',
      date: date,
      time: '10:00',
      maxParticipants: maxParticipants,
      registeredCount: 0,
      status: 'upcoming',
      description: description,
      requiresBooking: false,
    );
    myEvents.insert(0, ev);
    Get.snackbar(
      'event_published_title'.tr,
      'sponsorship_booked_msg'.trParams({'name': name}),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  // ── Book sponsorship (الجوال: يحجز ثم يرجع) ───────────────────────────
  Future<void> bookSponsorship(ExhibitionSponsorEvent event) async {
    final ok = await submitSponsorship(event);
    if (ok) Get.back();
  }

  // ── حجز الرعاية (مشترك ويب/جوال — نفس الـ API، بدون تنقّل) ────────────
  Future<bool> submitSponsorship(ExhibitionSponsorEvent event) async {
    if (selectedSponsorDuration.value == null) {
      _warn('event_sponsor_duration_required'.tr);
      return false;
    }

    final companyName = companyNameCtrl.text.trim();
    final companyPhone = companyPhoneCtrl.text.trim();
    if (companyName.isEmpty) {
      _warn('يرجى إدخال اسم الشركة');
      return false;
    }
    if (companyPhone.isEmpty) {
      _warn('يرجى إدخال رقم جوال الشركة');
      return false;
    }
    isBooking.value = true;

    final dur = selectedSponsorDuration.value!;
    final result = await _eventsData.createSponsorship(
      eventId: event.id,
      selectedDurationLabel: dur.label,
      selectedDays: dur.days,
      price: dur.price,
      companyName: companyName,
      companyWebsite: companyWebCtrl.text.trim(),
      companyPhone: companyPhone,
      productNames: productItems
          .map((p) => p.nameCtrl.text.trim())
          .where((n) => n.isNotEmpty)
          .join(', '),
      // ── multipart media ─────────────────────────────────
      logo: logoXFile.value,
      adImages: adXFiles.toList(),
      posterImages: posterXFiles.toList(),
      productImages: productItems
          .where((p) => p.xFile != null)
          .map((p) => p.xFile!)
          .toList(),
    );

    if (result['status'] == true) {
      await _loadSponsorships();
    } else {
      isBooking.value = false;
      _warn(result['message'] ?? 'تعذر إرسال طلب الرعاية');
      return false;
    }

    isBooking.value = false;
    selectedSponsorDuration.value = null;
    _resetSponsorMedia();
    Get.snackbar(
      'sponsorship_booked_title'.tr,
      'sponsorship_booked_msg'.trParams({'name': event.name}),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
    );
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
      req.status = d['status'] ?? 'approved';
      req.ticketNumber =
          d['ticket_number'] ?? 'ECT-${req.id.toString().padLeft(3, '0')}';
      req.qrCodeData = d['qr_code_data'] ?? '${req.ticketNumber}-2026';
    } else {
      req.status = 'approved';
      req.ticketNumber = 'ECT-${req.id.toString().padLeft(3, '0')}';
      req.qrCodeData = '${req.ticketNumber}-2026';
    }
    ticketRequests.refresh();
    Get.snackbar(
      'ticket_approved_title'.tr,
      'ticket_approved_msg'.trParams({'name': req.requesterName}),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  Future<void> rejectTicketRequest(TicketRequestModel req) async {
    await _eventsData.ticketRequestAction(req.eventId, req.id, 'reject');
    req.status = 'rejected';
    ticketRequests.refresh();
    Get.snackbar(
      'ticket_rejected_title'.tr,
      'ticket_rejected_msg'.trParams({'name': req.requesterName}),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE53935),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  int pendingRequestsCount(int eventId) =>
      getTicketRequests(eventId).where((r) => r.status == 'pending').length;

  // ── Helpers ───────────────────────────────────────────────────────────
  void toggleSponsorFavorite(ExhibitionSponsorEvent e) {
    final wasFav = e.isFavorite;
    e.isFavorite = !wasFav;
    exhibitionSponsorEvents.refresh();
    final _fav = FavoritesData(Crud());
    if (wasFav) {
      _fav.removeFavorite(e.id, FavoriteType.sponsorEvent);
      if (Get.isRegistered<FavoritesController>()) {
        Get.find<FavoritesController>().favoriteEvents.removeWhere(
          (item) => item.id == e.id,
        );
      }
    } else {
      _fav.addFavorite(e.id, FavoriteType.sponsorEvent);
      if (Get.isRegistered<FavoritesController>()) {
        final favoritesController = Get.find<FavoritesController>();
        if (!favoritesController.isEventFavorited(e.id)) {
          favoritesController.favoriteEvents.add(e);
        }
      }
    }
  }

  String statusLabel(String s) {
    const map = {
      'approved': 'مقبول',
      'pending': 'قيد المراجعة',
      'rejected': 'مرفوض',
      'active': 'نشط',
      'ended': 'منتهٍ',
      'upcoming': 'قادم',
    };
    final arabic = map[s] ?? s;
    return arabic.tr;
  }

  Color statusColor(String s) {
    switch (s) {
      case 'approved':
      case 'active':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFF7941D);
      default:
        return const Color(0xFF888888);
    }
  }

  void _warn(String msg) => Get.snackbar(
    'snack_warning'.tr,
    msg,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFFF7941D),
    colorText: const Color(0xFFFFFFFF),
  );

  void _resetCreateForm() {
    nameCtrl.clear();
    descCtrl.clear();
    maxCtrl.clear();
    seatsCtrl.clear();
    ticketPriceCtrl.clear();
    videoPromoCtrl.clear();
    freeLimitCtrl.clear();
    pickedImages.clear();
    selectedType.value = '';
    selectedDate.value = '';
    selectedEndDate.value = '';
    selectedTime.value = '';
    hasBookableSeats.value = false;
    isGeneralInvite.value = true;
    ticketType.value = 'general';
    selectedExhibitionName.value = '';
    selectedBooth.value = null;
  }

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'];
      if (data['data'] is Map) return _asList(data['data']);
      if (data['pagination'] is Map && data['pagination']['data'] is List) {
        return data['pagination']['data'];
      }
    }
    return [];
  }

  dynamic _body(dynamic data) =>
      (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});

  @override
  void onClose() {
    _sponsorSearchDebounce?.cancel();
    nameCtrl.dispose();
    descCtrl.dispose();
    maxCtrl.dispose();
    seatsCtrl.dispose();
    ticketPriceCtrl.dispose();
    videoPromoCtrl.dispose();
    freeLimitCtrl.dispose();
    sponsorSearchCtrl.dispose();
    companyNameCtrl.dispose();
    companyWebCtrl.dispose();
    companyPhoneCtrl.dispose();
    _resetSponsorMedia();
    super.onClose();
  }
}
