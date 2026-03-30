import '../../academy_panel/models/academy_models.dart';
import '../../../core/network/api_client.dart';

class StudentApiService {
  StudentApiService(this._client);

  final ApiClient _client;

  Future<List<JsonMap>> fetchCollection(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _client.get<List<JsonMap>>(
      path,
      queryParameters: query,
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

  Future<JsonMap> updateProfile(JsonMap payload) {
    return _client.put<JsonMap>(
      '/me/profile',
      data: payload,
      decoder: (json) => json is Map<String, dynamic>
          ? json
          : Map<String, dynamic>.from(json as Map),
    );
  }
}
