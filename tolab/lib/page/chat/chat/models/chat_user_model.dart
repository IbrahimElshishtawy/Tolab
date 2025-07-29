import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUserModel {
  final String uid;
  final String name;
  final String email;
  final String? imageUrl;
  final bool isOnline;
  final DateTime lastSeen;

  ChatUserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.isOnline,
    required this.lastSeen,
  });

  // تحويل من Map إلى Object
  factory ChatUserModel.fromMap(Map<String, dynamic> map) {
    return ChatUserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      imageUrl: map['imageUrl'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp).toDate(),
    );
  }

  // تحويل من Object إلى Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }
}
