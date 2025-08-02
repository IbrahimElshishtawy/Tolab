// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolab/page/chat/chat/controllers/chat_controller.dart';
import 'package:tolab/page/chat/chat/models/chat_message_model.dart';
import 'package:tolab/page/chat/chat/models/chat_user_model.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? groupId;
  final String? groupName;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.groupId,
    this.groupName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  String? editingMessageId;

  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;
  ChatUserModel? currentUserInfo;

  @override
  void initState() {
    super.initState();
    print('📥 ChatPage started. Current user: $currentUserId');

    final chatController = Provider.of<ChatController>(context, listen: false);

    chatController.markMessagesAsRead(widget.otherUserId);
    print('✅ Marked messages as read for ${widget.otherUserId}');

    if (widget.otherUserId == currentUserId) {
      _loadCurrentUserInfo();
    }
  }

  Future<void> _loadCurrentUserInfo() async {
    print('📡 Loading current user info...');
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    if (doc.exists) {
      currentUserInfo = ChatUserModel.fromMap(doc.data()!);
      print('✅ Current user loaded: ${currentUserInfo!.name}');
      setState(() {});
    } else {
      print('⚠️ User not found!');
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    print('📨 Sending message: $text');
    final chatController = Provider.of<ChatController>(context, listen: false);

    if (editingMessageId != null) {
      await chatController.editMessage(
        messageId: editingMessageId!,
        newText: text,
      );
      print('✏️ Message edited: $editingMessageId');
      editingMessageId = null;
    } else {
      await chatController.sendMessage(
        receiverId: widget.otherUserId,
        text: text,
      );
      print('✅ Message sent to ${widget.otherUserId}');
    }

    _messageController.clear();
  }

  void _startEditing(ChatMessageModel message) {
    print('✏️ Start editing message: ${message.id}');
    setState(() {
      editingMessageId = message.id;
      _messageController.text = message.text;
    });
  }

  void _cancelEditing() {
    print('❌ Cancel editing');
    setState(() {
      editingMessageId = null;
      _messageController.clear();
    });
  }

  void _deleteMessage(String messageId) async {
    print('🗑️ Deleting message: $messageId');
    final chatController = Provider.of<ChatController>(context, listen: false);
    await chatController.deleteMessage(messageId);
    print('✅ Message deleted');
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context, listen: false);
    final isSelfChat = widget.otherUserId == currentUserId;
    final displayName = isSelfChat
        ? (currentUserInfo?.name ?? 'أنا')
        : widget.otherUserName;
    final displayImage = isSelfChat ? currentUserInfo?.imageUrl : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: displayImage != null && displayImage.isNotEmpty
                  ? NetworkImage(displayImage)
                  : null,
              child: displayImage == null || displayImage.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(displayName),
          ],
        ),
        actions: [
          if (editingMessageId != null)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _cancelEditing,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: chatController.getMessageStream(widget.otherUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('❌ Error loading messages: ${snapshot.error}');
                  return const Center(
                    child: Text('حدث خطأ أثناء تحميل الرسائل'),
                  );
                }

                final messages = snapshot.data ?? [];
                print('💬 Loaded ${messages.length} messages');

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId == currentUserId;

                    return ListTile(
                      title: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      onLongPress: isMe
                          ? () {
                              print('📥 Options for message: ${message.id}');
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text("تعديل"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _startEditing(message);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text("حذف"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _deleteMessage(message.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: editingMessageId != null
                          ? 'تعديل الرسالة...'
                          : 'اكتب رسالة...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    editingMessageId != null ? Icons.check : Icons.send,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
