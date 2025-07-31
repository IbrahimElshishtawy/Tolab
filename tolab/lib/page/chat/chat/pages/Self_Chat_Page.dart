import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolab/page/chat/chat/pages/chat_tile.dart';
import '../models/chat_message_model.dart';
import '../models/chat_user_model.dart';

import 'package:firebase_auth/firebase_auth.dart';

class SelfChatPage extends StatefulWidget {
  const SelfChatPage({super.key});

  @override
  State<SelfChatPage> createState() => _SelfChatPageState();
}

class _SelfChatPageState extends State<SelfChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String currentUserId;
  ChatUserModel? currentUser;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      getCurrentUser();
    }
  }

  Future<void> getCurrentUser() async {
    final doc = await _firestore.collection('users').doc(currentUserId).get();
    if (doc.exists) {
      setState(() {
        currentUser = ChatUserModel.fromMap(doc.data()!);
      });
    }
  }

  void sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessageModel(
      id: '',
      senderId: currentUserId,
      receiverId: currentUserId,
      text: text,
      imageUrl: null,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _firestore.collection('chats').add(message.toMap());
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ChatTitle(
          userName: currentUser!.name,
          userImage: currentUser!.imageUrl,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('senderId', isEqualTo: currentUserId)
                  .where('receiverId', isEqualTo: currentUserId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final messages = snapshot.data!.docs
                    .map(
                      (doc) => ChatMessageModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          msg.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "اكتب رسالة...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
