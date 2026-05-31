class SponsorDurationOption {
  final String label;
  final int    days;
  final double price;

  SponsorDurationOption({
    required this.label,
    required this.days,
    required this.price,
  });

  factory SponsorDurationOption.fromJson(Map<String, dynamic> j) =>
      SponsorDurationOption(
        label: j['label'] ?? '',
        days:  j['days']  ?? 1,
        price: (j['price'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {'label': label, 'days': days, 'price': price};
}

class ExhibitionSponsorEvent {
  final int    id;
  final String name;
  final String type;
  final int    exhibitionId;
  final String exhibitionName;
  final String exhibitionImageUrl;
  final String date;
  final String startTime;
  final String endTime;
  final String place;
  final int    listingDays;
  final String description;
  final List<SponsorDurationOption> durationOptions;
  bool isFavorite;

  ExhibitionSponsorEvent({
    required this.id,
    required this.name,
    required this.type,
    required this.exhibitionId,
    required this.exhibitionName,
    required this.exhibitionImageUrl,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.place,
    required this.listingDays,
    required this.description,
    required this.durationOptions,
    this.isFavorite = false,
  });

  factory ExhibitionSponsorEvent.fromJson(Map<String, dynamic> j) =>
      ExhibitionSponsorEvent(
        id:                 j['id'] ?? 0,
        name:               j['name'] ?? '',
        type:               j['type'] ?? '',
        exhibitionId:       j['exhibition_id'] ?? 0,
        exhibitionName:     j['exhibition_name'] ?? '',
        exhibitionImageUrl: j['exhibition_image_url'] ?? '',
        date:               j['date'] ?? '',
        startTime:          j['start_time'] ?? '',
        endTime:            j['end_time'] ?? '',
        place:              j['place'] ?? '',
        listingDays:        j['listing_days'] ?? 1,
        description:        j['description'] ?? '',
        durationOptions: (j['duration_options'] as List? ?? [])
            .map((o) => SponsorDurationOption.fromJson(o))
            .toList(),
        isFavorite: j['is_favorite'] ?? false,
      );
}
