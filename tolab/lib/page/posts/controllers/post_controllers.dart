import 'package:flutter/material.dart';
import 'package:tolab/models/post_model.dart';

class PostsController extends ChangeNotifier {
  final List<PostModel> _posts = [];

  List<PostModel> get posts => _posts;

  void fetchPosts() {
    _posts.clear();
    _posts.addAll([
      PostModel(
        id: '1',
        title: 'Weekly Schedule',
        content: 'Don’t forget to check the schedule for this week.',
        authorId: 'dr_ahmed_001',
        authorName: 'د. أحمد',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        views: 12,
        shares: 3,
        viewsUsers: ['user_001', 'user_002'],
      ),
      PostModel(
        id: '2',
        title: 'Algorithms Materials',
        content: 'Algorithms slides and summaries are now available.',
        authorId: 'ta_sara_002',
        authorName: 'م. سارة',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        views: 8,
        shares: 1,
        viewsUsers: ['user_003'],
      ),
    ]);
    notifyListeners();
  }

  void addPost(PostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void deletePost(String postId, String currentUserId) {
    final post = _posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => throw Exception('Post not found'),
    );
    if (post.authorId == currentUserId) {
      _posts.remove(post);
      notifyListeners();
    } else {
      throw Exception('You do not have permission to delete this post.');
    }
  }

  void updatePost(
    String postId,
    String currentUserId, {
    String? newTitle,
    String? newContent,
  }) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    if (_posts[index].authorId != currentUserId) {
      throw Exception('You do not have permission to update this post.');
    }

    final updatedPost = _posts[index].copyWith(
      title: newTitle,
      content: newContent,
    );
    _posts[index] = updatedPost;
    notifyListeners();
  }

  void increaseViews(String postId, String userId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1 && !_posts[index].viewsUsers.contains(userId)) {
      final updatedPost = _posts[index].copyWith(
        views: _posts[index].views + 1,
        viewsUsers: [..._posts[index].viewsUsers, userId],
      );
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  void increaseShares(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final updatedPost = _posts[index].copyWith(
        shares: _posts[index].shares + 1,
      );
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  List<String> getViewsUsers(String postId) {
    final post = _posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => throw Exception('Post not found'),
    );
    return post.viewsUsers;
  }
}
