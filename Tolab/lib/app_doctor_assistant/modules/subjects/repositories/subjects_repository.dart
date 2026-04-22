import '../../../core/models/academic_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class SubjectsRepository {
  Future<List<SubjectModel>> fetchSubjects();

  Future<SubjectModel> fetchSubjectDetail(int subjectId);
}

class ApiSubjectsRepository implements SubjectsRepository {
  ApiSubjectsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<SubjectModel>> fetchSubjects() async {
    final response = await _apiClient.get<List<SubjectModel>>(
      '/staff-portal/subjects',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SubjectModel.fromJson)
          .toList(),
    );

    return response.data ?? const <SubjectModel>[];
  }

  @override
  Future<SubjectModel> fetchSubjectDetail(int subjectId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff-portal/subjects/$subjectId',
      parser: (value) => Map<String, dynamic>.from(value as Map),
    );

    return SubjectModel.fromJson(response.data ?? const {});
  }
}

class MockSubjectsRepository implements SubjectsRepository {
  MockSubjectsRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<List<SubjectModel>> fetchSubjects() async {
    await _mockRepository.simulateLatency();
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    return _mockRepository.subjectModelsFor(user);
  }

  @override
  Future<SubjectModel> fetchSubjectDetail(int subjectId) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 180));
    return _mockRepository.subjectModelById(subjectId);
  }
}
