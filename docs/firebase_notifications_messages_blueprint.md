# Firebase — Notifications & Messages Blueprint
# مخطط الربط مع Firebase للإشعارات والرسائل

> **الغرض من هذا الملف:** يحتوي على كل ما تحتاجه لبناء نفس آلية الإشعارات والرسائل في أي تطبيق Flutter جديد.
> اتبع الأقسام بالترتيب وغيّر فقط أسماء الـ package والـ collections وفق مشروعك.

---

## 📦 1. الـ Dependencies المطلوبة (pubspec.yaml)

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  firebase_messaging: ^15.0.0
  cloud_firestore: ^5.0.0
  flutter_local_notifications: ^17.0.0
  get: ^4.6.6
  get_storage: ^2.1.1
```

> ⚠️ **ملاحظة:** استخدم `flutter build web --profile` وليس `--release`
> بسبب مشكلة dart2js في Flutter 3.32.0 التي تُعطل release builds.

---

## 🗂️ 2. هيكل الملفات

```
lib/
├── main.dart                                        ← تهيئة Firebase + تسجيل background handler
├── firebase_options.dart                            ← مُولَّد بـ FlutterFire CLI
├── linkapi.dart                                     ← endpoints (منها fcmToken)
│
├── core/functions/
│   └── fcmConfig.dart                               ← المركز الرئيسي لإعداد FCM
│
├── data/
│   ├── model/
│   │   ├── notification/
│   │   │   └── notification_model.dart
│   │   └── message/
│   │       ├── message_model.dart
│   │       ├── conversation_model.dart              ← محادثات مع طرف A
│   │       └── visitor_conversation_model.dart      ← محادثات مع طرف B
│   └── sourcedata/remote/Firebace/
│       ├── NotificationsFirebaseData.dart           ← CRUD الإشعارات في Firestore
│       ├── MessagesFirebaseData.dart                ← CRUD محادثات طرف A
│       └── VisitorMessagesFirebaseData.dart         ← CRUD محادثات طرف B
│
└── controller/Home/
    ├── notifications_controller.dart
    ├── messages_controller.dart
    └── visitor_messages_controller.dart
```

---

## 🗄️ 3. هيكل Firestore

```
Firestore
├── notifications/
│   └── {userId}/                     ← معرّف المستخدم (String)
│       └── items/
│           └── {notifId}
│               ├── title: String
│               ├── body: String
│               ├── type: String
│               ├── time: String        ← ISO أو timestamp
│               ├── is_read: bool
│               └── route: String?      ← للتنقل عند الضغط (اختياري)
│
├── conversations/                      ← محادثات مع طرف A (معارض/شركات/...)
│   └── {conversationId}
│       ├── investor_id: int
│       ├── exhibition_id: int
│       ├── exhibition_name: String
│       ├── exhibition_initials: String
│       ├── color: String               ← hex مثل "FF7A1FFF"
│       ├── unread_count: int
│       ├── last_message: String
│       ├── last_time: Timestamp
│       └── messages/
│           └── {messageId}
│               ├── id: String
│               ├── text: String
│               ├── is_me: bool
│               ├── sender_id: int
│               ├── time: Timestamp
│               └── is_read: bool
│
└── visitor_conversations/              ← محادثات مع طرف B (زوار/عملاء/...)
    └── {conversationId}
        ├── investor_id: int
        ├── visitor_name: String
        ├── visitor_initials: String
        ├── color: String
        ├── unread_count: int
        ├── last_message: String
        ├── last_time: Timestamp
        └── messages/
            └── {messageId}
                ├── id: String
                ├── text: String
                ├── is_me: bool
                ├── time: Timestamp
                └── is_read: bool
