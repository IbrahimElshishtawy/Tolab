// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tolab/Features/posts/Notification/Notifications_Page.dart';
import 'package:tolab/Features/posts/add/Add_Post_Page.dart';
import 'package:tolab/Features/posts/controllers/post_controllers.dart';
import 'package:tolab/Features/posts/widgets/post_card.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 140,

        leading: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              const SizedBox(width: 15),
              const Text(
                'ToL',
                style: TextStyle(
                  color: Color.fromARGB(236, 13, 20, 217),
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/image_App/Tolab.png',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              const Text(
                'Ab',
                style: TextStyle(
                  color: Color.fromARGB(236, 13, 20, 217),
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
            ],
          ),
        ),

        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.bell,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.penToSquare,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPostPage()),
              );
            },
          ),
        ],
      ),

      body: Consumer<PostsController>(
        builder: (context, controller, child) {
          final posts = controller.posts;

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد بوستات بعد 📝',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              controller.fetchPosts();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  title: 'بوست',
                  author: post.authorId,
                  content: post.content,
                  date: _formatTime(post.createdAt),
                );
              },
            ),
          );
        },
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
