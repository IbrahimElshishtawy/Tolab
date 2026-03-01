class FetchPostsAction {}
class FetchPostsSuccessAction {
  final List<dynamic> posts;
  FetchPostsSuccessAction(this.posts);
}

class CreatePostAction {
  final String content;
  CreatePostAction(this.content);
}

class ToggleLikeAction {
  final int postId;
  ToggleLikeAction(this.postId);
}

class AddCommentAction {
  final int postId;
  final String text;
  AddCommentAction(this.postId, this.text);
}
