import 'package:flutter/material.dart';
import 'package:tolab_fci/features/community/presentation/screens/messages_screen.dart';
import 'package:tolab_fci/features/community/presentation/widgets/post_card.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
              "مجتمع Tolab",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessagesScreen(),
                  ),
                );
              },
              child: Icon(Icons.message),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return PostCard();
        },
      ),
    );
  }
}
