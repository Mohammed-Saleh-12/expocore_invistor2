class BoothModel {
  final int    id;
  final String number;
  final String exhibitionName;
  final String imageUrl;
  final double area;
  final String status;
  final double price;
  final String endDate;
  final String location;
  final List<String> amenities;
  bool isFavorite;

  BoothModel({
    required this.id,
    required this.number,
    required this.exhibitionName,
    required this.imageUrl,
    required this.area,
    required this.status,
    required this.price,
    required this.endDate,
    required this.location,
    required this.amenities,
    this.isFavorite = false,
  });

  factory BoothModel.fromJson(Map<String, dynamic> j) => BoothModel(
    id:             j['id'],
    number:         j['number'] ?? '',
    exhibitionName: j['exhibition_name'] ?? '',
    imageUrl:       j['image_url'] ?? '',
    area:           (j['area'] ?? 0).toDouble(),
    status:         j['status'] ?? 'available',
    price:          (j['price'] ?? 0).toDouble(),
    endDate:        j['end_date'] ?? '',
    location:       j['location'] ?? '',
    amenities:      List<String>.from(j['amenities'] ?? []),
    isFavorite:     j['is_favorite'] ?? false,
  );
}
