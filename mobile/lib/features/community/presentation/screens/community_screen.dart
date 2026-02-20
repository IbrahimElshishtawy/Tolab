import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text('2 hours ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('This is a post in the community about Software Engineering patterns.'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.thumb_up_outlined)),
                      const Text('12'),
                      const SizedBox(width: 20),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.comment_outlined)),
                      const Text('5'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
