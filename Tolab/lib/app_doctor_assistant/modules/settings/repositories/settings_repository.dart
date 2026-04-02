import '../../../core/models/session_user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

class SettingsRepository {
  SettingsRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

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
