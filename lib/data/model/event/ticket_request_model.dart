class TicketRequestModel {
  final int    id;
  final int    eventId;
  final String requesterName;
  final String requesterPhone;
  final String requesterEmail;
  final String requestedAt;
  String  status;
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

  factory TicketRequestModel.fromJson(Map<String, dynamic> j) =>
      TicketRequestModel(
        id:             j['id'] ?? 0,
        eventId:        j['event_id'] ?? 0,
        requesterName:  j['requester_name'] ?? '',
        requesterPhone: j['requester_phone'] ?? '',
        requesterEmail: j['requester_email'] ?? '',
        requestedAt:    j['requested_at'] ?? '',
        status:         j['status'] ?? 'pending',
        qrCodeData:     j['qr_code_data'],
        ticketNumber:   j['ticket_number'],
      );
}
