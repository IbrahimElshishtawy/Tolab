// lib/widgets/chat_title.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatTitle extends StatelessWidget {
  final String userName;
  final String? userImage;

  const ChatTitle({super.key, required this.userName, this.userImage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: isDark ? Colors.black : Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: userImage != null && userImage!.isNotEmpty
                ? NetworkImage(userImage!)
                : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              userName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(CupertinoIcons.ellipsis_vertical, size: 20),
        ],
      ),
    );
  }
}
