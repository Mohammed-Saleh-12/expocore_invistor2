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

  factory ReportModel.fromJson(Map<String, dynamic> j) => ReportModel(
    id:             j['id']?.toString() ?? '',
    title:          j['title'] ?? '',
    type:           j['type'] ?? '',
    description:    j['description'] ?? '',
    period:         j['period'] ?? '',
    boothName:      j['booth_name'] ?? '',
    exhibitionName: j['exhibition_name'] ?? '',
    createdAt:      j['created_at'] ?? '',
    mainValue:      (j['main_value'] ?? 0).toDouble(),
    mainLabel:      j['main_label'] ?? '',
    trend:          (j['trend'] ?? 0).toDouble(),
    sparklineData:  List<double>.from(
      (j['sparkline_data'] ?? []).map((v) => (v as num).toDouble()),
    ),
  );
}
