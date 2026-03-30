import 'package:dio/dio.dart';

import '../../academy_panel/models/academy_models.dart';
import '../../../core/network/api_client.dart';

class AdminApiService {
  AdminApiService(this._client);

  final ApiClient _client;

  Future<List<JsonMap>> fetchCollection(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _client.get<List<JsonMap>>(
      path,
      queryParameters: query,
      decoder: (json) => _decodeList(json),
    );
  }

  Future<JsonMap> createRecord(String path, JsonMap payload) {
    return _client.post<JsonMap>(
      path,
      data: payload,
      decoder: (json) => _decodeMap(json),
    );
  }

  Future<JsonMap> updateRecord(String path, JsonMap payload) {
    return _client.put<JsonMap>(
      path,
      data: payload,
      decoder: (json) => _decodeMap(json),
    );
  }

  Future<void> deleteRecord(String path) {
    return _client.delete<void>(path, decoder: (_) {});
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
        decoder: (json) => _decodeMap(json),
      );
    }
  }

  List<JsonMap> _decodeList(dynamic json) {
    if (json is List) {
      return json
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (json is Map<String, dynamic>) {
      final data = json['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const [];
  }

  JsonMap _decodeMap(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    if (json is Map) {
      return Map<String, dynamic>.from(json);
    }
    return <String, dynamic>{};
  }
}
