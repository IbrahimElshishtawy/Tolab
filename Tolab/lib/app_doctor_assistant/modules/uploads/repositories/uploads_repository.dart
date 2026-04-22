import 'package:dio/dio.dart';

import '../../../core/models/notification_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class UploadsRepository {
  Future<List<UploadModel>> fetchUploads();

  Future<void> upload({
    required FormData formData,
    ProgressCallback? onSendProgress,
  });
}

class ApiUploadsRepository implements UploadsRepository {
  ApiUploadsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<UploadModel>> fetchUploads() async {
    final response = await _apiClient.get<List<UploadModel>>(
      '/staff-portal/uploads',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(UploadModel.fromJson)
          .toList(),
    );

    return response.data ?? const <UploadModel>[];
  }

  @override
  Future<void> upload({
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) async {
    await _apiClient.upload<Object?>(
      '/staff-portal/uploads',
      formData: formData,
      onSendProgress: onSendProgress,
      parser: (_) => null,
    );
  }
}

class MockUploadsRepository implements UploadsRepository {
  MockUploadsRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<List<UploadModel>> fetchUploads() async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 220));
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    return _mockRepository.uploadsFor(user);
  }

  @override
  Future<void> upload({
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) async {
    const total = 100;
    for (var sent = 0; sent <= total; sent += 25) {
      await Future<void>.delayed(const Duration(milliseconds: 70));
      onSendProgress?.call(sent, total);
    }

    final fileName = formData.files.isEmpty
        ? 'LocalUpload.pdf'
        : (formData.files.first.value.filename ?? 'LocalUpload.pdf');
    final extension = fileName.contains('.')
        ? fileName.split('.').last
        : 'file';

    _mockRepository.addUpload(
      name: fileName,
      mimeType: extension,
      sizeBytes: 1200 * 1024,
    );
  }
}
