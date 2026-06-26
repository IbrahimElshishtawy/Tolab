import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../group/data/repositories/mock_group_repository.dart';

final communityControllerProvider =
    AsyncNotifierProvider.family<
      CommunityController,
      List<CommunityPost>,
      String
    >(CommunityController.new);

class CommunityController extends FamilyAsyncNotifier<List<CommunityPost>, String> {
  @override
  Future<List<CommunityPost>> build(String arg) async {
    return ref.watch(communityRepositoryProvider).getPosts(arg);
  }

  Future<void> createPost(String content) async {
    await ref.read(communityRepositoryProvider).createPost(arg, content);
    state = AsyncData(
      await ref.read(communityRepositoryProvider).getPosts(arg),
    );
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    await ref.read(communityRepositoryProvider).createComment(postId, content);
    state = AsyncData(
      await ref.read(communityRepositoryProvider).getPosts(arg),
    );
  }

  Future<void> reactToPost(String postId) async {
    await ref.read(communityRepositoryProvider).reactToPost(postId);
    state = AsyncData(
      await ref.read(communityRepositoryProvider).getPosts(arg),
    );
  }
}
