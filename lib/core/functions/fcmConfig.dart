import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import '../../firebase_options.dart';
import '../class/crud.dart';
import '../../linkapi.dart';

// ── Background handler (must be top-level) ────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

// ── Local notifications channel ───────────────────────────
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'expocore_high_importance',
  'ExpoCore Notifications',
  description: 'إشعارات التطبيق الرئيسية',
  importance: Importance.high,
);

// ── Main init function ────────────────────────────────────
Future<void> initFCM() async {
  final messaging = FirebaseMessaging.instance;

  // 1. طلب الإذن (iOS + Android 13+)
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // 2. إعداد الإشعارات المحلية
  await _setupLocalNotifications();

  // 3. الحصول على Token وإرساله للـ backend
  final token = await messaging.getToken(
    vapidKey:
        'BPoV9MkU1cXtrj_7iKGda1Dchteqt8KpxKFak4KjBwcxi589Gb35DgY8Hv1vj1JiB18y_PLYg2zNN8lZDH6hgNs',
  );
  if (token != null) {
    await _sendTokenToBackend(token);
  }

  // 4. مراقبة تحديث الـ Token تلقائياً
  messaging.onTokenRefresh.listen(_sendTokenToBackend);

  // 5. الإشعارات عند فتح التطبيق (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
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
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  // 6. فتح التطبيق من إشعار (Background → Foreground)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // يمكنك هنا التنقل لصفحة معينة بناءً على message.data
  });
}

// ── إرسال FCM Token للـ backend ───────────────────────────
Future<void> _sendTokenToBackend(String token) async {
  final storage = GetStorage();
  final savedToken = storage.read<String>('fcmToken');

  // لا ترسل إذا كان نفس الـ Token
  if (savedToken == token) return;

  final crud = Crud();
  await crud.postData(AppLink.fcmToken, {'fcm_token': token});

  storage.write('fcmToken', token);
}

// ── إعداد flutter_local_notifications ────────────────────
Future<void> _setupLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  await _localNotifications.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
  );

  await _localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_channel);
}
// // 1. إرسال الـ Push للهاتف
// await admin.messaging().send({ token: userFcmToken, notification: { title, body } });

// // 2. حفظ الإشعار في Firestore ليظهر في قائمة التطبيق
// await admin.firestore()
//   .collection('notifications')
//   .doc(String(userId))
//   .collection('items')
//   .add({ title, body, is_read: false, created_at: admin.firestore.FieldValue.serverTimestamp() });