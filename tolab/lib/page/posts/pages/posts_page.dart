// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tolab/page/posts/pages/Notifications_Page.dart';
import 'package:tolab/page/posts/pages/Add_Post_Page.dart';
import 'package:tolab/page/posts/controllers/post_controllers.dart';
import 'package:tolab/page/posts/widgets/Post_Card.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _lastPostCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _showNotification(String content) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'post_channel',
          'Post Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      '📢 منشور جديد',
      content,
      details,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              const SizedBox(width: 15),
              Text(
                'ToL',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
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
              Text(
                'Ab',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.bell,
              color: theme.iconTheme.color,
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
            icon: FaIcon(
              FontAwesomeIcons.penToSquare,
              color: theme.iconTheme.color,
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

          // إشعار إذا تم نشر بوست جديد
          if (_lastPostCount != 0 && posts.length > _lastPostCount) {
            final latestPost = posts.first;
            _showNotification("تم نشر بوست جديد بواسطة ${latestPost.authorId}");
          }

          _lastPostCount = posts.length;

          if (posts.isEmpty) {
            return Center(
              child: Text(
                'لا توجد بوستات بعد 📝',
                style: TextStyle(fontSize: 16, color: theme.hintColor),
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
                  author: post.authorId,
                  content: post.content,
                  date: _formatTime(post.createdAt),
                  views: post.views,
                  likes: 0,
                  title: '',
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
      return '${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ساعة';
    } else {
      return '${diff.inDays} يوم';
    }
  }
}
