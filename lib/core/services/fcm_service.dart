import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/class/crud.dart';
import '../../linkapi.dart';

class FcmService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'expocore_high_importance',
    'ExpoCore Notifications',
    description: 'إشعارات التطبيق الرئيسية',
    importance: Importance.high,
  );

  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> registerTokenToLaravel({required String token}) async {
    try {
      final storage = GetStorage();
      final saved = storage.read<String>('fcm_token');
      if (saved == token) return;

      final crud = Crud();
      final result = await crud.postData(AppLink.fcmToken, {
        'fcm_token': token,
      });
      if (result['status'] == true) {
        await storage.write('fcm_token', token);
      }
    } catch (e) {
      debugPrint('[FCM] Token register error: $e');
    }
  }

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await _setupLocalNotifications();
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        debugPrint('[FCM] Notification permission denied');
        return;
      }
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        await registerTokenToLaravel(token: token);
      }
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      });
      _messaging.onTokenRefresh.listen((token) async {
        await registerTokenToLaravel(token: token);
      });
    } catch (e) {
      debugPrint('[FCM] Initialize error: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }
}
