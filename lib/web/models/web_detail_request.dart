enum WebDetailType {
  exhibition, booth, event, report,
  createEvent, ticketRequests, sponsorship, scanner,
  notifications, sponsorEvent, map,
  boothManagement, bookingRequest, bookingDetail,
  exhibitionEvents,
}

class WebDetailRequest {
  final WebDetailType type;
  final Object?       data;
  final Object?       extra;

  const WebDetailRequest(this.type, {this.data, this.extra});
}
