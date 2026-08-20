class SponsorshipBookingModel {
  final int    id;
  final int    eventId;
  final String eventName;
  final String eventType;
  final String exhibitionName;
  final String date;
  final String startDate;
  final String endDate;
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
  final int capacity;
  final int registeredCount;
  final int scannedCount;
  final String ticketType;
  final double ticketPrice;
  final List<Map<String, dynamic>> durationOptions;
  final List<String> eventImages;
  final List<Map<String, dynamic>> activities;

  SponsorshipBookingModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.eventType,
    required this.exhibitionName,
    required this.date,
    this.startDate = '',
    this.endDate = '',
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
    this.capacity = 0,
    this.registeredCount = 0,
    this.scannedCount = 0,
    this.ticketType = 'invitation',
    this.ticketPrice = 0,
    this.durationOptions = const [],
    this.eventImages = const [],
    this.activities = const [],
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

  factory SponsorshipBookingModel.fromJson(Map<String, dynamic> json) {
    final nested = json['event'] is Map
        ? Map<String, dynamic>.from(json['event'])
        : <String, dynamic>{};
    final j = {...nested, ...json};
    final images = j['event_images'] ?? j['images'] ?? [];
    return SponsorshipBookingModel(
        id:                    _toInt(j['id']),
        eventId:               _toInt(j['event_id'] ?? j['eventId']),
        eventName:             (j['event_name'] ?? j['name'] ?? j['title'] ?? '').toString(),
        eventType:             (j['event_type'] ?? j['type'] ?? '').toString(),
        exhibitionName:        (j['exhibition_name'] ?? j['exhibitionName'] ?? j['exhibition'] ?? '').toString(),
        date:                  (j['date'] ?? j['start_date'] ?? '').toString(),
        startDate:             (j['start_date'] ?? j['startAt'] ?? j['date'] ?? '').toString(),
        endDate:               (j['end_date'] ?? j['endAt'] ?? j['date'] ?? '').toString(),
        place:                 (j['place'] ?? j['venueName'] ?? '').toString(),
        time:                  (j['time'] ?? '').toString(),
        selectedDurationLabel: (j['selected_duration_label'] ?? '').toString(),
        selectedDays:          _toInt(j['selected_days'], 1),
        price:                 _toDouble(j['price']),
        status:                (j['status'] ?? 'pending').toString(),
        bookedAt:              (j['booked_at'] ?? '').toString(),
        totalVisitors:         _toInt(j['total_visitors']),
        totalAttendees:        _toInt(j['total_attendees']),
        dailyVisitors:         (j['daily_visitors'] as List? ?? []).map(_toInt).toList(),
        currentDay:            _toInt(j['current_day'], 1),
        totalDays:             _toInt(j['total_days'], 1),
        capacity:              _toInt(j['capacity']),
        registeredCount:       _toInt(j['registered_count']),
        scannedCount:          _toInt(j['scanned_count']),
        ticketType:            (j['ticket_type'] ?? 'invitation').toString(),
        ticketPrice:           _toDouble(j['ticket_price']),
        durationOptions:       (j['duration_options'] as List? ?? [])
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList(),
        eventImages:           (images is List ? images : const []).map((image) {
          if (image is Map) return (image['url'] ?? '').toString();
          return image.toString();
        }).where((image) => image.isNotEmpty).toList(),
        activities:            (j['activities'] as List? ?? [])
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList(),
        );
      }

    static int _toInt(dynamic value, [int fallback = 0]) => value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '') ?? fallback;

  static double _toDouble(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;

  Map<String, dynamic> toJson() => {
    'event_id':               eventId,
    'selected_duration_label': selectedDurationLabel,
    'selected_days':          selectedDays,
    'price':                  price,
  };
}
