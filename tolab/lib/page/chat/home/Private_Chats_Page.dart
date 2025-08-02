// lib/page/chat/chat/pages/private_chats_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/page/chat/chat/models/Chat_User_Tile.dart';

class PrivateChatsPage extends StatelessWidget {
  const PrivateChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("حدث خطأ أثناء تحميل المحادثات"));
          }

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

              // تحديد الـ otherUserId
              final otherUserId =
                  (participants.length == 1 ||
                      participants.every((id) => id == currentUserId))
                  ? currentUserId
                  : participants.firstWhere((id) => id != currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError) {
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.error)),
                      title: Text("حدث خطأ في تحميل المستخدم"),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text("مستخدم غير معروف"),
                    );
                  }

                  try {
                    final user = userSnapshot.data!;
                    final name = user['name'] ?? 'مستخدم';
                    final imageUrl = user['imageUrl'];
                    final lastMessage = chat['lastMessage'] ?? '';

                    return ChatUserTile(
                      userId: otherUserId,
                      name: otherUserId == currentUserId
                          ? 'أنا (محادثة مع نفسي)'
                          : name,
                      imageUrl: imageUrl,
                      lastMessage: lastMessage,
                    );
                  } catch (e) {
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.error_outline)),
                      title: Text("خطأ أثناء عرض المحادثة"),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
