import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_user_model.dart';
import '../models/chat_message_model.dart';
import 'chat_page.dart'; // صفحة الدردشة بين المستخدمين

class IndividualChatsPage extends StatefulWidget {
  const IndividualChatsPage({super.key});

  @override
  State<IndividualChatsPage> createState() => _IndividualChatsPageState();
}

class _IndividualChatsPageState extends State<IndividualChatsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get currentUserId => _auth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final chatDocs = snapshot.data!.docs;

          final Map<String, ChatMessageModel> lastMessages = {};

          for (var doc in chatDocs) {
            final msg = ChatMessageModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
            final otherUserId = msg.senderId == currentUserId
                ? msg.receiverId
                : msg.senderId;

            if (!lastMessages.containsKey(otherUserId)) {
              lastMessages[otherUserId] = msg;
            }
          }

          final users = lastMessages.keys.toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final otherUserId = users[index];
              final lastMsg = lastMessages[otherUserId]!;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox();

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final otherUser = ChatUserModel.fromMap(userData);

                  return ListTile(
                    leading:
                        otherUser.imageUrl != null &&
                            otherUser.imageUrl!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(otherUser.imageUrl!),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.grey[400],
                            child: Text(
                              otherUser.name.isNotEmpty
                                  ? otherUser.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                    title: Text(otherUser.name),
                    subtitle: Text(lastMsg.text),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            otherUserId: otherUser.uid,
                            otherUserName: otherUser.name,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
