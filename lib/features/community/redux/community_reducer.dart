import 'community_state.dart';
import 'community_actions.dart';

CommunityState communityReducer(CommunityState state, dynamic action) {
  if (action is FetchPostsAction) {
    return state.copyWith(isLoading: true);
  }
  if (action is FetchPostsSuccessAction) {
    return state.copyWith(isLoading: false, posts: action.posts);
  }
  if (action is ToggleLikeAction) {
    final newPosts = state.posts.map((post) {
      if (post['id'] == action.postId) {
        final isLiked = post['is_liked'] as bool;
        return {
          ...post,
          'is_liked': !isLiked,
          'likes': isLiked ? post['likes'] - 1 : post['likes'] + 1,
        };
      }
      return post;
    }).toList();
    return state.copyWith(posts: newPosts);
  }
  return state;
}
