import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/page/chat/chat/models/chat_message_model.dart';
import 'package:tolab/page/chat/chat/models/chat_user_model.dart';
import 'package:tolab/page/chat/chat/models/chat_tile.dart';

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return ChatMessageModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
