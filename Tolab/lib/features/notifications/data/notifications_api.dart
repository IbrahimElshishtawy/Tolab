import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class NotificationsApi {
  final ApiClient _client = ApiClient();

  Future<Response> getNotifications() async {
    return await _client.get(ApiEndpoints.notifications);
  }

  Future<Response> markRead(int id) async {
    return await _client.put("${ApiEndpoints.notifications}/$id/read", data: {});
  }

  Future<Response> createNotification(Map<String, dynamic> data) async {
    return await _client.post(ApiEndpoints.notifications, data: data);
  }
}
