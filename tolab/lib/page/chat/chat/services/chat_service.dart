import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/page/chat/chat/services/notification_service.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<List<ChatMessageModel>> getMessages(String otherUserId) {
    final currentUserId = _auth.currentUser!.uid;
    return _firestore
        .collection('chats')
        .doc(_getChatId(currentUserId, otherUserId))
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String receiverId,
    required String text,
    String? imageUrl,
  }) async {
    final currentUser = _auth.currentUser!;
    final message = ChatMessageModel(
      id: '',
      senderId: currentUser.uid,
      receiverId: receiverId,
      text: text,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      isRead: false,
    );

    final chatId = _getChatId(currentUser.uid, receiverId);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': text,
      'timestamp': Timestamp.now(),
      'senderId': currentUser.uid,
      'receiverId': receiverId,
    });

    await NotificationService.sendNotificationToUser(
      receiverId: receiverId,
      message: text,
    );
  }

  Future<void> markMessagesAsRead(String otherUserId) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = _getChatId(currentUserId, otherUserId);

    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  Future<void> editMessage({
    required String messageId,
    required String newText,
  }) async {}
}
