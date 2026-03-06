import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AttendanceApi {
  final ApiClient _client = ApiClient();

  Future<Response> getAttendanceHistory(int subjectId) async {
    return await _client.get(ApiEndpoints.attendance.replaceFirst('{id}', subjectId.toString()));
  }

  Future<Response> startSession(int subjectId, String type, int duration) async {
    return await _client.post(ApiEndpoints.attendanceSessions.replaceFirst('{id}', subjectId.toString()), data: {
      'type': type,
      'duration_mins': duration
    });
  }

  Future<Response> checkIn(int sessionId, String code) async {
    return await _client.post("/attendance/sessions/$sessionId/checkin", data: {
      'code': code
    });
  }
}
