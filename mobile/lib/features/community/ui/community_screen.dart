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
          return PostCard(index: index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final int index;
  const PostCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostDetailsScreen(index: index)),
          );
        },
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
              const SizedBox(height: 12),
              const Text('This is an interesting post about our current Software Engineering patterns. What do you think?'),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.thumb_up_outlined, size: 18),
                  const SizedBox(width: 4),
                  const Text('12'),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment_outlined, size: 18),
                  const SizedBox(width: 4),
                  const Text('5'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostDetailsScreen extends StatelessWidget {
  final int index;
  const PostDetailsScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PostCard(index: index),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, i) {
                return ListTile(
                  leading: const CircleAvatar(radius: 14),
                  title: Text('Commenter ${i + 1}'),
                  subtitle: const Text('I agree with this point!'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
