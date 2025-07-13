import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tolab/Features/posts/Notification/Notifications_Page.dart';
import 'package:tolab/Features/posts/controllers/post_controllers.dart';

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

        leadingWidth: 140, // وسّع عرض الشعار حسب الحجم الجديد

        leading: Padding(
          padding: const EdgeInsets.only(right: 8), // مسافة من الطرف الأيمن
          child: Row(
            children: [
              const SizedBox(width: 15), // مسافة إضافية داخل Row
              const Text(
                'ToL',
                style: TextStyle(
                  color: Color.fromARGB(236, 13, 20, 217),
                  fontWeight: FontWeight.bold,
                  fontSize: 23, // ⬅️ حجم الخط الجديد
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/image_App/Tolab.png',
                width: 35, // ⬅️ حجم الصورة الجديد
                height: 35,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              const Text(
                'Ab',
                style: TextStyle(
                  color: Color.fromARGB(236, 13, 20, 217),
                  fontWeight: FontWeight.bold,
                  fontSize: 23, // ⬅️ حجم الخط الجديد
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
            onPressed: () {},
          ),
        ],
      ),

      /// ✅ البوستات
      body: Consumer<PostsController>(
        builder: (context, controller, child) {
          final posts = controller.posts;

          if (posts.isEmpty) {
            return const Center(child: Text('🚫 No posts available.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
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
