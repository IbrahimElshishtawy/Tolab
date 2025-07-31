import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/page/chat/chat/controllers/chat_controller.dart';
import 'package:tolab/page/chat/chat/models/chat_message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required String receiverId,
    required receiverName,
    required bool isGroup,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _editingMessageId;

  @override
  void initState() {
    super.initState();
    final chatController = Provider.of<ChatController>(context, listen: false);
    chatController.loadMessages(widget.otherUserId);
    chatController.markMessagesAsRead(widget.otherUserId);
  }

  void _sendMessage() {
    final chatController = Provider.of<ChatController>(context, listen: false);
    final text = _messageController.text.trim();

    if (_editingMessageId != null) {
      chatController.editMessage(messageId: _editingMessageId!, newText: text);
      _editingMessageId = null;
    } else {
      chatController.sendMessage(receiverId: widget.otherUserId, text: text);
    }

    _messageController.clear();
  }

  void _startEditing(ChatMessageModel message) {
    setState(() {
      _messageController.text = message.text;
      _editingMessageId = message.messageId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatController>(
              builder: (context, controller, child) {
                final messages = controller.messages;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - index - 1];
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
                              _startEditing(message);
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _editingMessageId != null
                          ? 'تعديل الرسالة...'
                          : 'اكتب رسالة...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
