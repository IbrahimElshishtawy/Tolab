import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/page/chat/chat/pages/chat_page.dart';

class PrivateChatsPage extends StatelessWidget {
  const PrivateChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('private_chats')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("لا توجد محادثات"));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = List<String>.from(chat['participants']);

              // دعم المحادثة مع النفس
              final otherUserId = participants.length == 1
                  ? currentUserId
                  : participants.firstWhere((id) => id != currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox();

                  final user = userSnapshot.data!;
                  final name = user['name'] ?? 'مستخدم';
                  final imageUrl = user['imageUrl'];

                  return ListTile(
                    leading: imageUrl != null && imageUrl.toString().isNotEmpty
                        ? CircleAvatar(backgroundImage: NetworkImage(imageUrl))
                        : CircleAvatar(
                            backgroundColor: Colors.grey[400],
                            child: Text(
                              name.isNotEmpty ? name[0] : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                    title: Text(name),
                    subtitle: Text(chat['lastMessage'] ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            otherUserId: otherUserId,
                            otherUserName: name,
                            groupId: '',
                            groupName: '',
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
