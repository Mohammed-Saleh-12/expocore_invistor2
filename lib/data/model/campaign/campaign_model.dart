class CampaignModel {
  final int    id;
  final String title;
  final String type;
  final String startDate;
  final String endDate;
  final int    reach;
  final String status;
  final double budget;
  final List<double> weeklyTrend;

  CampaignModel({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reach,
    required this.status,
    required this.budget,
    required this.weeklyTrend,
  });
}
