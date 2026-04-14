import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../subjects/data/repositories/mock_subjects_repository.dart';

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
    return ref
        .watch(subjectsRepositoryProvider)
        .fetchCommunityPosts(_subjectId);
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    await ref
        .read(subjectsRepositoryProvider)
        .addComment(subjectId: _subjectId, postId: postId, content: content);
    state = AsyncData(
      await ref
          .read(subjectsRepositoryProvider)
          .fetchCommunityPosts(_subjectId),
    );
  }

  Future<void> reactToPost(String postId) async {
    await ref
        .read(subjectsRepositoryProvider)
        .reactToPost(subjectId: _subjectId, postId: postId);
    state = AsyncData(
      await ref
          .read(subjectsRepositoryProvider)
          .fetchCommunityPosts(_subjectId),
    );
  }
}
