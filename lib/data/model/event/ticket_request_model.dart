import 'package:intl/intl.dart';

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

  String get formattedRequestedAt {
    final date = DateTime.tryParse(requestedAt);
    return date == null ? requestedAt : DateFormat('dd/MM/yyyy').format(date);
  }

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

  factory TicketRequestModel.fromJson(
    Map<String, dynamic> j,
  ) => TicketRequestModel(
    id: _intValue(j['id']),
    eventId: _intValue(j['event_id']),
    requesterName: _stringValue(j['requester_name'] ?? j['visitor_name']),
    requesterPhone: _stringValue(j['requester_phone'] ?? j['visitor_phone']),
    requesterEmail: _stringValue(j['requester_email'] ?? j['visitor_email']),
    requestedAt: _stringValue(j['requested_at'] ?? j['booked_at']),
    status: _stringValue(j['status'], fallback: 'pending'),
    qrCodeData: _nullableString(j['qr_code_data'] ?? j['qr_code']),
    ticketNumber: _nullableString(j['ticket_number']),
  );

  static int _intValue(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  static String _stringValue(dynamic value, {String fallback = ''}) =>
      value?.toString() ?? fallback;

  static String? _nullableString(dynamic value) =>
      value == null ? null : value.toString();
}
