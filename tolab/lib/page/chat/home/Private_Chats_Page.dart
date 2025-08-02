// lib/page/chat/chat/pages/private_chats_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/page/chat/chat/models/Chat_User_Tile.dart';

class PrivateChatsPage extends StatelessWidget {
  const PrivateChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    print('Current User ID: $currentUserId');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.hasError) {
            print("Error loading chats: ${snapshot.error}");
            return const Center(child: Text("Error loading chats"));
          }

          if (!snapshot.hasData) {
            print("Loading chats...");
            return const Center(child: CircularProgressIndicator());
          }

          final List<QueryDocumentSnapshot> chats = snapshot.data!.docs;
          print("Found ${chats.length} chat(s)");

          if (chats.isEmpty) {
            print("No chats found");
            return const Center(child: Text("No chats found"));
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              final chat = chats[index];
              final List<String> participants = List<String>.from(
                chat['participants'],
              );
              final String otherUserId =
                  (participants.length == 1 ||
                      participants.every((id) => id == currentUserId))
                  ? currentUserId
                  : participants.firstWhere((id) => id != currentUserId);

              print("Chat [$index] with user ID: $otherUserId");

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError) {
                    print(
                      "Error loading user [$otherUserId]: ${userSnapshot.error}",
                    );
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.error)),
                      title: Text("Error loading user"),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    print("User [$otherUserId] not found in database");
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text("Unknown user"),
                    );
                  }

                  try {
                    final user = userSnapshot.data!;
                    final String name = user['name'] ?? 'User';
                    final String? imageUrl = user['imageUrl'];
                    final String lastMessage = chat['lastMessage'] ?? '';

                    print("User [$otherUserId] name: $name");
                    print("Last message: $lastMessage");

                    return ChatUserTile(
                      userId: otherUserId,
                      name: otherUserId == currentUserId
                          ? 'Me (Self Chat)'
                          : name,
                      imageUrl: imageUrl,
                      lastMessage: lastMessage,
                    );
                  } catch (e) {
                    print("Exception displaying chat [$otherUserId]: $e");
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.error_outline)),
                      title: Text("Error displaying chat"),
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
