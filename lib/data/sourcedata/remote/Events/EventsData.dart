import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';
import 'package:image_picker/image_picker.dart';

class EventsData {
  final Crud crud;
  EventsData(this.crud);

  // ── فعاليات المستثمر الخاصة ───────────────────────────────
  Future<Map<String, dynamic>> getInvestorEvents() async {
    return await crud.getData(AppLink.investorEvents);
  }

  /// إنشاء فعالية — مع صور اختيارية (multipart) أو بدونها (JSON).
  /// يُرسَل تاريخ البداية والنهاية بدلاً من عدد الأيام.
  Future<Map<String, dynamic>> createInvestorEvent({
    required String name,
    required String type,
    required int    boothId,
    required String boothNumber,
    required String exhibitionName,
    required String startDate,      // 'YYYY-MM-DD'
    required String endDate,        // 'YYYY-MM-DD' (= startDate إذا يوم واحد)
    required String time,
    required int    maxParticipants,
    required String description,
    required bool   requiresBooking,
    required bool   hasBookableSeats,
    required int    totalSeats,
    required double ticketPrice,
    required bool   isGeneralInvitation,
    required String ticketType,
    required int    freeTicketLimit,
    required String videoPromoUrl,
    List<XFile>     images = const [],
  }) async {
    final fields = <String, dynamic>{
      'name':                  name,
      'type':                  type,
      'booth_id':              boothId,
      'booth_number':          boothNumber,
      'exhibition_name':       exhibitionName,
      'start_date':            startDate,
      'end_date':              endDate,
      'time':                  time,
      'max_participants':      maxParticipants,
      'description':           description,
      'requires_booking':      requiresBooking,
      'has_bookable_seats':    hasBookableSeats,
      'total_seats':           totalSeats,
      'ticket_price':          ticketPrice,
      'is_general_invitation': isGeneralInvitation,
      'ticket_type':           ticketType,
      'free_ticket_limit':     freeTicketLimit,
      'video_promo_url':       videoPromoUrl,
    };

    if (images.isEmpty) {
      return await crud.postData(AppLink.investorEvents, fields);
    }

    return await crud.uploadData(
      AppLink.investorEvents,
      fields,
      files: images.map((f) => MapEntry('images[]', f)).toList(),
    );
  }

  // ── الفعاليات الإعلانية (Sponsor Events) — مع Pagination ───
  Future<Map<String, dynamic>> getSponsorEvents({
    int     page     = 1,
    int     perPage  = 15,
    String? type,
    String? dateStart,
    String? dateEnd,
  }) async {
    final params = <String, dynamic>{
      'page':     page,
      'per_page': perPage,
    };
    if (type      != null && type.isNotEmpty)      params['type']       = type;
    if (dateStart != null && dateStart.isNotEmpty) params['date_start'] = dateStart;
    if (dateEnd   != null && dateEnd.isNotEmpty)   params['date_end']   = dateEnd;
    return await crud.getData(AppLink.exhibitionSponsorEvents, params: params);
  }

  // ── رعايات المستثمر ───────────────────────────────────────
  Future<Map<String, dynamic>> getSponsorships() async {
    return await crud.getData(AppLink.investorSponsorships);
  }

  /// إنشاء رعاية — مع وسائط اختيارية (logo / صور إعلانية / ملصقات / صور منتجات).
  Future<Map<String, dynamic>> createSponsorship({
    required int    eventId,
    required String selectedDurationLabel,
    required int    selectedDays,
    required double price,
    required String companyName,
    required String companyWebsite,
    required String companyPhone,
    required String productNames,
    XFile?          logo,
    List<XFile>     adImages      = const [],
    List<XFile>     posterImages  = const [],
    List<XFile>     productImages = const [],
  }) async {
    final fields = <String, dynamic>{
      'event_id':                eventId,
      'selected_duration_label': selectedDurationLabel,
      'selected_days':           selectedDays,
      'price':                   price,
      'company_name':            companyName,
      'company_website':         companyWebsite,
      'company_phone':           companyPhone,
      'product_names':           productNames,
    };

    final files = <MapEntry<String, XFile>>[];
    if (logo != null) files.add(MapEntry('logo', logo));
    for (final f in adImages)      files.add(MapEntry('ad_images[]', f));
    for (final f in posterImages)  files.add(MapEntry('poster_images[]', f));
    for (final f in productImages) files.add(MapEntry('product_images[]', f));

    if (files.isEmpty) {
      return await crud.postData(AppLink.investorSponsorships, fields);
    }

    return await crud.uploadData(
      AppLink.investorSponsorships,
      fields,
      files: files,
    );
  }

  Future<Map<String, dynamic>> cancelSponsorship(int id) async {
    return await crud.patchData(AppLink.cancelSponsorship(id), {});
  }

  // ── طلبات تذاكر الفعالية ──────────────────────────────────
  Future<Map<String, dynamic>> getTicketRequests(int eventId) async {
    return await crud.getData(AppLink.eventTicketRequests(eventId));
  }

  Future<Map<String, dynamic>> ticketRequestAction(
    int    eventId,
    int    requestId,
    String action,
  ) async {
    return await crud.patchData(
      AppLink.ticketRequestAction(eventId, requestId),
      {'action': action},
    );
  }
}
