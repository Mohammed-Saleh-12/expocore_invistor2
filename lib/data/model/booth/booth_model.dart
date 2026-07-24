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

  // ── Dynamic services for booking (اسم الخدمة → سعرها) ────────
  /// يُرسَل من الـ API مع تفاصيل الجناح
  final Map<String, double> services;

  // ── Company info when booth is booked ────────────────────────
  final String? companyName;
  final String? companyEmail;
  final String? companyInitials;

  // ── Booking history fields (from GET /investor/bookings) ──────
  final int    bookingId;
  final String bookingNumber;
  final String bookedAt;
  final int    durationDays;
  final double servicesPrice;
  final double totalPrice;
  final double paidAmount;
  final double remainingAmount;
  final List<String> bookedServices;  // الخدمات التي تم اختيارها في الحجز
  final String notes;

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
    this.services        = const {},
    this.companyName,
    this.companyEmail,
    this.companyInitials,
    // Booking history
    this.bookingId       = 0,
    this.bookingNumber   = '',
    this.bookedAt        = '',
    this.durationDays    = 0,
    this.servicesPrice   = 0,
    this.totalPrice      = 0,
    this.paidAmount      = 0,
    this.remainingAmount = 0,
    this.bookedServices  = const [],
    this.notes           = '',
  });

  factory BoothModel.fromJson(Map<String, dynamic> j) {
    // ── Dynamic services map ──────────────────────────────────
    Map<String, double> svcMap = {};
    if (j['services'] is Map) {
      (j['services'] as Map).forEach((k, v) {
        svcMap[k.toString()] = (v as num).toDouble();
      });
    }

    return BoothModel(
      id:             j['id'] ?? 0,
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
      services:       svcMap,
      companyName:    j['company_name'],
      companyEmail:   j['company_email'],
      companyInitials: j['company_initials'],
      // Booking history
      bookingId:       j['booking_id'] ?? 0,
      bookingNumber:   j['booking_number'] ?? '',
      bookedAt:        j['booked_at'] ?? '',
      durationDays:    j['duration_days'] ?? 0,
      servicesPrice:   (j['services_price'] ?? 0).toDouble(),
      totalPrice:      (j['total_price'] ?? 0).toDouble(),
      paidAmount:      (j['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (j['remaining_amount'] ?? 0).toDouble(),
      bookedServices:  List<String>.from(j['booked_services'] ?? []),
      notes:           j['notes'] ?? '',
    );
  }
}
