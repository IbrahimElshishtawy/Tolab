import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../../mock/fake_repositories/community_fake_repo.dart';
import '../data/community_api.dart';
import '../../../config/env.dart';
import 'community_actions.dart';

List<Middleware<AppState>> createCommunityMiddlewares() {
  return [
    TypedMiddleware<AppState, FetchPostsAction>(_fetchPosts).call,
    TypedMiddleware<AppState, CreatePostAction>(_createPost).call,
    TypedMiddleware<AppState, ToggleLikeAction>(_toggleLike).call,
    TypedMiddleware<AppState, AddCommentAction>(_addComment).call,
  ];
}

void _fetchPosts(
  Store<AppState> store,
  FetchPostsAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    List<dynamic> posts;
    if (Env.useMock) {
      final repo = CommunityFakeRepo();
      posts = await repo.getPosts();
    } else {
      final api = CommunityApi();
      final response = await api.getPosts();
      posts = response.data;
    }
    store.dispatch(FetchPostsSuccessAction(posts));
  } catch (e) {
    // handle error
  }
}

void _createPost(
  Store<AppState> store,
  CreatePostAction action,
  NextDispatcher next,
) async {
  next(action);
  if (Env.useMock) {
    final repo = CommunityFakeRepo();
    await repo.createPost(action.content);
  } else {
    final api = CommunityApi();
    await api.createPost(action.content);
  }
  store.dispatch(FetchPostsAction());
}

void _toggleLike(
  Store<AppState> store,
  ToggleLikeAction action,
  NextDispatcher next,
) async {
  next(action);
  if (Env.useMock) {
    final repo = CommunityFakeRepo();
    await repo.toggleLike(action.postId);
  } else {
    final api = CommunityApi();
    await api.toggleReaction(action.postId);
  }
}

void _addComment(
  Store<AppState> store,
  AddCommentAction action,
  NextDispatcher next,
) async {
  next(action);
  if (Env.useMock) {
    final repo = CommunityFakeRepo();
    await repo.addComment(action.postId, action.text);
  } else {
    final api = CommunityApi();
    await api.createComment(action.postId, action.text);
  }
}
