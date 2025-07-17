import 'package:flutter/material.dart';
import 'package:tolab/models/post_model.dart';

class PostsController extends ChangeNotifier {
  final List<PostModel> _posts = [];

  List<PostModel> get posts => _posts;

  void fetchPosts() {
    // هنا تقدر تجيب الداتا من Firebase أو API أو تضيف داتا وهمية
    _posts.clear();
    _posts.addAll([
      PostModel(
        id: '1',
        content: 'Don’t forget to check the schedule for this week.',
        authorId: 'dr_ahmed_001',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      PostModel(
        id: '2',
        content: 'Algorithms slides and summaries are now available.',
        authorId: 'ta_sara_002',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);

    notifyListeners();
  }

  void addPost(PostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void deletePost(String id) {
    _posts.removeWhere((post) => post.id == id);
    notifyListeners();
  }
}
