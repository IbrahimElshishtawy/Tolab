import 'package:flutter/material.dart';
import 'package:tolab_fci/features/community/presentation/widgets/chat_tile.dart';

class StudyGroupsTab extends StatelessWidget {
  const StudyGroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: const [
        ChatTile(
          name: "Math 3",
          time: "6:05 PM",
          message: "تم إضافة محاضرة جديدة",
          image: "assets/images/pfp.png",
        ),
        ChatTile(
          name: "Algorithms",
          time: "5:22 PM",
          message: "موعد الـ Mid الأسبوع القادم",
          image: "assets/images/pfp.png",
        ),
      ],
    );
  }
}