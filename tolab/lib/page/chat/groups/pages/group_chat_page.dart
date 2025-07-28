// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupChatPage extends StatefulWidget {
  final String groupName;

  const GroupChatPage({super.key, required this.groupName});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = {
      'sender': 'أنت',
      'text': text,
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    };

    setState(() {
      messages.add(message);
      _messageController.clear();
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessage(Map<String, dynamic> message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe
              ? CupertinoColors.activeBlue.withOpacity(0.8)
              : CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message['sender'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            Text(message['text'], style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              message['time'],
              style: const TextStyle(
                fontSize: 10,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
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
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['sender'] == 'أنت';
                  return _buildMessage(msg, isMe);
                },
              ),
            ),
            // إدخال رسالة
            Container(
              color: isDark
                  ? CupertinoColors.darkBackgroundGray
                  : CupertinoColors.extraLightBackgroundGray,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _messageController,
                      placeholder: 'اكتب رسالة...',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _sendMessage,
                    child: const Icon(
                      CupertinoIcons.arrow_up_circle_fill,
                      size: 30,
                    ),
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
