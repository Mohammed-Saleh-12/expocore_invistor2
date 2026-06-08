import 'message_model.dart';

class VisitorConversationModel {
  final int    id;
  final String visitorName;
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
        id:              j['id'] ?? 0,
        visitorName:     j['visitor_name'] ?? '',
        visitorInitials: j['visitor_initials'] ?? '',
        color: int.tryParse(
                  (j['color'] as String? ?? 'FFFF1592').replaceFirst('#', ''),
                  radix: 16,
                ) ??
                0xFFFF1592,
        messages: (j['messages'] as List? ?? [])
            .map((m) => MessageModel.fromJson(m))
            .toList(),
        unreadCount: j['unread_count'] ?? 0,
      );

  MessageModel? get lastMessageObj =>
      messages.isNotEmpty ? messages.last : null;

  String get lastMessage => lastMessageObj?.text ?? '';
  String get lastTime    => lastMessageObj?.time ?? '';
}
