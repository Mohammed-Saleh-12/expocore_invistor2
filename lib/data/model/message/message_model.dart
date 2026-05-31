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

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
    id:     j['id']       ?? 0,
    text:   j['text']     ?? j['body'] ?? '',
    isMe:   j['is_me']    ?? false,
    time:   j['time']     ?? j['created_at'] ?? '',
    isRead: j['is_read']  ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id':      id,
    'text':    text,
    'is_me':   isMe,
    'time':    time,
    'is_read': isRead,
  };
}
