import '../../../core/models/content_models.dart';
import '../../../core/network/api_client.dart';

class LecturesRepository {
  LecturesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LectureModel>> fetchLectures() async {
    final response = await _apiClient.get<List<LectureModel>>(
      '/staff-portal/lectures',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(LectureModel.fromJson)
          .toList(),
    );

    return response.data ?? const <LectureModel>[];
  }

  Future<void> saveLecture(Map<String, dynamic> payload) async {
    await _apiClient.post<Object?>(
      '/staff-portal/lectures',
      data: payload,
      parser: (_) => null,
    );
  }

  Future<void> deleteLecture(int lectureId) async {
    await _apiClient.delete<Object?>(
      '/staff-portal/lectures/$lectureId',
      parser: (_) => null,
    );
  }
}