```

---

## 🚀 4. التهيئة في main.dart

```dart
// lib/main.dart

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';
import 'core/functions/fcmConfig.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();

    // ── 1. تهيئة Firebase ──────────────────────────────────────
    try {
      final firebaseInit = Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // على الويب: انتظر 12 ثانية كحد أقصى لتجنب تعليق التطبيق
      if (kIsWeb) {
        await firebaseInit.timeout(const Duration(seconds: 12));
      } else {
        await firebaseInit;
      }
    } catch (e) {
      debugPrint('[App] Firebase init skipped: $e');
    }

    // ── 2. تسجيل Background Handler (موبايل فقط) ─────────────
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }

    // ── 3. تهيئة FCM (موبايل فقط) ────────────────────────────
    if (!kIsWeb) {
      try {
        await initFCM();
      } catch (_) {}
    }

    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('[App] Zone error: $error');
  });
}
```

---

## ⚙️ 5. fcmConfig.dart — المركز الرئيسي

```dart
// lib/core/functions/fcmConfig.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import '../../firebase_options.dart';
import '../../linkapi.dart';
// استبدل Crud بأي HTTP client تستخدمه
import '../class/crud.dart';

// ─────────────────────────────────────────────────────────────
// STEP 1: Background handler — يجب أن يكون دالة على مستوى top-level
// ─────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // أعد تهيئة Firebase (مطلوب لأن الدالة تعمل في isolate منفصل)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // يمكنك هنا حفظ البيانات محلياً أو إظهار إشعار محلي
}

// ─────────────────────────────────────────────────────────────
// STEP 2: تعريف قناة الإشعارات (Android)
// ─────────────────────────────────────────────────────────────
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

// غيّر id واسم القناة وفق تطبيقك
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'YOUR_APP_high_importance',   // ← غيّر هذا
  'YOUR_APP Notifications',     // ← غيّر هذا
  description: 'إشعارات التطبيق الرئيسية',
  importance: Importance.high,
);

// ─────────────────────────────────────────────────────────────
// STEP 3: دالة التهيئة الرئيسية — استدعِها من main()
// ─────────────────────────────────────────────────────────────
Future<void> initFCM() async {
  final messaging = FirebaseMessaging.instance;

  // 1. طلب إذن الإشعارات (iOS + Android 13+)
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // 2. إعداد الإشعارات المحلية
  await _setupLocalNotifications();

  // 3. الحصول على FCM Token وإرساله للـ Backend
  //    vapidKey مطلوب فقط للويب — أزله إذا لم تدعم الويب
  final token = await messaging.getToken(
    vapidKey: 'YOUR_VAPID_KEY_HERE', // ← من Firebase Console
  );
  if (token != null) {
    await _sendTokenToBackend(token);
  }

  // 4. تحديث الـ Token تلقائياً عند تغييره
  messaging.onTokenRefresh.listen(_sendTokenToBackend);

  // 5. إشعار عند وصول رسالة والتطبيق مفتوح (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android      = message.notification?.android;

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
            priority:   Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  // 6. المستخدم يضغط على إشعار والتطبيق في الخلفية → يفتح التطبيق
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // مثال: Get.toNamed(message.data['route'] ?? '/home');
    final route = message.data['route'];
    if (route != null) {
      // انتقل للصفحة المناسبة
    }
  });
}

// ─────────────────────────────────────────────────────────────
// STEP 4: إرسال FCM Token للـ Backend (مرة واحدة فقط إذا تغيّر)
// ─────────────────────────────────────────────────────────────
Future<void> _sendTokenToBackend(String token) async {
  final storage    = GetStorage();
  final savedToken = storage.read<String>('fcmToken');

  // لا ترسل إذا كان نفس الـ Token المحفوظ مسبقاً
  if (savedToken == token) return;

  final crud = Crud(); // ← استبدل بـ http client الخاص بك
  await crud.postData(AppLink.fcmToken, {'fcm_token': token});

  storage.write('fcmToken', token);
}

// ─────────────────────────────────────────────────────────────
// STEP 5: إعداد flutter_local_notifications
// ─────────────────────────────────────────────────────────────
Future<void> _setupLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit     = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  await _localNotifications.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
  );

  // إنشاء قناة الإشعارات في Android
  await _localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);
}
```

---

## 🔗 6. API Endpoint لتسجيل FCM Token

```dart
// lib/linkapi.dart  (أضف هذا السطر مع باقي endpoints)

class AppLink {
  static String get server => AppEnv.baseUrl; // ← base URL من env

  // ── FCM Token ─────────────────────────────────────────────
  // POST {server}/auth/fcm-token  →  body: { "fcm_token": "..." }
  static String get fcmToken => '$server/auth/fcm-token';

