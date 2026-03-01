import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class CalendarApi {
  final ApiClient _client = ApiClient();

  Future<Response> getEvents() async {
    return await _client.get(ApiEndpoints.schedule);
  }
}
