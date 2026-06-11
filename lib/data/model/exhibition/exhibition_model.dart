class ExhibitionModel {
  final int    id;
  final String name;
  final String description;
  final String imageUrl;
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
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.city,
    required this.status,
    required this.availableBooths,
    required this.sectors,
    this.isFavorite = false,
  });

  // ── Domain helpers (منطق النطاق — لا تبعيات واجهة) ─────────
  String get statusLabel {
    switch (status) {
      case 'active':   return 'جارٍ';
      case 'upcoming': return 'قادم';
      default:         return 'منتهٍ';
    }
  }

  factory ExhibitionModel.fromJson(Map<String, dynamic> j) => ExhibitionModel(
    id:              j['id'],
    name:            j['name'] ?? '',
    description:     j['description'] ?? '',
    imageUrl:        j['image_url'] ?? '',
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