  // ... باقي endpoints
}
```

**Body الـ Request:**
```json
{ "fcm_token": "xxxxxxxxxxxxxxxxxx" }
```

---

## 📬 7. البيانات من Firestore — Data Sources

### 7.1 — NotificationsFirebaseData.dart

```dart
// lib/data/sourcedata/remote/Firebace/NotificationsFirebaseData.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/notification/notification_model.dart';

// Firestore path: /notifications/{userId}/items/{notifId}
class NotificationsFirebaseData {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _db.collection('notifications').doc(userId).collection('items');

  /// Stream لقائمة الإشعارات — مرتبة بالأحدث أولاً
  Stream<List<NotificationModel>> notificationsStream(String userId) {
    return _col(userId)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromJson({...d.data(), 'id': _toIntId(d.id)}))
            .toList());
  }

  /// تعليم إشعار واحد كمقروء
  Future<void> markRead(String userId, int notifId) async {
    await _col(userId).doc(notifId.toString()).update({'is_read': true});
  }

  /// تعليم جميع الإشعارات كمقروءة (batch write)
  Future<void> markAllRead(String userId) async {
    final batch = _db.batch();
    final snap  = await _col(userId).where('is_read', isEqualTo: false).get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  int _toIntId(String docId) => int.tryParse(docId) ?? docId.hashCode;
}
```

### 7.2 — MessagesFirebaseData.dart (محادثات طرف A)

```dart
// lib/data/sourcedata/remote/Firebace/MessagesFirebaseData.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/message/conversation_model.dart';
import '../../model/message/message_model.dart';

// Firestore paths:
//   /conversations/{conversationId}
//   /conversations/{conversationId}/messages/{messageId}
class MessagesFirebaseData {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conv =>
      _db.collection('conversations');

