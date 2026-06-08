import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/model/notification/notification_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../linkapi.dart';

class NotificationsController extends GetxController {
  final _crud         = Crud();
  final notifications = <NotificationModel>[].obs;
  final isLoading     = false.obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    _loadNotifications();
    super.onInit();
  }

  Future<void> _loadNotifications() async {
    isLoading.value = true;
    final result = await _crud.getData(AppLink.investorNotifications);
    if (result['status'] == true) {
      final list = _asList(result['data']);
      notifications.value =
          list.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      notifications.value = DummyData.notifications;
    }
    isLoading.value = false;
  }

  Future<void> markRead(int id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;

    notifications[idx] = notifications[idx].copyWith(isRead: true);
    notifications.refresh();

    await _crud.patchData(AppLink.markNotificationRead(id), {});
  }

  Future<void> markAllRead() async {
    notifications.value =
        notifications.map((n) => n.copyWith(isRead: true)).toList();

    await _crud.patchData(AppLink.markAllNotificationsRead, {});
  }

  Future<void> refresh() => _loadNotifications();

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }
}
