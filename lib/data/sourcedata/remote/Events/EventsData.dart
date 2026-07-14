import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class EventsData {
  Crud crud;

  EventsData(this.crud);

  Future<Map<String, dynamic>> getInvestorEvents() async {
    return await crud.getData(AppLink.investorEvents);
  }

  Future<Map<String, dynamic>> createInvestorEvent({
    required String name,
    required String type,
    required int boothId,
    required String boothNumber,
    required String exhibitionName,
    required String date,
    required String time,
    required int maxParticipants,
    required String description,
    required bool requiresBooking,
    required int durationDays,
    required bool hasBookableSeats,
    required int totalSeats,
    required double ticketPrice,
    required bool isGeneralInvitation,
    required String ticketType,
    required int freeTicketLimit,
    required String videoPromoUrl,
  }) async {
    return await crud.postData(AppLink.investorEvents, {
      'name': name,
      'type': type,
      'booth_id': boothId,
      'booth_number': boothNumber,
      'exhibition_name': exhibitionName,
      'date': date,
      'time': time,
      'max_participants': maxParticipants,
      'description': description,
      'requires_booking': requiresBooking,
      'duration_days': durationDays,
      'has_bookable_seats': hasBookableSeats,
      'total_seats': totalSeats,
      'ticket_price': ticketPrice,
      'is_general_invitation': isGeneralInvitation,
      'ticket_type': ticketType,
      'free_ticket_limit': freeTicketLimit,
      'video_promo_url': videoPromoUrl,
    });
  }

  Future<Map<String, dynamic>> getSponsorEvents() async {
    return await crud.getData(AppLink.exhibitionSponsorEvents);
  }

  Future<Map<String, dynamic>> getSponsorships() async {
    return await crud.getData(AppLink.investorSponsorships);
  }

  Future<Map<String, dynamic>> createSponsorship({
    required int eventId,
    required String selectedDurationLabel,
    required int selectedDays,
    required double price,
    required String companyName,
    required String companyWebsite,
    required String companyPhone,
    required String productNames,
  }) async {
    return await crud.postData(AppLink.investorSponsorships, {
      'event_id': eventId,
      'selected_duration_label': selectedDurationLabel,
      'selected_days': selectedDays,
      'price': price,
      'company_name': companyName,
      'company_website': companyWebsite,
      'company_phone': companyPhone,
      'product_names': productNames,
    });
  }

  Future<Map<String, dynamic>> getTicketRequests(int eventId) async {
    return await crud.getData(AppLink.eventTicketRequests(eventId));
  }

  Future<Map<String, dynamic>> ticketRequestAction(
    int eventId,
    int requestId,
    String action,
  ) async {
    return await crud.patchData(
      AppLink.ticketRequestAction(eventId, requestId),
      {'action': action},
    );
  }

  Future<Map<String, dynamic>> addFavoriteEvent(int eventId) async {
    return await crud.postData(AppLink.favoriteEvent(eventId), {});
  }

  Future<Map<String, dynamic>> removeFavoriteEvent(int eventId) async {
    return await crud.deleteData(AppLink.favoriteEvent(eventId));
  }
}
