import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class CommunityApi {
  final ApiClient _client = ApiClient();

  Future<Response> getPosts({int? subjectId}) async {
    return await _client.get(ApiEndpoints.community, queryParameters: subjectId != null ? {'subject_id': subjectId} : null);
  }

  Future<Response> createPost(String content, {int? subjectId}) async {
    return await _client.post(
      ApiEndpoints.community,
      data: {'content': content, 'subject_id': subjectId},
    );
  }

  Future<Response> createComment(int postId, String content) async {
    return await _client.post(
      "${ApiEndpoints.community}/$postId/comments",
      data: {'content': content},
    );
  }

  Future<Response> toggleReaction(int postId) async {
    return await _client.post("${ApiEndpoints.community}/$postId/react");
  }
}
