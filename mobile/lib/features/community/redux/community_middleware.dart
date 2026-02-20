import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../../mock/fake_repositories/community_fake_repo.dart';
import 'community_actions.dart';

List<Middleware<AppState>> createCommunityMiddlewares() {
  return [
    TypedMiddleware<AppState, FetchPostsAction>(_fetchPosts),
    TypedMiddleware<AppState, CreatePostAction>(_createPost),
    TypedMiddleware<AppState, ToggleLikeAction>(_toggleLike),
    TypedMiddleware<AppState, AddCommentAction>(_addComment),
  ];
}

void _fetchPosts(Store<AppState> store, FetchPostsAction action, NextDispatcher next) async {
  next(action);
  try {
    final repo = CommunityFakeRepo();
    final posts = await repo.getPosts();
    store.dispatch(FetchPostsSuccessAction(posts));
  } catch (e) {
    // handle error
  }
}

void _createPost(Store<AppState> store, CreatePostAction action, NextDispatcher next) async {
  next(action);
  final repo = CommunityFakeRepo();
  await repo.createPost(action.content);
  store.dispatch(FetchPostsAction());
}

void _toggleLike(Store<AppState> store, ToggleLikeAction action, NextDispatcher next) async {
  next(action);
  final repo = CommunityFakeRepo();
  await repo.toggleLike(action.postId);
}

void _addComment(Store<AppState> store, AddCommentAction action, NextDispatcher next) async {
  next(action);
  final repo = CommunityFakeRepo();
  await repo.addComment(action.postId, action.text);
}
