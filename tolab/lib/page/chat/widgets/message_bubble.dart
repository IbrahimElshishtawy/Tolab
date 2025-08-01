import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMe
              ? (isDark ? Colors.blue[600] : Colors.blue[700])
              : (isDark ? Colors.grey[800] : Colors.grey[300]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white70
                        : (isDark ? Colors.white38 : Colors.black54),
                    fontSize: 12,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 5),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 18,
                    color: isRead
                        ? Colors.greenAccent
                        : (isDark ? Colors.white38 : Colors.white70),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
