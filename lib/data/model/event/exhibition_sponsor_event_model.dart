class SponsorDurationOption {
  final String label;
  final int days;
  final double price;

  SponsorDurationOption({
    required this.label,
    required this.days,
    required this.price,
  });
}

class ExhibitionSponsorEvent {
  final int id;
  final String name;
  final String type;
  final int exhibitionId;
  final String exhibitionName;
  final String exhibitionImageUrl;
  final String date;
  final String startTime;
  final String endTime;
  final String place;
  final int listingDays;
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
}
