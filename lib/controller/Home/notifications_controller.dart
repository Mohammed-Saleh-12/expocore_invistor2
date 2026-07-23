import 'dart:async';
import 'package:expocore_invistor2/data/sourcedata/remote/Firebace/NotificationsFirebaseData.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/services.dart';
import '../../data/model/notification/notification_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

// ════════════════════════════════════════════════════════════
//  NotificationsController
//  الإشعارات مرتبطة بـ Firebase Firestore
//  المسار: /notifications/{userId}/items
// ════════════════════════════════════════════════════════════
class NotificationsController extends GetxController {
  final NotificationsFirebaseData _firebaseData = NotificationsFirebaseData();

  final notifications = <NotificationModel>[].obs;
  final isLoading     = true.obs;

  StreamSubscription<List<NotificationModel>>? _sub;
  String _userId = '';

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    _userId = Get.find<Services>().userId.toString();
    _subscribeToFirestore();
    super.onInit();
  }

  void _subscribeToFirestore() {
    if (_userId.isEmpty || _userId == '0') {
      // قبل تسجيل الدخول — استخدام بيانات ثابتة مؤقتاً
      notifications.value = DummyData.notifications;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    _sub = _firebaseData.notificationsStream(_userId).listen(
      (list) {
        notifications.value = list;
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('[Notifications] Firestore error: $e');
        if (notifications.isEmpty) {
          notifications.value = DummyData.notifications;
        }
        isLoading.value = false;
      },
    );
  }

  Future<void> markRead(int id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    notifications[idx] = notifications[idx].copyWith(isRead: true);
    notifications.refresh();
    if (_userId.isNotEmpty && _userId != '0') {
      await _firebaseData.markRead(_userId, id);
    }
  }

  Future<void> markAllRead() async {
    notifications.value =
        notifications.map((n) => n.copyWith(isRead: true)).toList();
    if (_userId.isNotEmpty && _userId != '0') {
      await _firebaseData.markAllRead(_userId);
    }
  }

  Future<void> refresh() async {
    // Firestore stream يُحدَّث تلقائياً؛ هذا للإعادة اليدوية فقط
    _sub?.cancel();
    _subscribeToFirestore();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
