import 'message_model.dart';

class ConversationModel {
  final int    id;
  final int    exhibitionId;
  final String exhibitionName;
  final String exhibitionInitials;
  final int    color;
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

  MessageModel? get lastMessageObj =>
      messages.isNotEmpty ? messages.last : null;

  String get lastMessage => lastMessageObj?.text ?? '';
  String get lastTime    => lastMessageObj?.time ?? '';
}