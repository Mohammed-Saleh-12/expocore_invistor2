import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseChatService {
  FirebaseChatService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final Map<String, StreamSubscription> _listeners = {};

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  CollectionReference<Map<String, dynamic>> _messagesRef(
    String conversationId,
  ) => _conversations.doc(conversationId).collection('messages');

  Future<String> createConversation({
    required String creatorId,
    required String title,
    required List<String> participants,
    required String type,
  }) async {
    final ref = await _conversations.add({
      'id': '',
      'title': title,
      'participants': participants,
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'type': type,
      'createdBy': creatorId,
    });

    await ref.update({'id': ref.id});
    return ref.id;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    List<String> attachments = const [],
  }) async {
    final messageRef = _messagesRef(conversationId).doc();
    final message = {
      'id': messageRef.id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': <String>[senderId],
      'attachments': attachments,
    };

    final batch = _firestore.batch();
    batch.set(messageRef, message);
    batch.update(_conversations.doc(conversationId), {
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> subscribeToMessages(
    String conversationId,
  ) {
    final key = 'messages:$conversationId';
    _listeners[key]?.cancel();
    final sub = _messagesRef(
      conversationId,
    ).orderBy('createdAt', descending: false).snapshots();
    _listeners[key] = sub.listen((_) {});
    return _messagesRef(
      conversationId,
    ).orderBy('createdAt', descending: false).snapshots();
  }

  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    final snapshot = await _messagesRef(
      conversationId,
    ).where('readBy', isNotEqualTo: null).get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      final readBy = List<String>.from(doc.data()['readBy'] ?? <String>[]);
      if (!readBy.contains(userId)) {
        readBy.add(userId);
        batch.update(doc.reference, {'readBy': readBy});
      }
    }
    await batch.commit();
  }

  void disposeListener(String conversationId) {
    final key = 'messages:$conversationId';
    _listeners[key]?.cancel();
    _listeners.remove(key);
  }

  Future<void> addConversationMember({
    required String conversationId,
    required String userId,
  }) async {
    final ref = _firestore
        .collection('conversation_members')
        .doc('${conversationId}_$userId');
    await ref.set({
      'conversationId': conversationId,
      'userId': userId,
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    final doc = await _conversations.doc(conversationId).get();
    return doc.data() ?? {};
  }

  void dispose() {
    for (final sub in _listeners.values) {
      sub.cancel();
    }
    _listeners.clear();
  }
}
