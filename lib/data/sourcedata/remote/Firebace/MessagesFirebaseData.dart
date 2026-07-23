import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expocore_invistor2/data/model/message/conversation_model.dart';
import 'package:expocore_invistor2/data/model/message/message_model.dart';

// ════════════════════════════════════════════════════════════
//  MessagesFirebaseData
//  محادثات المستثمر مع المعارض — Firestore:
//    /conversations/{conversationId}
//    /conversations/{conversationId}/messages/{messageId}
// ════════════════════════════════════════════════════════════
class MessagesFirebaseData {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conv =>
      _db.collection('conversations');

  /// Stream لقائمة المحادثات الخاصة بالمستثمر
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
        .map((snap) =>
            snap.docs.map((d) => MessageModel.fromJson(d.data())).toList());
  }

  /// إنشاء محادثة جديدة مع معرض
  Future<String> createConversation({
    required int    investorId,
    required int    exhibitionId,
    required String exhibitionName,
    required String exhibitionInitials,
    required int    color,
  }) async {
    final ref = await _conv.add({
      'investor_id':          investorId,
      'exhibition_id':        exhibitionId,
      'exhibition_name':      exhibitionName,
      'exhibition_initials':  exhibitionInitials,
      'color':                color.toRadixString(16).toUpperCase(),
      'unread_count':         0,
      'last_message':         '',
      'last_time':            FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// إرسال رسالة
  Future<void> sendMessage({
    required String conversationId,
    required int    senderId,
    required String text,
    required bool   isMe,
  }) async {
    final batch = _db.batch();
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

  /// تعليم رسائل المحادثة كمقروءة
  Future<void> markConversationRead(String conversationId) async {
    await _conv.doc(conversationId).update({'unread_count': 0});
  }

  int _toInt(String id) => int.tryParse(id) ?? id.hashCode;
}