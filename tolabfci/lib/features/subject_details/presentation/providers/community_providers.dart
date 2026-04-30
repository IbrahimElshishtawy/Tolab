import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../group/data/repositories/mock_group_repository.dart';

final communityControllerProvider =
    AsyncNotifierProvider.family<
      CommunityController,
      List<CommunityPost>,
      String
    >(CommunityController.new);

class CommunityController extends AsyncNotifier<List<CommunityPost>> {
  CommunityController(this._subjectId);
  final String _subjectId;

  @override
  Future<List<CommunityPost>> build() async {
    return ref.watch(communityRepositoryProvider).getPosts(_subjectId);
  }

  Future<void> createPost(String content) async {
    await ref.read(communityRepositoryProvider).createPost(_subjectId, content);
    state = AsyncData(
      await ref.read(communityRepositoryProvider).getPosts(_subjectId),
    );
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    await ref.read(communityRepositoryProvider).createComment(postId, content);
    state = AsyncData(
      await ref.read(communityRepositoryProvider).getPosts(_subjectId),
    );
  }

  Future<void> reactToPost(String postId) async {
    await ref.read(communityRepositoryProvider).reactToPost(postId);
    state = AsyncData(
      await ref.read(communityRepositoryProvider).getPosts(_subjectId),
    );
  }
}
