import '../../../core/models/notification_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class NotificationsRepository {
  Future<List<NotificationModel>> fetchNotifications();

  Future<void> markRead(int notificationId);
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    final response = await _apiClient.get<List<NotificationModel>>(
      '/staff-portal/notifications',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList(),
    );

    return response.data ?? const <NotificationModel>[];
  }

  @override
  Future<void> markRead(int notificationId) async {
    await _apiClient.patch<Object?>(
      '/staff-portal/notifications/$notificationId/read',
      parser: (_) => null,
    );
  }
}

class MockNotificationsRepository implements NotificationsRepository {
  MockNotificationsRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    await _mockRepository.simulateLatency();
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    return _mockRepository.notificationModelsFor(user);
  }

  @override
  Future<void> markRead(int notificationId) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 140));
    _mockRepository.markNotificationRead(notificationId);
  }
}
