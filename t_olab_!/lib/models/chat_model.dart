class ChatModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime sentAt;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.sentAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    id: json['id'],
    senderId: json['sender_id'],
    receiverId: json['receiver_id'],
    message: json['message'],
    sentAt: DateTime.parse(json['sent_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'message': message,
    'sent_at': sentAt.toIso8601String(),
  };
}
