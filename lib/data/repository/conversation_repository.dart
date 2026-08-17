import 'package:get/get.dart';

import '../../core/services/firebase_chat_service.dart';

class ConversationRepository extends GetxService {
  final FirebaseChatService _chatService = FirebaseChatService();

  Future<String> createConversation({
    required String creatorId,
    required String title,
    required List<String> participants,
    required String type,
  }) async {
    return _chatService.createConversation(
      creatorId: creatorId,
      title: title,
      participants: participants,
      type: type,
    );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    List<String> attachments = const [],
  }) async {
    await _chatService.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      attachments: attachments,
    );
  }

  Stream<dynamic> subscribeToMessages(String conversationId) {
    return _chatService.subscribeToMessages(conversationId);
  }

  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    await _chatService.markMessagesAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }

  Future<void> addConversationMember({
    required String conversationId,
    required String userId,
  }) async {
    await _chatService.addConversationMember(
      conversationId: conversationId,
      userId: userId,
    );
  }
}
