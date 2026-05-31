import 'message_model.dart';

class VisitorConversationModel {
  final int id;
  final String visitorName;
  final String visitorInitials;
  final int color;
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

  MessageModel? get lastMessageObj =>
      messages.isNotEmpty ? messages.last : null;

  String get lastMessage => lastMessageObj?.text ?? '';
  String get lastTime    => lastMessageObj?.time ?? '';
}
