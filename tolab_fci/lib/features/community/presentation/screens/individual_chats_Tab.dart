import 'package:flutter/material.dart';
import 'package:tolab_fci/features/community/presentation/widgets/chat_tile.dart';

class IndividualChatsTab extends StatelessWidget {
  const IndividualChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: const [
        ChatTile(
          name: "Ibrahim030",
          time: "11:05 AM",
          message: "بعت ملخصات مادة Web اللي طلبتها منك",
          image: "assets/images/pfp.png",
        ),
        ChatTile(
          name: "Nada022",
          time: "12:23 PM",
          message: "محاضرة Network النهاردة الساعة كام؟",
          image: "assets/images/pfp.png",
        ),
        ChatTile(
          name: "Mostafa25",
          time: "1:05 PM",
          message: "ممكن تبعت شيتات مادة Algorithm؟",
          image: "assets/images/pfp.png",
        ),
      ],
    );
  }
}