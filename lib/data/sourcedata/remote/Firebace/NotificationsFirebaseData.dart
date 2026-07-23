import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expocore_invistor2/data/model/notification/notification_model.dart';

// ════════════════════════════════════════════════════════════
//  NotificationsFirebaseData
//  الإشعارات تُخزَّن في Firestore:
//    /notifications/{userId}/items/{notifId}
//  البك-اند يكتب في هذه المجموعة عند إرسال أي إشعار
// ════════════════════════════════════════════════════════════
class NotificationsFirebaseData {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) => _db
      .collection('notifications')
      .doc(userId)
      .collection('items');

  /// Stream لقائمة الإشعارات — مرتبة بالأحدث أولاً
  Stream<List<NotificationModel>> notificationsStream(String userId) {
    return _col(userId)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromJson({...d.data(), 'id': _toIntId(d.id)}))
            .toList());
  }

  /// تعليم إشعار كمقروء
  Future<void> markRead(String userId, int notifId) async {
    final doc = _col(userId).doc(notifId.toString());
    await doc.update({'is_read': true});
  }

  /// تعليم جميع الإشعارات كمقروءة
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
