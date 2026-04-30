import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/repositories/group_repository.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return MockGroupCommunityRepository(ref.watch(mockBackendServiceProvider));
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return MockGroupCommunityRepository(ref.watch(mockBackendServiceProvider));
});

final courseGroupProvider = FutureProvider.family<CourseGroup, String>((
  ref,
  courseOfferingId,
) {
  return ref.watch(groupRepositoryProvider).getCourseGroup(courseOfferingId);
});

class MockGroupCommunityRepository
    implements GroupRepository, CommunityRepository {
  const MockGroupCommunityRepository(this._backendService);

  final MockBackendService _backendService;

  @override
  Future<CourseGroup> getCourseGroup(String courseOfferingId) {
    return _backendService.fetchCourseGroup(
      _subjectIdFromGroupId(courseOfferingId),
    );
  }

  @override
  Future<List<CommunityPost>> getPosts(String groupId) {
    return _backendService.fetchCommunityPosts(_subjectIdFromGroupId(groupId));
  }

  @override
  Future<CommunityPost> createPost(String groupId, String content) {
    return _backendService.createCommunityPost(
      subjectId: _subjectIdFromGroupId(groupId),
      content: content,
    );
  }

  @override
  Future<List<CommunityComment>> getComments(String postId) {
    return _backendService.fetchComments(postId);
  }

  @override
  Future<void> createComment(String postId, String text) {
    return _backendService.addCommentByPostId(postId: postId, content: text);
  }

  @override
  Future<void> reactToPost(String postId) {
    return _backendService.reactToPostById(postId);
  }

  @override
  Future<List<ChatMessage>> getMessages(
    String groupId, {
    int page = 0,
    int pageSize = 15,
  }) {
    return _backendService.fetchChatMessages(
      _subjectIdFromGroupId(groupId),
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<void> sendMessage(String groupId, String text) {
    return _backendService.sendChatMessage(
      subjectId: _subjectIdFromGroupId(groupId),
      content: text,
    );
  }

  @override
  Future<void> deleteMessage(String groupId, String messageId) {
    return _backendService.deleteChatMessage(
      subjectId: _subjectIdFromGroupId(groupId),
      messageId: messageId,
    );
  }

  String _subjectIdFromGroupId(String value) {
    return value.startsWith('group-') ? value.substring(6) : value;
  }
}
