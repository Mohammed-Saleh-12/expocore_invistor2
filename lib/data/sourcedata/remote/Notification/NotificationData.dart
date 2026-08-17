import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/data/model/notification/notification_model.dart';
import 'package:expocore_invistor2/linkapi.dart';

class NotificationData {
  final Crud _crud = Crud();

  Future<List<NotificationModel>> fetchNotifications() async {
    final result = await _crud.getData(AppLink.investorNotifications);
    if (result['status'] != true) {
      return <NotificationModel>[];
    }

    final data = result['data'];
    if (data is Map && data['data'] != null) {
      return _parseList(data['data']);
    }
    if (data is List) {
      return _parseList(data);
    }

    return <NotificationModel>[];
  }

  Future<bool> markAsRead(int notificationId) async {
    final result = await _crud.patchData(
      AppLink.notificationRead(notificationId),
      <String, dynamic>{},
    );
    return result['status'] == true;
  }

  Future<bool> markAllAsRead() async {
    final result = await _crud.patchData(
      AppLink.notificationsReadAll,
      <String, dynamic>{},
    );
    return result['status'] == true;
  }

  Future<bool> deleteNotification(int notificationId) async {
    final result = await _crud.deleteData(
      AppLink.notificationDetail(notificationId),
    );
    return result['status'] == true;
  }

  List<NotificationModel> _parseList(dynamic raw) {
    if (raw is! List) return <NotificationModel>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .toList();
  }
}
