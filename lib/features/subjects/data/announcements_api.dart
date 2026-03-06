import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AnnouncementsApi {
  final ApiClient _client = ApiClient();

  Future<Response> getAnnouncements(int subjectId) async {
    return await _client.get(ApiEndpoints.announcements.replaceFirst('{id}', subjectId.toString()));
  }

  Future<Response> createAnnouncement(int subjectId, Map<String, dynamic> data) async {
    return await _client.post(ApiEndpoints.announcements.replaceFirst('{id}', subjectId.toString()), data: data);
  }

  Future<Response> deleteAnnouncement(int id) async {
    return await _client.delete("/announcements/$id");
  }
}
