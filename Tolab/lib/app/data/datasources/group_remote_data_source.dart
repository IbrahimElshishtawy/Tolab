import '../../core/constants/api_constants.dart';
import '../models/comment_model.dart';
import '../models/group_model.dart';
import '../models/message_model.dart';
import '../models/post_model.dart';
import 'base_remote_data_source.dart';

class GroupRemoteDataSource {
  GroupRemoteDataSource(this._remote);

  final BaseRemoteDataSource _remote;

  Future<GroupModel> details(String id) async {
    final envelope = await _remote.get<GroupModel>(
      ApiConstants.groupDetails(id),
      parser: (raw) => GroupModel.fromJson(raw as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<List<PostModel>> posts(String id) async {
    final envelope = await _remote.get<List<PostModel>>(
      ApiConstants.groupPosts(id),
      parser: (raw) => (raw as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(PostModel.fromJson)
          .toList(),
    );
    return envelope.data!;
  }

  Future<List<MessageModel>> messages(String id) async {
    final envelope = await _remote.get<List<MessageModel>>(
      ApiConstants.groupMessages(id),
      parser: (raw) => (raw as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(MessageModel.fromJson)
          .toList(),
    );
    return envelope.data!;
  }

  Future<List<CommentModel>> comments(String groupId, String postId) async {
    final envelope = await _remote.get<List<CommentModel>>(
      '${ApiConstants.groupPosts(groupId)}/$postId',
      parser: (raw) {
        final map = raw as Map<String, dynamic>? ?? <String, dynamic>{};
        return (map['comments'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(CommentModel.fromJson)
            .toList();
      },
    );
    return envelope.data!;
  }
}
