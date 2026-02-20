import '../fake_delay.dart';

import '../mock_data.dart';

class CommunityFakeRepo {
  Future<List<dynamic>> getPosts() async {
    await fakeDelay();
    return List.generate(5, (index) => {
      'id': index + 1,
      'user': 'User ${index + 1}',
      'content': 'This is post number ${index + 1}. Hello community!',
      'likes': 10 + index,
      'comments_count': index,
      'is_liked': false,
      'created_at': DateTime.now().subtract(Duration(hours: index)).toIso8601String(),
    });
  }

  Future<void> createPost(String content) async {
    await fakeDelay(1000);
  }

  Future<void> addComment(int postId, String text) async {
    await fakeDelay(800);
  }

  Future<void> toggleLike(int postId) async {
    await fakeDelay(300);
  }

  Future<List<dynamic>> getComments(int postId) async {
    await fakeDelay();
    return mockCommentsData.where((c) => c['post_id'] == postId).toList();
  }
}
