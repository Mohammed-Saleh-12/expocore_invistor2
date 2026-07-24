class CampaignModel {
  final int    id;
  final String title;
  final String description;
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
    this.description = '',
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reach,
    required this.status,
    required this.budget,
    required this.weeklyTrend,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> j) => CampaignModel(
    id:          j['id'] ?? 0,
    title:       j['title'] ?? '',
    description: j['description'] ?? '',
    type:        j['type'] ?? '',
    startDate:   j['start_date'] ?? '',
    endDate:     j['end_date'] ?? '',
    reach:       j['reach'] ?? 0,
    status:      j['status'] ?? 'active',
    budget:      (j['budget'] ?? 0).toDouble(),
    weeklyTrend: List<double>.from(
      (j['weekly_trend'] ?? []).map((v) => (v as num).toDouble()),
    ),
  );

  Map<String, dynamic> toJson() => {
    'title':       title,
    'description': description,
    'type':        type,
    'start_date':  startDate,
    'end_date':    endDate,
    'budget':      budget,
  };
}
