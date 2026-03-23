import '../../core/utils/result.dart';
import '../datasources/group_remote_data_source.dart';
import '../models/comment_model.dart';
import '../models/group_model.dart';
import '../models/message_model.dart';
import '../models/post_model.dart';
import 'base_repository.dart';

class GroupRepository with BaseRepository {
  GroupRepository(this._remote);

  final GroupRemoteDataSource _remote;

  Future<Result<GroupModel>> details(String id) =>
      guard(() => _remote.details(id));
  Future<Result<List<PostModel>>> posts(String id) =>
      guard(() => _remote.posts(id));
  Future<Result<List<MessageModel>>> messages(String id) =>
      guard(() => _remote.messages(id));
  Future<Result<List<CommentModel>>> comments(String groupId, String postId) =>
      guard(() => _remote.comments(groupId, postId));
}
