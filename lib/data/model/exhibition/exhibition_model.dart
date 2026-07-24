import '../event/exhibition_sponsor_event_model.dart';

class ExhibitionModel {
  final int    id;
  final String name;
  final String description;
  // ── Multi-image support ──────────────────────────────────────
  final List<String> images;          // قائمة الصور (الأولى تُعرض في الكرت)
  // ── Dynamic services from API ────────────────────────────────
  final List<String> services;        // خدمات المعرض من الـ API
  // ── Map data embedded in detail response ─────────────────────
  final Map<String, dynamic>? mapJson; // بيانات الخريطة 3D
  // ── Sponsor events embedded in detail response ───────────────
  final List<ExhibitionSponsorEvent> sponsorEvents;
  // ── Standard fields ──────────────────────────────────────────
  final String startDate;
  final String endDate;
  final String location;
  final String city;
  final String status;
  final int    availableBooths;
  final List<String> sectors;
  bool isFavorite;

  ExhibitionModel({
    required this.id,
    required this.name,
    required this.description,
    this.images        = const [],
    this.services      = const [],
    this.mapJson,
    this.sponsorEvents = const [],
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.city,
    required this.status,
    required this.availableBooths,
    required this.sectors,
    this.isFavorite = false,
  });

  // ── imageUrl for backward-compatibility with cards/views ──────
  /// يُعيد أول صورة أو String فارغ — لا كسر للكود القديم
  String get imageUrl => images.isNotEmpty ? images.first : '';

  // ── Domain helpers ────────────────────────────────────────────
  String get statusLabel {
    switch (status) {
      case 'active':   return 'جارٍ';
      case 'upcoming': return 'قادم';
      default:         return 'منتهٍ';
    }
  }

  factory ExhibitionModel.fromJson(Map<String, dynamic> j) {
    // ── Images: يقبل images (list) أو image_url (string قديم) ──
    List<String> imgs;
    if (j['images'] is List) {
      imgs = List<String>.from(j['images']);
    } else if ((j['image_url'] ?? '').toString().isNotEmpty) {
      imgs = [j['image_url'] as String];
    } else {
      imgs = [];
    }

    // ── Sponsor events ────────────────────────────────────────
    List<ExhibitionSponsorEvent> events = [];
    if (j['sponsor_events'] is List) {
      events = (j['sponsor_events'] as List)
          .map((e) => ExhibitionSponsorEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ExhibitionModel(
      id:              j['id'] ?? 0,
      name:            j['name'] ?? '',
      description:     j['description'] ?? '',
      images:          imgs,
      services:        List<String>.from(j['services'] ?? []),
      mapJson:         j['map_data'] is Map<String, dynamic>
                           ? j['map_data'] as Map<String, dynamic>
                           : null,
      sponsorEvents:   events,
      startDate:       j['start_date'] ?? '',
      endDate:         j['end_date'] ?? '',
      location:        j['location'] ?? '',
      city:            j['city'] ?? '',
      status:          j['status'] ?? 'upcoming',
      availableBooths: j['available_booths'] ?? 0,
      sectors:         List<String>.from(j['sectors'] ?? []),
      isFavorite:      j['is_favorite'] ?? false,
    );
  }
}
