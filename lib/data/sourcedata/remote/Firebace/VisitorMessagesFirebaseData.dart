import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expocore_invistor2/data/model/message/message_model.dart';
import 'package:expocore_invistor2/data/model/message/visitor_conversation_model.dart';

// ════════════════════════════════════════════════════════════
//  VisitorMessagesFirebaseData
//  محادثات المستثمر مع الزوار — Firestore:
//    /visitor_conversations/{conversationId}
//    /visitor_conversations/{conversationId}/messages/{messageId}
// ════════════════════════════════════════════════════════════
class VisitorMessagesFirebaseData {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('visitor_conversations');

  /// Stream لقائمة محادثات الزوار الخاصة بالمستثمر
  Stream<List<VisitorConversationModel>> conversationsStream(int investorId) {
    return _col
        .where('investor_id', isEqualTo: investorId)
        .orderBy('last_time', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                VisitorConversationModel.fromJson({...d.data(), 'id': _toInt(d.id)}))
            .toList());
  }

  /// Stream لرسائل محادثة زائر واحدة
  Stream<List<MessageModel>> messagesStream(String conversationId) {
    return _col
        .doc(conversationId)
        .collection('messages')
        .orderBy('time')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MessageModel.fromJson(d.data())).toList());
  }

  /// إرسال رسالة للزائر
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

  /// تعليم رسائل المحادثة كمقروءة
  Future<void> markConversationRead(String conversationId) async {
    await _col.doc(conversationId).update({'unread_count': 0});
  }

  int _toInt(String id) => int.tryParse(id) ?? id.hashCode;
}
