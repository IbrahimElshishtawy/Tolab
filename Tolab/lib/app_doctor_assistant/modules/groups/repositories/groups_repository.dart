import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../models/group_models.dart';

abstract class GroupsRepository {
  Future<SubjectGroupModel> fetchSubjectGroup(int subjectId);

  Future<void> savePost(int subjectId, Map<String, dynamic> payload);

  Future<void> deletePost(int postId);

  Future<void> togglePin(int postId);
}

class ApiGroupsRepository implements GroupsRepository {
  ApiGroupsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<SubjectGroupModel> fetchSubjectGroup(int subjectId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff-portal/subjects/$subjectId/group',
      parser: (value) => Map<String, dynamic>.from(value as Map),
    );

    return SubjectGroupModel.fromJson(response.data ?? const {});
  }

  @override
  Future<void> savePost(int subjectId, Map<String, dynamic> payload) async {
    final postId = (payload['post_id'] as num?)?.toInt();
    if (postId == null) {
      await _apiClient.post<Object?>(
        '/staff-portal/subjects/$subjectId/posts',
        data: payload,
        parser: (_) => null,
      );
      return;
    }

    await _apiClient.put<Object?>(
      '/staff-portal/posts/$postId',
      data: payload,
      parser: (_) => null,
    );
  }

  @override
  Future<void> deletePost(int postId) async {
    await _apiClient.delete<Object?>(
      '/staff-portal/posts/$postId',
      parser: (_) => null,
    );
  }

  @override
  Future<void> togglePin(int postId) async {
    await _apiClient.patch<Object?>(
      '/staff-portal/posts/$postId/pin',
      parser: (_) => null,
    );
  }
}

class MockGroupsRepository implements GroupsRepository {
  MockGroupsRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<SubjectGroupModel> fetchSubjectGroup(int subjectId) async {
    await _mockRepository.simulateLatency();
    final user =
        _mockRepository.restoreUserFromSession(await _tokenStorage.read()) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    return _mockRepository.subjectGroupById(subjectId, user);
  }

  @override
  Future<void> savePost(int subjectId, Map<String, dynamic> payload) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 220));
    final user =
        _mockRepository.restoreUserFromSession(await _tokenStorage.read()) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    _mockRepository.saveGroupPost(subjectId, payload, user);
  }

  @override
  Future<void> deletePost(int postId) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 180));
    _mockRepository.deleteGroupPost(postId);
  }

  @override
  Future<void> togglePin(int postId) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 160));
    _mockRepository.togglePinnedPost(postId);
  }
}
