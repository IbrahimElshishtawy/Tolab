import 'package:dio/dio.dart';

import '../../../academy_panel/models/academy_models.dart';
import '../../../app/core/network/api_client.dart';

class DoctorApiService {
  DoctorApiService(this._client);

  final ApiClient _client;

  Future<List<JsonMap>> fetchCollection(String path) {
    return _client.get<List<JsonMap>>(
      path,
      decoder: (json) {
        if (json is List) {
          return json
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
        if (json is Map<String, dynamic> && json['data'] is List) {
          return (json['data'] as List)
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
        return const <JsonMap>[];
      },
    );
  }

  Future<JsonMap> createRecord(String path, JsonMap payload) {
    return _client.post<JsonMap>(
      path,
      data: payload,
      decoder: (json) => json is Map<String, dynamic>
          ? json
          : Map<String, dynamic>.from(json as Map),
    );
  }

  Future<JsonMap> updateProfile(JsonMap payload) {
    return _client.put<JsonMap>(
      '/me/profile',
      data: payload,
      decoder: (json) => json is Map<String, dynamic>
          ? json
          : Map<String, dynamic>.from(json as Map),
    );
  }

  Future<void> uploadFiles(List<UploadDraft> files) async {
    for (final file in files) {
      final multipartFile = file.path != null
          ? await MultipartFile.fromFile(file.path!, filename: file.name)
          : MultipartFile.fromBytes(
              file.bytes ?? const [],
              filename: file.name,
            );
      await _client.multipart<JsonMap>(
        '/files/upload',
        data: FormData.fromMap({'file': multipartFile}),
        decoder: (json) => json is Map<String, dynamic>
            ? json
            : Map<String, dynamic>.from(json as Map),
      );
    }
  }
}
