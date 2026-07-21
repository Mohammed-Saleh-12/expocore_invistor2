class EventModel {
  final int    id;
  final String name;
  final String type;
  final String boothNumber;
  final String exhibitionName;
  final String date;
  final String time;
  final int    maxParticipants;
  final int    registeredCount;
  final String status;
  final String description;
  final bool   requiresBooking;
  bool isFavorite;

  // Extended fields for investor's own events
  final String place;
  final int    durationDays;
  final bool   hasBookableSeats;
  final int    totalSeats;
  final int    bookedSeats;
  final int    soldTickets;
  final double ticketPrice;
  final bool   isGeneralInvitation;
  final String videoPromoUrl;
  final List<String> companyImages;
  final int    currentDay;
  final int    totalEventDays;
  final List<int> dailyAttendees;
  final int    scannedCount;

  EventModel({
    required this.id,
    required this.name,
    required this.type,
    required this.boothNumber,
    required this.exhibitionName,
    required this.date,
    required this.time,
    required this.maxParticipants,
    required this.registeredCount,
    required this.status,
    required this.description,
    required this.requiresBooking,
    this.isFavorite = false,
    this.place = '',
    this.durationDays = 1,
    this.hasBookableSeats = false,
    this.totalSeats = 0,
    this.bookedSeats = 0,
    this.soldTickets = 0,
    this.ticketPrice = 0,
    this.isGeneralInvitation = true,
    this.videoPromoUrl = '',
    this.companyImages = const [],
    this.currentDay = 1,
    this.totalEventDays = 1,
    this.dailyAttendees = const [],
    this.scannedCount = 0,
  });

  String get ticketCategory {
    if (ticketPrice > 0) return 'paid';
    if (hasBookableSeats || requiresBooking) return 'free';
    return 'none';
  }

  factory EventModel.fromJson(Map<String, dynamic> j) => EventModel(
    id:               j['id'],
    name:             j['name'] ?? '',
    type:             j['type'] ?? '',
    boothNumber:      j['booth_number'] ?? '',
    exhibitionName:   j['exhibition_name'] ?? '',
    date:             j['date'] ?? '',
    time:             j['time'] ?? '',
    maxParticipants:  j['max_participants'] ?? 0,
    registeredCount:  j['registered_count'] ?? 0,
    status:           j['status'] ?? 'upcoming',
    description:      j['description'] ?? '',
    requiresBooking:  j['requires_booking'] ?? false,
    isFavorite:       j['is_favorite'] ?? false,
    place:            j['place'] ?? '',
    durationDays:     j['duration_days'] ?? 1,
    hasBookableSeats: j['has_bookable_seats'] ?? false,
    totalSeats:       j['total_seats'] ?? 0,
    bookedSeats:      j['booked_seats'] ?? 0,
    soldTickets:      j['sold_tickets'] ?? 0,
    ticketPrice:      (j['ticket_price'] ?? 0).toDouble(),
    isGeneralInvitation: j['is_general_invitation'] ?? true,
    videoPromoUrl:    j['video_promo_url'] ?? '',
    companyImages:    List<String>.from(j['company_images'] ?? []),
    currentDay:       j['current_day'] ?? 1,
    totalEventDays:   j['total_event_days'] ?? 1,
    dailyAttendees:   List<int>.from(j['daily_attendees'] ?? []),
    scannedCount:     j['scanned_count'] ?? 0,
  );
}
