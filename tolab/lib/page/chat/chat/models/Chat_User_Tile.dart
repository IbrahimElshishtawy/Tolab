// lib/widgets/chat_user_tile.dart

import 'package:flutter/material.dart';
import 'package:tolab/page/chat/chat/pages/chat_page.dart';

class ChatUserTile extends StatelessWidget {
  final String userId;
  final String name;
  final String? imageUrl;
  final String lastMessage;

  const ChatUserTile({
    super.key,
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.lastMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: imageUrl != null && imageUrl!.isNotEmpty
          ? CircleAvatar(backgroundImage: NetworkImage(imageUrl!))
          : CircleAvatar(
              backgroundColor: Colors.grey[400],
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
      title: Text(name),
      subtitle: Text(lastMessage),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              otherUserId: userId,
              otherUserName: name,
              groupId: '',
              groupName: '',
            ),
          ),
        );
      },
    );
  }
}
