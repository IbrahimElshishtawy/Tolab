// services/post_service.dart

import 'package:tolab/models/post_model.dart';

class PostService {
  Future<List<PostModel>> fetchPostsFromBackend() async {
    // TODO: استبدال هذه البيانات بداتا حقيقية من Subabase أو Firebase
    await Future.delayed(const Duration(seconds: 1)); // محاكاة التأخير

    return [
      PostModel(
        id: '1',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostModel(
        id: '2',
        content: 'Course updates available in your dashboard.',
        authorId: 'ta_002',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      PostModel(
        id: '3',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostModel(
        id: '4',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostModel(
        id: '5',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostModel(
        id: '6',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostModel(
        id: '7',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostModel(
        id: '8',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostModel(
        id: '9',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostModel(
        id: '10',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostModel(
        id: '11',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostModel(
        id: '12',
        content: 'First official post from backend.',
        authorId: 'admin_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  Future<void> addPostToBackend(PostModel post) async {
    // TODO: تنفيذ كود لإرسال البوست إلى Subabase أو أي Backend تستخدمه
  }

  Future<void> deletePostFromBackend(String id) async {
    // TODO: #1 تنفيذ كود لحذف البوست من قاعدة البيانات
  }
}
