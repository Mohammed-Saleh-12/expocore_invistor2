import 'package:get/get.dart';
import '../../core/services/notification_service.dart';
import '../../data/model/notification/notification_model.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final notifications = <NotificationModel>[].obs;
  final isLoading = true.obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    loadNotifications();
    super.onInit();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    notifications.value = await _notificationService.fetchNotifications();
    isLoading.value = false;
  }

  Future<void> markRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    notifications[idx] = notifications[idx].copyWith(isRead: true);
    notifications.refresh();
    await _notificationService.markAsRead(id);
  }

  Future<void> markAllRead() async {
    notifications.value = notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    await _notificationService.markAllAsRead();
  }

  Future<void> refresh() async {
    await loadNotifications();
  }
}
