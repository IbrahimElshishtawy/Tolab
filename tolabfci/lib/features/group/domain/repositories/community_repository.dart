import '../../../../core/models/community_models.dart';

abstract class CommunityRepository {
  Future<List<CommunityPost>> getPosts(String groupId);

  Future<CommunityPost> createPost(String groupId, String content);

  Future<List<CommunityComment>> getComments(String postId);

  Future<void> createComment(String postId, String text);

  Future<void> reactToPost(String postId);

  Future<List<ChatMessage>> getMessages(
    String groupId, {
    int page = 0,
    int pageSize = 15,
  });

  Future<void> sendMessage(String groupId, String text);

  Future<void> deleteMessage(String groupId, String messageId);
}
