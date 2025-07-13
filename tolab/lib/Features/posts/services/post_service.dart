// services/post_service.dart
import 'package:tolab/models/post_model.dart';

class PostService {
  /// Simulated fetch from Supabase or backend API
  Future<List<PostModel>> fetchPostsFromBackend() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    return List.generate(12, (index) {
      return PostModel(
        id: '${index + 1}',
        content: 'Post #${index + 1}: Updates from backend.',
        authorId: index.isEven ? 'admin_001' : 'ta_002',
        createdAt: DateTime.now().subtract(Duration(hours: index + 1)),
      );
    });
  }

  /// Simulated add post (replace with Supabase insert logic)
  Future<void> addPostToBackend(PostModel post) async {
    // TODO: Use Supabase insert query like:
    // await Supabase.instance.client.from('posts').insert(post.toJson());
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Simulated delete post (replace with Supabase delete logic)
  Future<void> deletePostFromBackend(String id) async {
    // TODO: Use Supabase delete query like:
    // await Supabase.instance.client.from('posts').delete().eq('id', id);
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
