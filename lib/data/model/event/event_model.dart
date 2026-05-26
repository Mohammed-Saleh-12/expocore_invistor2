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
  });

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
  );
}
