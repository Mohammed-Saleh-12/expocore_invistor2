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
}
