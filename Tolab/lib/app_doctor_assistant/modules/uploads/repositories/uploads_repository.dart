import 'package:dio/dio.dart';

import '../../../core/models/notification_models.dart';
import '../../../core/network/api_client.dart';

class UploadsRepository {
  UploadsRepository(this._apiClient);

  final ApiClient _apiClient;

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
