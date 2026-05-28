class SponsorshipBookingModel {
  final int id;
  final int eventId;
  final String eventName;
  final String eventType;
  final String exhibitionName;
  final String date;
  final String place;
  final String time;
  final String selectedDurationLabel;
  final int selectedDays;
  final double price;
  String status;
  final String bookedAt;
  final int totalVisitors;
  final int totalAttendees;
  final List<int> dailyVisitors;
  final int currentDay;
  final int totalDays;

  SponsorshipBookingModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.eventType,
    required this.exhibitionName,
    required this.date,
    required this.place,
    required this.time,
    required this.selectedDurationLabel,
    required this.selectedDays,
    required this.price,
    this.status = 'pending',
    required this.bookedAt,
    this.totalVisitors = 0,
    this.totalAttendees = 0,
    this.dailyVisitors = const [],
    this.currentDay = 1,
    this.totalDays = 3,
  });
}
