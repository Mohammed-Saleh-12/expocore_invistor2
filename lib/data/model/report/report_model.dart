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
  final Map<String, dynamic> graph;
  final List<Map<String, dynamic>> specificTable;
  final List<String> recommendations;
  final Map<String, dynamic> metrics;

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
    this.graph = const {},
    this.specificTable = const [],
    this.recommendations = const [],
    this.metrics = const {},
  });

  factory ReportModel.fromJson(Map<String, dynamic> j) {
    final rawGraphValue = j['graph'] ?? j['data_graph'];
    final rawGraph = rawGraphValue is Map
        ? Map<String, dynamic>.from(rawGraphValue)
        : <String, dynamic>{};
    final rawTableValue = j['specific_table'] ?? j['data_specific_table'];
    final rawTable = rawTableValue is List
        ? (rawTableValue)
              .whereType<Map>()
              .map(Map<String, dynamic>.from)
              .toList()
        : <Map<String, dynamic>>[];
    final rawRecommendationsValue =
        j['recommendations'] ?? j['data_recommendations'];
    final rawRecommendations = rawRecommendationsValue is List
        ? rawRecommendationsValue.map((v) => v.toString()).toList()
        : <String>[];
    final sparklineValue = j['sparkline_data'];
    final sparkline = sparklineValue is List
        ? sparklineValue.map(_toDouble).toList()
        : rawGraph.values.map(_toDouble).toList();
    return ReportModel(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      type: j['type']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      period: j['period']?.toString() ?? '',
      boothName: j['booth_name']?.toString() ?? '',
      exhibitionName: j['exhibition_name']?.toString() ?? '',
      createdAt: j['created_at']?.toString() ?? '',
      mainValue: _toDouble(j['main_value']),
      mainLabel: j['main_label']?.toString() ?? '',
      trend: _toDouble(j['trend']),
      sparklineData: sparkline,
      graph: rawGraph,
      specificTable: rawTable,
      recommendations: rawRecommendations,
      metrics: Map<String, dynamic>.from(j),
    );
  }

  static double _toDouble(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;
}
