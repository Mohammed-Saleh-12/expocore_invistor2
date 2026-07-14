import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class NotificationsData {
  Crud crud;

  NotificationsData(this.crud);

  Future<Map<String, dynamic>> getNotifications() async {
    return await crud.getData(AppLink.investorNotifications);
  }

  Future<Map<String, dynamic>> markRead(int notificationId) async {
    return await crud.patchData(AppLink.markNotificationRead(notificationId), {});
  }

  Future<Map<String, dynamic>> markAllRead() async {
    return await crud.patchData(AppLink.markAllNotificationsRead, {});
  }
}
