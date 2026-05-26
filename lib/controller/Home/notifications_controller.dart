import 'package:get/get.dart';
import '../../data/model/notification/notification_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    notifications.value = DummyData.notifications;
    super.onInit();
  }

  void markRead(int id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx] = NotificationModel(
        id: notifications[idx].id, title: notifications[idx].title,
        body: notifications[idx].body, type: notifications[idx].type,
        time: notifications[idx].time, isRead: true, route: notifications[idx].route,
      );
      notifications.refresh();
    }
  }

  void markAllRead() {
    notifications.value = notifications.map((n) => NotificationModel(
      id: n.id, title: n.title, body: n.body, type: n.type,
      time: n.time, isRead: true, route: n.route,
    )).toList();
  }
}
