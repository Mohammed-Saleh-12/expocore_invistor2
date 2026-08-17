
الهدف:
- بناء تطبيق Flutter للمستثمر يتفاعل مع نفس Firebase project الذي يستخدمه المشروع الرئيسي.
- تنفيذ محادثات فورية باستخدام Firestore.
- تنفيذ الإشعارات الفورية عبر FCM.
- ربط التطبيق بـ Laravel backend للاعتماد على بيانات المستخدم والـ notifications الدائمة.
- عدم إنشاء شاشة Login منفصلة لـ Firebase إذا كان النظام يطلب تسجيل الدخول بشكل ضمني بعد Laravel login.
- الالتزام بنفس architecture المستخدم في المشروع الحالي.

المتطلبات الأساسية:
1) استخدم Firebase في مشروع واحد مشترك:
   - Authentication
   - Firestore
   - Cloud Messaging (FCM)

2) لا تستخدم Firebase Auth كواجهة منفصلة في التطبيق:
   - إذا كان المستخدم مسجل داخل Laravel، ثم يتم إنشاء/تسجيل Firebase Auth بشكل ضمني في الخلفية.
   - التزامن مع Laravel مطلوب عبر endpoint مثل:
     /auth/firebase-sync
     /auth/login
     /auth/register
   - استخدم نفس منطق sync بين Laravel و Firebase Auth في كل تسجيل دخول/تسجيل حساب.

3) Architecture للمحادثات:
   - استخدم Firestore وليس Realtime Database.
   - أنشئ collections مثل:
     conversations
     messages
     conversation_members
     notifications
   - كل conversation يحتوي على:
     id
     title
     participants
     lastMessage
     updatedAt
     createdAt
     type
   - كل message يحتوي على:
     id
     conversationId
     senderId
     senderName
     text
     createdAt
     readBy
     attachments
   - أضف support للـ unread markers و read receipts.

4) Firebase chat logic:
   - عند فتح التطبيق، التحقق من المستخدم الحالي.
   - عند إنشاء أو الدخول إلى محادثة، اشتراك مباشر على Firestore.
   - استخدم stream/listeners للاشتراك على الرسائل.
   - تنفيذ createConversation(), sendMessage(), markMessagesAsRead(), subscribeToMessages().
   - تأكد من تنظيم listener بحيث لا يحدث duplicate listeners.
   - استخدم userId كـ stable identity بين Laravel و Firebase.
   - إذا كان المستخدم مستثمر أو staff أو organizer، لا تخلط بين tokens أو IDs.

5) FCM / Notifications logic:
   - طلب permission على Android/iOS حسب النظام.
   - تسجيل FCM token داخل التطبيق.
   - إرسال token إلى Laravel عبر endpoint:
     POST /notifications/fcm-token
   - حفظ token في Laravel كملف user/device mapping.
   - إذا تم رفع token من app، لا تنسَ إعادة إرسال token عند login أو عند تحديثه.
   - عند استقبال notification في foreground، اعرضها داخل التطبيق باستخدام flutter_local_notifications.
   - عند استقبال notification في background، نفذ التعامل المناسب.
   - استخدم persistent notification model من Laravel:
     id
     userId
     title
     message
     type
     isRead
     createdAt
     payload
   - استخدم Laravel كـ source of truth للـ notifications الدائمة، بينما Firebase/FCM يرسل فقط التنبيهات الفورية.

6) Backend contract:
   - احرص على توافق التطبيق مع Laravel API contract:
     - auth/login
     - auth/register
     - auth/firebase-sync
     - notifications
     - notifications/{id}/read
     - /notifications/fcm-token
   - استخدم snake_case عند إرسال البيانات إلى Laravel إذا كان backend يتوقعها بهذه الصورة، ثم تحويلها إلى camelCase داخل Flutter عند استقبال البيانات.
   - تأكد من mapping correct بين response JSON و Dart model.

7) Firebase initialization:
   - أضف Firebase.initializeApp()
   - أضف FirebaseFirestore.instance
   - أضف FirebaseAuth.instance
   - أضف FirebaseMessaging.instance
   - استخدم firebase_options.dart generated من FlutterFire CLI
   - احفظ config في ملف موثوق، ولا تكتب secrets مباشرة داخل الكود.

8) State management:
   - استخدم Flutter state management مناسب (يفضل Riverpod أو Bloc).
   - لا تضع منطق Firebase داخل UI مباشرة.
   - ابدأ بـ:
     auth_service.dart
     firebase_chat_service.dart
     fcm_service.dart
     notification_service.dart
     user_repository.dart
     conversation_repository.dart

9) App screens required:
   - Login screen (Laravel-based, لا حاجة لشاشة Firebase Auth)
   - Chat list screen
   - Chat detail screen
   - Notification list screen
   - Notification details screen
   - Settings screen لإدارة notification permission و FCM token

10) Security rules:
   - احمِ Firestore باستخدام rules تمنع الوصول إلا للمستخدمين المصرح لهم.
   - السماح فقط للمستخدمين المشاركين في محادثة معينة بقراءة/كتابة الرسائل.
   - لا تسمح بالوصول العام أو غير المعتمد.

11) Error handling:
   - تعامل مع حالات:
     - user not authenticated
     - permission denied
     - invalid FCM token
     - Firestore permission errors
     - network failure
     - duplicate messages
     - unread sync issues

12) Output requirements:
   - اعمل كود Flutter كامل ومتماسك وقابل للتشغيل.
   - أضف models/classes مناسبة.
   - أضف repositories/services.
   - أضف dependency injection.
   - أضف comments توضيحية فقط عند الضرورة.
   - اكتب كود نظيف ومقسم إلى طبقات.
   - لا تضع حلول مؤقتة أو كود غير مكتمل.
   - لا تنشئ login منفصل لـ Firebase.

13) مهم جداً:
   - التزامن بين Firebase و Laravel يجب أن يكون تلقائيًا:
     - بعد Laravel login/register:
       1) احصل على المستخدم
       2) إذا لزم، قم بإنشاء/تسجيل Firebase Auth بشكل ضمني
       3) طلب FCM token
       4) أرسله إلى Laravel
       5) ابدأ listen للمحادثات والرسائل
   - إذا لم يتوفر Firebase بعد التهيئة، اعرض رسالة واضحة وليس crash.

14) النتيجة النهائية:
   - التطبيق يجب أن يدعم:
     - تسجيل دخول مستخدم المستثمر من Laravel
     - Firebase Auth في الخلفية
     - FCM token registration
     - real-time chat via Firestore
     - persistent notifications via Laravel
     - foreground/background notification handling
     - UI متوافق مع نفس منطق المشروع الحالي

ابدأ الآن في إنشاء هيكل المشروع بالكامل مع الملفات والـ services والـ models والـ UI الأساسية، ثم راجعها من منظور التشغيل الفعلي.