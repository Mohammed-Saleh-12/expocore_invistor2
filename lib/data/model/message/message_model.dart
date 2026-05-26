class MessageModel {
  final int    id;
  final String text;
  final bool   isMe;
  final String time;
  final bool   isRead;

  MessageModel({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    required this.isRead,
  });
}
