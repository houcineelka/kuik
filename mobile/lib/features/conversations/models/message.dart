class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final int conversationId;
  final int senderId;
  final String content;
  final DateTime createdAt;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as int,
        conversationId: json['conversation_id'] as int,
        senderId: json['sender_id'] as int,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
