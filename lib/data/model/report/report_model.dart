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
    final rawGraph = j['graph'] is Map
        ? Map<String, dynamic>.from(j['graph'])
        : <String, dynamic>{};
    final rawTable = j['specific_table'] is List
        ? (j['specific_table'] as List)
              .whereType<Map>()
              .map(Map<String, dynamic>.from)
              .toList()
        : <Map<String, dynamic>>[];
    final rawRecommendations = j['recommendations'] is List
        ? (j['recommendations'] as List).map((v) => v.toString()).toList()
        : <String>[];
    final sparkline = j['sparkline_data'] is List
        ? (j['sparkline_data'] as List).map(_toDouble).toList()
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
