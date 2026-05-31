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

  factory ConversationModel.fromJson(Map<String, dynamic> j) =>
      ConversationModel(
        id:                  j['id'] ?? 0,
        exhibitionId:        j['exhibition_id'] ?? 0,
        exhibitionName:      j['exhibition_name'] ?? '',
        exhibitionInitials:  j['exhibition_initials'] ?? '',
        color: int.tryParse(
                  (j['color'] as String? ?? 'FF7A1FFF').replaceFirst('#', ''),
                  radix: 16,
                ) ??
                0xFF7A1FFF,
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
