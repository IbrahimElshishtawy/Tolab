import '../../../core/models/content_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class SectionContentRepository {
  Future<List<SectionContentModel>> fetchSectionContent();

  Future<void> saveSectionContent(Map<String, dynamic> payload);
}

class ApiSectionContentRepository implements SectionContentRepository {
  ApiSectionContentRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<SectionContentModel>> fetchSectionContent() async {
    final response = await _apiClient.get<List<SectionContentModel>>(
      '/staff-portal/section-content',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SectionContentModel.fromJson)
          .toList(),
    );

    return response.data ?? const <SectionContentModel>[];
  }

  @override
  Future<void> saveSectionContent(Map<String, dynamic> payload) async {
    await _apiClient.post<Object?>(
      '/staff-portal/section-content',
      data: payload,
      parser: (_) => null,
    );
  }
}

class MockSectionContentRepository implements SectionContentRepository {
  MockSectionContentRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<List<SectionContentModel>> fetchSectionContent() async {
    await _mockRepository.simulateLatency();
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('assistant@tolab.edu');
    return _mockRepository.sectionContentFor(user);
  }

  @override
  Future<void> saveSectionContent(Map<String, dynamic> payload) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 220));
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('assistant@tolab.edu');
    _mockRepository.saveSectionContent(payload, user);
  }
}
