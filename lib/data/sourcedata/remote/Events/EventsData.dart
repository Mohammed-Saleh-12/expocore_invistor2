import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class EventsData {
  Crud crud;

  EventsData(this.crud);

  Future<Map<String, dynamic>> getInvestorEvents() async {
    return await crud.getData(AppLink.investorEvents);
  }

  Future<Map<String, dynamic>> createInvestorEvent(
    Map<String, dynamic> body,
  ) async {
    return await crud.postData(AppLink.investorEvents, body);
  }

  Future<Map<String, dynamic>> getSponsorEvents() async {
    return await crud.getData(AppLink.exhibitionSponsorEvents);
  }

  Future<Map<String, dynamic>> getSponsorships() async {
    return await crud.getData(AppLink.investorSponsorships);
  }

  Future<Map<String, dynamic>> createSponsorship(
    Map<String, dynamic> body,
  ) async {
    return await crud.postData(AppLink.investorSponsorships, body);
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
