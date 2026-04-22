import '../../../core/models/session_user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class SettingsRepository {
  Future<SessionUser> updateSettings(Map<String, dynamic> payload);
}

class ApiSettingsRepository implements SettingsRepository {
  ApiSettingsRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  @override
  Future<SessionUser> updateSettings(Map<String, dynamic> payload) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/staff-portal/profile/settings',
      data: payload,
      parser: (value) => Map<String, dynamic>.from(value as Map),
    );

    final user = SessionUser.fromJson(response.data ?? const {});
    final session = await _tokenStorage.read() ?? <String, dynamic>{};
    await _tokenStorage.write({...session, 'user': user.toJson()});
    return user;
  }
}

class MockSettingsRepository implements SettingsRepository {
  MockSettingsRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<SessionUser> updateSettings(Map<String, dynamic> payload) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 200));
    final session = await _tokenStorage.read() ?? <String, dynamic>{};
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    final updatedUser = _mockRepository.updateUserSettings(user, payload);
    await _tokenStorage.write({...session, 'user': updatedUser.toJson()});
    return updatedUser;
  }
}
