import 'package:get/get.dart';

import '../../data/model/notification/notification_model.dart';
import '../../data/sourcedata/remote/Notification/NotificationData.dart';

class NotificationService extends GetxService {
  final NotificationData _data = NotificationData();

  Future<List<NotificationModel>> fetchNotifications() async {
    return _data.fetchNotifications();
  }

  Future<bool> markAsRead(String notificationId) async {
    return _data.markAsRead(notificationId);
  }

  Future<bool> markAllAsRead() async {
    return _data.markAllAsRead();
  }

  Future<bool> deleteNotification(String notificationId) async {
    return _data.deleteNotification(notificationId);
  }
}
