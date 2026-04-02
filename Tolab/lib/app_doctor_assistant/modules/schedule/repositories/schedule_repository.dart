import '../../../core/models/notification_models.dart';
import '../../../core/network/api_client.dart';

class ScheduleRepository {
  ScheduleRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ScheduleEventModel>> fetchEvents() async {
    final response = await _apiClient.get<List<ScheduleEventModel>>(
      '/staff-portal/schedule',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ScheduleEventModel.fromJson)
          .toList(),
    );

    return response.data ?? const <ScheduleEventModel>[];
  }
}
