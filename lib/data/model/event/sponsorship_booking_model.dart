class SponsorshipBookingModel {
  final int    id;
  final int    eventId;
  final String eventName;
  final String eventType;
  final String exhibitionName;
  final String date;
  final String place;
  final String time;
  final String selectedDurationLabel;
  final int    selectedDays;
  final double price;
  String status;
  final String bookedAt;
  final int    totalVisitors;
  final int    totalAttendees;
  final List<int> dailyVisitors;
  final int    currentDay;
  final int    totalDays;

  SponsorshipBookingModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.eventType,
    required this.exhibitionName,
    required this.date,
    required this.place,
    required this.time,
    required this.selectedDurationLabel,
    required this.selectedDays,
    required this.price,
    this.status = 'pending',
    required this.bookedAt,
    this.totalVisitors = 0,
    this.totalAttendees = 0,
    this.dailyVisitors = const [],
    this.currentDay = 1,
    this.totalDays = 3,
  });

  // ── Domain helpers (منطق النطاق — لا تبعيات واجهة) ─────────
  String get statusLabel {
    switch (status) {
      case 'approved':
      case 'confirmed':
      case 'active':   return 'مقبول';
      case 'pending':  return 'قيد المراجعة';
      case 'rejected': return 'مرفوض';
      default:         return status;
    }
  }

  factory SponsorshipBookingModel.fromJson(Map<String, dynamic> j) =>
      SponsorshipBookingModel(
        id:                    j['id'] ?? 0,
        eventId:               j['event_id'] ?? 0,
        eventName:             j['event_name'] ?? '',
        eventType:             j['event_type'] ?? '',
        exhibitionName:        j['exhibition_name'] ?? '',
        date:                  j['date'] ?? '',
        place:                 j['place'] ?? '',
        time:                  j['time'] ?? '',
        selectedDurationLabel: j['selected_duration_label'] ?? '',
        selectedDays:          j['selected_days'] ?? 1,
        price:                 (j['price'] ?? 0).toDouble(),
        status:                j['status'] ?? 'pending',
        bookedAt:              j['booked_at'] ?? '',
        totalVisitors:         j['total_visitors'] ?? 0,
        totalAttendees:        j['total_attendees'] ?? 0,
        dailyVisitors:         List<int>.from(j['daily_visitors'] ?? []),
        currentDay:            j['current_day'] ?? 1,
        totalDays:             j['total_days'] ?? 1,
      );

  Map<String, dynamic> toJson() => {
    'event_id':               eventId,
    'selected_duration_label': selectedDurationLabel,
    'selected_days':          selectedDays,
    'price':                  price,
  };
}
