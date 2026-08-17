class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> payload;
  final String? route;

  NotificationModel({
    required this.id,
    this.userId = 0,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.payload = const {},
    this.route,
  });

  String get body => message;
  String get time => createdAt.toLocal().toString();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? json['body'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      isRead: json['is_read'] == true || json['read'] == true,
      createdAt: _parseDate(
        json['created_at'] ?? json['time'] ?? DateTime.now().toIso8601String(),
      ),
      payload: payload is Map
          ? Map<String, dynamic>.from(payload)
          : const <String, dynamic>{},
      route: json['route']?.toString(),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    userId: userId,
    title: title,
    message: message,
    type: type,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
    payload: payload,
    route: route,
  );
}
