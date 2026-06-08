class NotificationModel {
  final int    id;
  final String title;
  final String body;
  final String type;
  final String time;
  final bool   isRead;
  final String? route;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    required this.isRead,
    this.route,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) =>
      NotificationModel(
        id:      j['id'] ?? 0,
        title:   j['title'] ?? '',
        body:    j['body'] ?? j['message'] ?? '',
        type:    j['type'] ?? '',
        time:    j['time'] ?? j['created_at'] ?? '',
        isRead:  j['is_read'] ?? false,
        route:   j['route'],
      );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id, title: title, body: body, type: type,
    time: time, isRead: isRead ?? this.isRead, route: route,
  );
}
