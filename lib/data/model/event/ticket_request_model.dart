class TicketRequestModel {
  final int id;
  final int eventId;
  final String requesterName;
  final String requesterPhone;
  final String requesterEmail;
  final String requestedAt;
  String status;
  String? qrCodeData;
  String? ticketNumber;

  TicketRequestModel({
    required this.id,
    required this.eventId,
    required this.requesterName,
    required this.requesterPhone,
    required this.requesterEmail,
    required this.requestedAt,
    this.status = 'pending',
    this.qrCodeData,
    this.ticketNumber,
  });
}
