import '../../../core/models/content_models.dart';
import '../../../core/models/session_user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class LecturesRepository {
  Future<List<LectureModel>> fetchLectures();

  Future<void> saveLecture(Map<String, dynamic> payload);

  Future<void> deleteLecture(int lectureId);
}

class ApiLecturesRepository implements LecturesRepository {
  ApiLecturesRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
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

  @override
  Future<void> saveLecture(Map<String, dynamic> payload) async {
    await _apiClient.post<Object?>(
      '/staff-portal/lectures',
      data: payload,
      parser: (_) => null,
    );
  }

  @override
  Future<void> deleteLecture(int lectureId) async {
    await _apiClient.delete<Object?>(
      '/staff-portal/lectures/$lectureId',
      parser: (_) => null,
    );
  }
}

class MockLecturesRepository implements LecturesRepository {
  MockLecturesRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<List<LectureModel>> fetchLectures() async {
    await _mockRepository.simulateLatency();
    final user = await _currentUser();
    return _mockRepository.lecturesFor(user);
  }

  @override
  Future<void> saveLecture(Map<String, dynamic> payload) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 220));
    final user = await _currentUser();
    _mockRepository.saveLecture(payload, user);
  }

  @override
  Future<void> deleteLecture(int lectureId) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 160));
    _mockRepository.deleteLecture(lectureId);
  }

  Future<SessionUser> _currentUser() async {
    final session = await _tokenStorage.read();
    return _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
  }
}