  /// Stream لجميع المحادثات الخاصة بالمستخدم
  Stream<List<ConversationModel>> conversationsStream(int investorId) {
    return _conv
        .where('investor_id', isEqualTo: investorId)
        .orderBy('last_time', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ConversationModel.fromJson({...d.data(), 'id': _toInt(d.id)}))
            .toList());
  }

  /// Stream لرسائل محادثة واحدة
  Stream<List<MessageModel>> messagesStream(String conversationId) {
    return _conv
        .doc(conversationId)
        .collection('messages')
        .orderBy('time')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MessageModel.fromJson(d.data())).toList());
  }

  /// إنشاء محادثة جديدة
  Future<String> createConversation({
    required int    investorId,
    required int    partyId,          // ← id الطرف الآخر (معرض/شركة/...)
    required String partyName,
    required String partyInitials,
    required int    color,            // ← لون Avatar (ARGB int)
  }) async {
    final ref = await _conv.add({
      'investor_id':      investorId,
      'exhibition_id':    partyId,
      'exhibition_name':  partyName,
      'exhibition_initials': partyInitials,
      'color':            color.toRadixString(16).toUpperCase(),
      'unread_count':     0,
      'last_message':     '',
      'last_time':        FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// إرسال رسالة (batch: يُضيف الرسالة + يُحدّث last_message)
  Future<void> sendMessage({
    required String conversationId,
    required int    senderId,
    required String text,
    required bool   isMe,
  }) async {
    final batch  = _db.batch();
    final msgRef = _conv.doc(conversationId).collection('messages').doc();
    batch.set(msgRef, {
      'id':        msgRef.id,
      'text':      text,
      'is_me':     isMe,
      'sender_id': senderId,
      'time':      FieldValue.serverTimestamp(),
      'is_read':   false,
    });
    batch.update(_conv.doc(conversationId), {
      'last_message': text,
      'last_time':    FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// تعليم محادثة كمقروءة (unread_count = 0)
  Future<void> markConversationRead(String conversationId) async {
    await _conv.doc(conversationId).update({'unread_count': 0});
  }

  int _toInt(String id) => int.tryParse(id) ?? id.hashCode;
}
```

### 7.3 — VisitorMessagesFirebaseData.dart (محادثات طرف B)

```dart
// lib/data/sourcedata/remote/Firebace/VisitorMessagesFirebaseData.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/message/visitor_conversation_model.dart';
import '../../model/message/message_model.dart';

// Firestore paths:
//   /visitor_conversations/{conversationId}
//   /visitor_conversations/{conversationId}/messages/{messageId}
class VisitorMessagesFirebaseData {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('visitor_conversations');

  Stream<List<VisitorConversationModel>> conversationsStream(int investorId) {
    return _col
        .where('investor_id', isEqualTo: investorId)
        .orderBy('last_time', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => VisitorConversationModel.fromJson({...d.data(), 'id': _toInt(d.id)}))
            .toList());
  }

  Stream<List<MessageModel>> messagesStream(String conversationId) {
    return _col
        .doc(conversationId)
        .collection('messages')
        .orderBy('time')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MessageModel.fromJson(d.data())).toList());
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required bool   isMe,
  }) async {
    final batch  = _db.batch();
    final msgRef = _col.doc(conversationId).collection('messages').doc();
    batch.set(msgRef, {
      'id':      msgRef.id,
      'text':    text,
      'is_me':   isMe,
      'time':    FieldValue.serverTimestamp(),
      'is_read': false,
    });
    batch.update(_col.doc(conversationId), {
      'last_message': text,
      'last_time':    FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> markConversationRead(String conversationId) async {
    await _col.doc(conversationId).update({'unread_count': 0});
  }

  int _toInt(String id) => int.tryParse(id) ?? id.hashCode;
}
```

---

## 📊 8. Models

### 8.1 — NotificationModel

```dart
// lib/data/model/notification/notification_model.dart

class NotificationModel {
  final int     id;
  final String  title;
  final String  body;
  final String  type;     // نوع الإشعار (booking, message, alert, ...)
  final String  time;
  final bool    isRead;
  final String? route;    // مسار الانتقال عند الضغط

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    required this.isRead,
    this.route,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
    id:     j['id']         ?? 0,
    title:  j['title']      ?? '',
    body:   j['body']       ?? j['message'] ?? '',
    type:   j['type']       ?? '',
    time:   j['time']       ?? j['created_at'] ?? '',
    isRead: j['is_read']    ?? false,
    route:  j['route'],
  );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id, title: title, body: body, type: type,
    time: time, isRead: isRead ?? this.isRead, route: route,
  );
}
```

### 8.2 — MessageModel

```dart
// lib/data/model/message/message_model.dart

class MessageModel {
  final int    id;
  final String text;
  final bool   isMe;    // true = الرسالة من المستخدم الحالي
  final String time;
  final bool   isRead;

  MessageModel({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    required this.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
    id:     j['id']       ?? 0,
    text:   j['text']     ?? j['body'] ?? '',
    isMe:   j['is_me']    ?? false,
    time:   j['time']     ?? j['created_at'] ?? '',
    isRead: j['is_read']  ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id':      id,
    'text':    text,
    'is_me':   isMe,
    'time':    time,
    'is_read': isRead,
  };
}
```

### 8.3 — ConversationModel (طرف A)

```dart
// lib/data/model/message/conversation_model.dart

import 'message_model.dart';

class ConversationModel {
  final int    id;
  final int    exhibitionId;       // ← غيّر الاسم وفق طبيعة مشروعك
  final String exhibitionName;
  final String exhibitionInitials;
  final int    color;              // ARGB
  final List<MessageModel> messages;
  int unreadCount;

  ConversationModel({
    required this.id,
    required this.exhibitionId,
    required this.exhibitionName,
    required this.exhibitionInitials,
    required this.color,
    required this.messages,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> j) => ConversationModel(
    id:                 j['id']                  ?? 0,
    exhibitionId:       j['exhibition_id']        ?? 0,
    exhibitionName:     j['exhibition_name']      ?? '',
    exhibitionInitials: j['exhibition_initials']  ?? '',
    color: int.tryParse(
              (j['color'] as String? ?? 'FF7A1FFF').replaceFirst('#', ''),
              radix: 16,
            ) ?? 0xFF7A1FFF,
    messages: (j['messages'] as List? ?? [])
        .map((m) => MessageModel.fromJson(m)).toList(),
    unreadCount: j['unread_count'] ?? 0,
  );

  MessageModel? get lastMessageObj => messages.isNotEmpty ? messages.last : null;
  String get lastMessage => lastMessageObj?.text ?? '';
  String get lastTime    => lastMessageObj?.time ?? '';
}
```

### 8.4 — VisitorConversationModel (طرف B)

```dart
// lib/data/model/message/visitor_conversation_model.dart

import 'message_model.dart';

class VisitorConversationModel {
  final int    id;
  final String visitorName;        // ← غيّر الاسم وفق طبيعة مشروعك
  final String visitorInitials;
  final int    color;
  final List<MessageModel> messages;
  int unreadCount;

  VisitorConversationModel({
    required this.id,
    required this.visitorName,
    required this.visitorInitials,
    required this.color,
    required this.messages,
    this.unreadCount = 0,
  });

  factory VisitorConversationModel.fromJson(Map<String, dynamic> j) =>
      VisitorConversationModel(
        id:              j['id']               ?? 0,
        visitorName:     j['visitor_name']     ?? '',
        visitorInitials: j['visitor_initials'] ?? '',
        color: int.tryParse(
                  (j['color'] as String? ?? 'FFFF1592').replaceFirst('#', ''),
                  radix: 16,
                ) ?? 0xFFFF1592,
        messages: (j['messages'] as List? ?? [])
            .map((m) => MessageModel.fromJson(m)).toList(),
        unreadCount: j['unread_count'] ?? 0,
      );

  MessageModel? get lastMessageObj => messages.isNotEmpty ? messages.last : null;
  String get lastMessage => lastMessageObj?.text ?? '';
  String get lastTime    => lastMessageObj?.time ?? '';
}
```

---

## 🎮 9. Controllers (GetX)

### 9.1 — NotificationsController

```dart
// lib/controller/Home/notifications_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/services.dart';   // ← مكان حفظ userId
import '../../data/model/notification/notification_model.dart';
import '../../data/sourcedata/remote/Firebace/NotificationsFirebaseData.dart';

class NotificationsController extends GetxController {
  final NotificationsFirebaseData _firebaseData = NotificationsFirebaseData();

  final notifications = <NotificationModel>[].obs;
  final isLoading     = true.obs;

  StreamSubscription<List<NotificationModel>>? _sub;
  String _userId = '';

  /// عدد الإشعارات غير المقروءة (للـ badge)
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    // ← اجلب userId من أي مكان تحفظه (Services / SharedPreferences / ...)
    _userId = Get.find<Services>().userId.toString();
    _subscribeToFirestore();
    super.onInit();
  }

  void _subscribeToFirestore() {
    if (_userId.isEmpty || _userId == '0') {
      // المستخدم لم يسجّل الدخول بعد — أظهر قائمة فارغة أو dummy data
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
        isLoading.value = false;
      },
    );
  }

  /// تعليم إشعار واحد كمقروء (optimistic update)
  Future<void> markRead(int id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    notifications[idx] = notifications[idx].copyWith(isRead: true);
    notifications.refresh();
    if (_userId.isNotEmpty && _userId != '0') {
      await _firebaseData.markRead(_userId, id);
    }
  }

  /// تعليم الكل كمقروء
  Future<void> markAllRead() async {
    notifications.value = notifications.map((n) => n.copyWith(isRead: true)).toList();
    if (_userId.isNotEmpty && _userId != '0') {
      await _firebaseData.markAllRead(_userId);
    }
  }

  Future<void> refresh() async {
    _sub?.cancel();
    _subscribeToFirestore();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
```

### 9.2 — MessagesController (محادثات طرف A)

```dart
// lib/controller/Home/messages_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/services.dart';
import '../../data/model/message/conversation_model.dart';
import '../../data/model/message/message_model.dart';
import '../../data/sourcedata/remote/Firebace/MessagesFirebaseData.dart';

class MessagesController extends GetxController {
  final MessagesFirebaseData _firebaseData = MessagesFirebaseData();

  final conversations        = <ConversationModel>[].obs;
  final activeConversationId = Rxn<int>();
  final inputCtrl            = TextEditingController();
  final isLoading            = false.obs;
  final isSending            = false.obs;
  final activeMessages       = <MessageModel>[].obs;

  StreamSubscription<List<ConversationModel>>? _convSub;
  StreamSubscription<List<MessageModel>>?      _msgSub;

  /// خريطة int id → Firestore doc id
  final _firestoreIds = <int, String>{};

  int _userId = 0;

  int get totalUnread => conversations.fold(0, (sum, c) => sum + c.unreadCount);

  ConversationModel? get activeConversation {
    final id = activeConversationId.value;
    if (id == null) return null;
    return conversations.firstWhereOrNull((c) => c.id == id);
  }

  @override
  void onInit() {
    _userId = Get.find<Services>().userId;
    _subscribeToConversations();
    super.onInit();
  }

  void _subscribeToConversations() {
    if (_userId == 0) { isLoading.value = false; return; }
    isLoading.value = true;
    _convSub = _firebaseData.conversationsStream(_userId).listen(
      (list) { conversations.value = list; isLoading.value = false; },
      onError: (e) { debugPrint('[Messages] $e'); isLoading.value = false; },
    );
  }

  /// فتح محادثة والاشتراك بـ Stream رسائلها
  void openConversation(int convId) {
    activeConversationId.value = convId;
    activeMessages.clear();
    _msgSub?.cancel();

    final firestoreId = _firestoreIds[convId];
    if (firestoreId == null) {
      final conv = conversations.firstWhereOrNull((c) => c.id == convId);
      if (conv != null) activeMessages.value = List.from(conv.messages);
      return;
    }
    _msgSub = _firebaseData.messagesStream(firestoreId).listen(
      (msgs) => activeMessages.value = msgs,
      onError: (e) => debugPrint('[Messages] msg stream: $e'),
    );
    _firebaseData.markConversationRead(firestoreId).ignore();
  }

  void closeConversation() {
    activeConversationId.value = null;
    activeMessages.clear();
    _msgSub?.cancel();
    _msgSub = null;
  }

  /// إرسال رسالة — بدون مُعامَل لدعم VoidCallback في الواجهات
  Future<void> sendMessage() async {
    final text        = inputCtrl.text.trim();
    if (text.isEmpty) return;
    final convId      = activeConversationId.value;
    final firestoreId = convId != null ? _firestoreIds[convId] : null;
    inputCtrl.clear();

    if (firestoreId == null) return; // لا توجد محادثة نشطة

    isSending.value = true;
    await _firebaseData.sendMessage(
      conversationId: firestoreId,
      senderId:       _userId,
      text:           text,
      isMe:           true,
    );
    isSending.value = false;
  }

  /// البحث عن محادثة بالاسم أو إنشاء واحدة جديدة
  void openOrCreateConversation(String partyName) {
    final existing = conversations.firstWhereOrNull(
      (c) => c.exhibitionName.contains(partyName),
    );
    if (existing != null) {
      openConversation(existing.id);
    } else {
      _createAndOpen(partyName: partyName);
    }
  }

  Future<void> _createAndOpen({required String partyName}) async {
    if (_userId == 0) return;
    final firestoreId = await _firebaseData.createConversation(
      investorId:    _userId,
      partyId:       0,
      partyName:     partyName,
      partyInitials: _initials(partyName),
      color:         0xFF7A1FFF,
    );
    final intId = firestoreId.hashCode.abs();
    _firestoreIds[intId] = firestoreId;
    openConversation(intId);
  }

  Future<void> refresh() async {
    _convSub?.cancel();
    _subscribeToConversations();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : '?';
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    _convSub?.cancel();
    _msgSub?.cancel();
    super.onClose();
  }
}
```

### 9.3 — VisitorMessagesController (محادثات طرف B — نفس النمط)

```dart
// lib/controller/Home/visitor_messages_controller.dart
// ← نفس بنية MessagesController بالضبط، مع تغيير:
//   - MessagesFirebaseData  → VisitorMessagesFirebaseData
//   - ConversationModel     → VisitorConversationModel
//   - conversations         → visitorConversations
//   - Firestore collection  → visitor_conversations
//
// راجع الملف الأصلي في المشروع للكود الكامل.
// الفكرة: كرّر نفس النمط لكل "نوع محادثة" في تطبيقك.
```

---

## 🔌 10. ربط Controllers بـ GetX (Bindings)

```dart
// lib/bindings/home_binding.dart  (أو InitialBindings)

import 'package:get/get.dart';
import '../controller/Home/notifications_controller.dart';
import '../controller/Home/messages_controller.dart';
import '../controller/Home/visitor_messages_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(() => NotificationsController());
    Get.lazyPut<MessagesController>(() => MessagesController());
    Get.lazyPut<VisitorMessagesController>(() => VisitorMessagesController());
  }
}
```

---

## 📡 11. Backend — ما يجب أن يفعله السيرفر

```
عند إرسال إشعار للمستخدم، يجب أن يقوم السيرفر بـ خطوتين معاً:

1. FCM Push (يصل للجهاز حتى لو التطبيق مغلق):
   await admin.messaging().send({
     token: userFcmToken,
     notification: { title: "...", body: "..." },
     data: { route: "/notifications" }   // اختياري للتنقل
   });

2. Firestore (يظهر في قائمة الإشعارات داخل التطبيق):
   await admin.firestore()
     .collection('notifications')
     .doc(String(userId))
     .collection('items')
     .add({
       title:      "...",
       body:       "...",
       type:       "booking",      // نوع الإشعار
       time:       admin.firestore.FieldValue.serverTimestamp(),
       is_read:    false,
       route:      "/booking/123"  // اختياري
     });
```

---

## 🔒 12. Firestore Security Rules (قواعد الأمان)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // الإشعارات: كل مستخدم يقرأ إشعاراته فقط، الكتابة للـ backend فقط
    match /notifications/{userId}/items/{notifId} {
      allow read, update: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // الكتابة من السيرفر عبر Admin SDK
    }

    // المحادثات مع طرف A
    match /conversations/{convId} {
      allow read, write: if request.auth != null
        && resource.data.investor_id == request.auth.token.userId;
      match /messages/{msgId} {
        allow read, write: if request.auth != null;
      }
    }

    // المحادثات مع طرف B
    match /visitor_conversations/{convId} {
      allow read, write: if request.auth != null
        && resource.data.investor_id == request.auth.token.userId;
      match /messages/{msgId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

---

## ✅ 13. قائمة التحقق عند تطبيق الآلية في مشروع جديد

```
□ 1. أنشئ مشروع Firebase جديد وفعّل: Firestore + Cloud Messaging
□ 2. نفّذ: flutterfire configure  ← يولّد firebase_options.dart تلقائياً
□ 3. أضف Dependencies في pubspec.yaml (القسم 1)
□ 4. انسخ fcmConfig.dart وغيّر:
       - اسم قناة الإشعارات (channel id + name)
       - VAPID key (للويب فقط)
       - AppLink.fcmToken (endpoint تسجيل الـ token)
□ 5. في main.dart: أضف Firebase.initializeApp() والـ background handler
□ 6. انسخ ملفات Data Sources (NotificationsFirebaseData, MessagesFirebaseData)
       وغيّر أسماء الـ Firestore collections وفق مشروعك
□ 7. انسخ Models وعدّل الحقول وفق بيانات مشروعك
□ 8. انسخ Controllers وعدّل مصدر userId
□ 9. سجّل Controllers في Bindings
□ 10. طبّق Firestore Security Rules (القسم 12)
□ 11. تأكد أن السيرفر يكتب في Firestore + يرسل FCM (القسم 11)
```

---

## ⚡ 14. نقاط مهمة لتجنب المشاكل الشائعة

| المشكلة | السبب | الحل |
|---------|-------|------|
| الإشعار لا يظهر والتطبيق مفتوح | FCM لا يعرض إشعاراً تلقائياً عند Foreground | استخدم `flutter_local_notifications` داخل `onMessage` |
| الـ Token لا يُرسَل للـ Backend | يُرسَل مرة واحدة فقط عند أول تشغيل | استمع لـ `onTokenRefresh` لتحديثه تلقائياً |
| Firestore لا يُعيد نتائج | مشكلة في قواعد الأمان أو الـ index | افتح Firebase Console وتحقق من Firestore Rules + Indexes |
| background handler لا يعمل | يجب أن تكون top-level function مع `@pragma` | لا تضعها داخل class |
| الـ Stream لا يُلغى | memory leak | ألغِ الـ subscription في `onClose()` |
| Firestore index error | orderBy على حقلين بدون index | أنشئ Composite Index من Firebase Console |
```
