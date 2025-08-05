import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/page/chat/chat/widget/message_bubble.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final user = FirebaseAuth.instance.currentUser;

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || user == null) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .add({
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
          'sender': user!.displayName ?? user!.email ?? 'مستخدم',
          'uid': user!.uid,
        });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.groupName),
        previousPageTitle: 'رجوع',
      ),
      child: SafeArea(
        child: Column(
          children: [
            // الرسائل
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.groupId)
                    .collection('messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final text = msg['text'] ?? '';
                      final sender = msg['sender'] ?? 'مجهول';
                      final uid = msg['uid'] ?? '';
                      final timestamp = msg['timestamp'] as Timestamp?;
                      final time = timestamp != null
                          ? DateFormat.Hm().format(timestamp.toDate())
                          : '';

                      final isMe = uid == user?.uid;

                      return MessageBubble(
                        message: text,
                        sender: sender,
                        time: time,
                        isMe: isMe,
                      );
                    },
                  );
                },
              ),
            ),

            // حقل إدخال الرسائل
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: isDark
                  ? CupertinoColors.darkBackgroundGray
                  : CupertinoColors.systemGrey6,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _messageController,
                      placeholder: 'اكتب رسالة...',
                      onSubmitted: (_) => _sendMessage(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? CupertinoColors.systemGrey6
                            : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: _sendMessage,
                    child: const Icon(CupertinoIcons.paperplane_fill),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
