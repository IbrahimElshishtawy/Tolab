import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../models/results_models.dart';

abstract class ResultsRepository {
  Future<ResultsOverviewModel> fetchOverview();

  Future<SubjectResultsModel> fetchSubjectResults(int subjectId);

  Future<void> saveGradesDraft(int subjectId, Map<String, dynamic> payload);

  Future<void> publishGrades(int subjectId, Map<String, dynamic> payload);
}

class ApiResultsRepository implements ResultsRepository {
  ApiResultsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ResultsOverviewModel> fetchOverview() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff-portal/results',
      parser: (value) => Map<String, dynamic>.from(value as Map),
    );

    return ResultsOverviewModel.fromJson(response.data ?? const {});
  }

  @override
  Future<SubjectResultsModel> fetchSubjectResults(int subjectId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff-portal/subjects/$subjectId/results',
      parser: (value) => Map<String, dynamic>.from(value as Map),
    );

    return SubjectResultsModel.fromJson(response.data ?? const {});
  }

  @override
  Future<void> saveGradesDraft(int subjectId, Map<String, dynamic> payload) async {
    await _apiClient.post<Object?>(
      '/staff-portal/subjects/$subjectId/grades/draft',
      data: payload,
      parser: (_) => null,
    );
  }

  @override
  Future<void> publishGrades(int subjectId, Map<String, dynamic> payload) async {
    await _apiClient.post<Object?>(
      '/staff-portal/subjects/$subjectId/grades/publish',
      data: payload,
      parser: (_) => null,
    );
  }
}

class MockResultsRepository implements ResultsRepository {
  MockResultsRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<ResultsOverviewModel> fetchOverview() async {
    await _mockRepository.simulateLatency();
    final user =
        _mockRepository.restoreUserFromSession(await _tokenStorage.read()) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    return _mockRepository.resultsOverviewFor(user);
  }

  @override
  Future<SubjectResultsModel> fetchSubjectResults(int subjectId) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 220));
    final user =
        _mockRepository.restoreUserFromSession(await _tokenStorage.read()) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    return _mockRepository.subjectResultsById(subjectId, user);
  }

  @override
  Future<void> saveGradesDraft(int subjectId, Map<String, dynamic> payload) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 200));
    final user =
        _mockRepository.restoreUserFromSession(await _tokenStorage.read()) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    _mockRepository.saveGrades(subjectId, payload, user, publish: false);
  }

  @override
  Future<void> publishGrades(int subjectId, Map<String, dynamic> payload) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 200));
    final user =
        _mockRepository.restoreUserFromSession(await _tokenStorage.read()) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    _mockRepository.saveGrades(subjectId, payload, user, publish: true);
  }
}
