import '../../../linkapi.dart';

class BoothModel {
  final int id;
  final int exhibitionId;
  final String number;
  final String exhibitionName;
  final String imageUrl;
  final double area;
  final String status;
  final double price;
  final String pricingType;
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
  final int bookingId;
  final String bookingNumber;
  final String bookedAt;
  final int durationDays;
  final double servicesPrice;
  final double totalPrice;
  final double paidAmount;
  final double remainingAmount;
  final List<String> bookedServices; // الخدمات التي تم اختيارها في الحجز
  final String notes;

  BoothModel({
    required this.id,
    this.exhibitionId = 0,
    required this.number,
    required this.exhibitionName,
    required this.imageUrl,
    required this.area,
    required this.status,
    required this.price,
    this.pricingType = 'total',
    this.startDate = '',
    required this.endDate,
    required this.location,
    required this.amenities,
    this.isFavorite = false,
    this.services = const {},
    this.companyName,
    this.companyEmail,
    this.companyInitials,
    // Booking history
    this.bookingId = 0,
    this.bookingNumber = '',
    this.bookedAt = '',
    this.durationDays = 0,
    this.servicesPrice = 0,
    this.totalPrice = 0,
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.bookedServices = const [],
    this.notes = '',
  });

  factory BoothModel.fromJson(Map<String, dynamic> j) {
    final services = _parseServices(j['services']);
    final amenities = _parseNames(j['amenities']);
    final exhibition = j['exhibition'];
    final exhibitionName = _parseString(
      j['exhibition_name'] ??
          j['exhibitionName'] ??
          (exhibition is Map ? exhibition['name'] : null),
    );

    final rawImage = _parseString(j['image_url'] ?? j['imageUrl']);
    final images = j['images'] is List ? j['images'] as List : const [];
    final imageValue = rawImage.isNotEmpty
        ? rawImage
        : (images.isNotEmpty ? _parseString(images.first) : '');

    return BoothModel(
      id: _parseInt(j['id']),
      exhibitionId:
          int.tryParse(
            (j['exhibition_id'] ?? j['exhibitionId'] ?? 0).toString(),
          ) ??
          0,
      number: _parseString(j['number']),
      exhibitionName: exhibitionName,
      imageUrl: AppLink.mediaUrl(imageValue),
      area: _parseDouble(j['area']),
      status: _parseString(j['status'], fallback: 'available'),
      price: _parseDouble(j['price']),
      pricingType: _parseString(
        j['pricing_type'] ?? j['pricingType'],
        fallback: 'total',
      ),
      startDate: _parseString(j['start_date'] ?? j['startDate']),
      endDate: _parseString(j['end_date'] ?? j['endDate']),
      location: _parseString(j['location']),
      amenities: amenities,
      isFavorite: j['is_favorite'] == true || j['isFavorite'] == true,
      services: services,
      companyName: _nullableString(j['company_name'] ?? j['companyName']),
      companyEmail: _nullableString(j['company_email'] ?? j['companyEmail']),
      companyInitials: _nullableString(
        j['company_initials'] ?? j['companyInitials'],
      ),
      // Booking history
      bookingId: _parseInt(j['booking_id']),
      bookingNumber: _parseString(j['booking_number']),
      bookedAt: _parseString(j['booked_at']),
      durationDays: _parseInt(j['duration_days']),
      servicesPrice: _parseDouble(j['services_price']),
      totalPrice: _parseDouble(j['total_price']),
      paidAmount: _parseDouble(j['paid_amount']),
      remainingAmount: _parseDouble(j['remaining_amount']),
      bookedServices: _parseSelectedServices(j['booked_services']),
      notes: _parseString(j['notes']),
    );
  }

  static String _parseString(dynamic value, {String fallback = ''}) =>
      value?.toString() ?? fallback;

  static String? _nullableString(dynamic value) {
    final result = value?.toString();
    return result == null || result.isEmpty ? null : result;
  }

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    final normalized = value?.toString().replaceFirst(RegExp(r'^[bB]'), '');
    return int.tryParse(normalized ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _parseNames(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item is Map ? item['name'] : item)
          .where((item) => item != null)
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is Map) return value.keys.map((key) => key.toString()).toList();
    return const [];
  }

  static Map<String, double> _parseServices(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, price) => MapEntry(key.toString(), _parseDouble(price)),
      );
    }
    if (value is List) {
      final result = <String, double>{};
      for (final item in value) {
        if (item is Map && item['name'] != null) {
          result[item['name'].toString()] = _parseDouble(item['price']);
        }
      }
      return result;
    }
    return const {};
  }

  static List<String> _parseSelectedServices(dynamic value) {
    if (value is Map) {
      return value.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key.toString())
          .toList();
    }
    if (value is List) return _parseNames(value);
    return const [];
  }
}
