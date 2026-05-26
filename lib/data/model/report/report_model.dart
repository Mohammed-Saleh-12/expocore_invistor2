class ReportModel {
  final String id;
  final String title;
  final String type;
  final String description;
  final String period;
  final String boothName;
  final String exhibitionName;
  final String createdAt;
  final double mainValue;
  final String mainLabel;
  final double trend;
  final List<double> sparklineData;

  ReportModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.period,
    required this.boothName,
    required this.exhibitionName,
    required this.createdAt,
    required this.mainValue,
    required this.mainLabel,
    required this.trend,
    required this.sparklineData,
  });
}
