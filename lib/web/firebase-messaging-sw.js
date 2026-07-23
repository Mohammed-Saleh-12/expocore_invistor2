// Firebase Cloud Messaging Service Worker
// هذا الملف مطلوب لاستقبال إشعارات FCM في الخلفية على المتصفح (ويب)
// يجب أن يكون في مجلد web/ ليكون متاحاً على /firebase-messaging-sw.js

importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

// ── إعدادات Firebase (يجب أن تطابق firebase_options.dart) ──
firebase.initializeApp({
  apiKey:            "AIzaSyBQB_3hs9Rt2S43MEFYB0dJAuXLJoMxlt8",
  authDomain:        "expocore-57f9f.firebaseapp.com",
  databaseURL:       "https://expocore-57f9f-default-rtdb.firebaseio.com",
  projectId:         "expocore-57f9f",
  storageBucket:     "expocore-57f9f.firebasestorage.app",
  messagingSenderId: "940238627133",
  appId:             "1:940238627133:web:74975f11ce319a2be7e554",
});

const messaging = firebase.messaging();

// استقبال الإشعارات في الخلفية (background)
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Background message received:', payload);
  const { title, body } = payload.notification ?? {};
  if (title) {
    self.registration.showNotification(title, {
      body:  body  ?? '',
      icon:  '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
    });
  }
});
