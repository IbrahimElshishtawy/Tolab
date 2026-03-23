class MessageModel {
  const MessageModel({
    required this.id,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.isMine = false,
  });

  final String id;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final bool isMine;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    return MessageModel(
      id: (json['id'] ?? '').toString(),
      senderName:
          (sender?['name'] ?? json['sender_name'] ?? 'Unknown') as String,
      content: (json['content'] ?? json['body'] ?? '') as String,
      sentAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      isMine: json['is_mine'] as bool? ?? false,
    );
  }
}
