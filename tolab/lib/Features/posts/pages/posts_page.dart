// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/Features/posts/controllers/post_controllers.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ✅ AppBar مع الأيقونات
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,

        /// ✅ العنوان
        title: const Text(
          'Posts',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        /// ✅ الأيقونات في AppBar
        leading: IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
          onPressed: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const ChatPage()),
            //   );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => const AddPostPage()),
              // );
            },
          ),
        ],
      ),

      /// ✅ محتوى البوستات
      body: Consumer<PostsController>(
        builder: (context, controller, child) {
          final posts = controller.posts;

          if (posts.isEmpty) {
            return const Center(child: Text('🚫 No posts available.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = posts[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    bottom: BorderSide(
                      color: Color.fromRGBO(152, 172, 201, 0.2),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(152, 172, 201, 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔵 معلومات الكاتب
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color.fromRGBO(152, 172, 201, 1),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            post.authorId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(post.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    /// 📝 نص البوست
                    Text(
                      post.content,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
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
