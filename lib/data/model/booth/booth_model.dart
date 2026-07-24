class BoothModel {
  final int    id;
  final String number;
  final String exhibitionName;
  final String imageUrl;
  final double area;
  final String status;
  final double price;
  final String startDate;
  final String endDate;
  final String location;
  final List<String> amenities;
  bool isFavorite;

  // ── Booking-specific fields (مُعبَّأة من GET /investor/bookings) ──────
  final int    bookingId;
  final String bookingNumber;
  final String bookedAt;
  final int    durationDays;
  final double servicesPrice;
  final double totalPrice;
  final double paidAmount;
  final double remainingAmount;
  final bool   screenService;
  final bool   setupService;
  final bool   securityService;
  final bool   cleaningService;
  final String notes;
  final List<String> bookedServices;

  BoothModel({
    required this.id,
    required this.number,
    required this.exhibitionName,
    required this.imageUrl,
    required this.area,
    required this.status,
    required this.price,
    this.startDate       = '',
    required this.endDate,
    required this.location,
    required this.amenities,
    this.isFavorite      = false,
    // Booking fields
    this.bookingId       = 0,
    this.bookingNumber   = '',
    this.bookedAt        = '',
    this.durationDays    = 0,
    this.servicesPrice   = 0,
    this.totalPrice      = 0,
    this.paidAmount      = 0,
    this.remainingAmount = 0,
    this.screenService   = false,
    this.setupService    = false,
    this.securityService = false,
    this.cleaningService = false,
    this.notes           = '',
    this.bookedServices  = const [],
  });

  factory BoothModel.fromJson(Map<String, dynamic> j) => BoothModel(
    id:             j['id'],
    number:         j['number'] ?? '',
    exhibitionName: j['exhibition_name'] ?? '',
    imageUrl:       j['image_url'] ?? '',
    area:           (j['area'] ?? 0).toDouble(),
    status:         j['status'] ?? 'available',
    price:          (j['price'] ?? 0).toDouble(),
    startDate:      j['start_date'] ?? '',
    endDate:        j['end_date'] ?? '',
    location:       j['location'] ?? '',
    amenities:      List<String>.from(j['amenities'] ?? []),
    isFavorite:     j['is_favorite'] ?? false,
    // Booking fields
    bookingId:       j['booking_id'] ?? 0,
    bookingNumber:   j['booking_number'] ?? '',
    bookedAt:        j['booked_at'] ?? '',
    durationDays:    j['duration_days'] ?? 0,
    servicesPrice:   (j['services_price'] ?? 0).toDouble(),
    totalPrice:      (j['total_price'] ?? 0).toDouble(),
    paidAmount:      (j['paid_amount'] ?? 0).toDouble(),
    remainingAmount: (j['remaining_amount'] ?? 0).toDouble(),
    screenService:   j['screen_service'] ?? false,
    setupService:    j['setup_service'] ?? false,
    securityService: j['security_service'] ?? false,
    cleaningService: j['cleaning_service'] ?? false,
    notes:           j['notes'] ?? '',
    bookedServices:  List<String>.from(j['booked_services'] ?? []),
  );
}
