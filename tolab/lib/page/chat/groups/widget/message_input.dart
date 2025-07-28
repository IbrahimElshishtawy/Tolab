import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final void Function(String message) onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  String _currentMessage = '';

  void _sendMessage() {
    if (_currentMessage.trim().isEmpty) return;
    widget.onSend(_currentMessage.trim());
    _controller.clear();
    setState(() {
      _currentMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? CupertinoColors.darkBackgroundGray : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _controller,
              placeholder: 'اكتب رسالة...',
              minLines: 1,
              maxLines: 4,
              onChanged: (value) {
                setState(() {
                  _currentMessage = value;
                });
              },
              onSubmitted: (_) => _sendMessage(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? CupertinoColors.systemGrey6
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: CircleAvatar(
              backgroundColor: CupertinoColors.activeBlue,
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
