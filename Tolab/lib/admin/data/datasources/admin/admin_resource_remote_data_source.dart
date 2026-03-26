import 'package:dio/dio.dart';

import '../../../core/network/api_envelope.dart';
import '../../dto/pagination_query_dto.dart';
import '../../models/admin_models.dart';

class AdminResourceRemoteDataSource {
  AdminResourceRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<T>> getList<T>({
    required String endpoint,
    required PaginationQueryDto query,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: query.toJson(),
    );
    final envelope = ApiEnvelope.fromJson(
      response.data ?? const {},
      (data) => data as Map<String, dynamic>,
    );
    final payload = envelope.data;
    final list = (payload['data'] as List<dynamic>? ?? [])
        .map((item) => parser(item as Map<String, dynamic>))
        .toList();
    return PaginatedResponse<T>(
      items: list,
      total: payload['total'] as int? ?? list.length,
      page: payload['current_page'] as int? ?? query.page,
      perPage: payload['per_page'] as int? ?? query.perPage,
    );
  }

  Future<T> getOne<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(endpoint);
    final envelope = ApiEnvelope.fromJson(
      response.data ?? const {},
      (data) => parser(data as Map<String, dynamic>),
    );
    return envelope.data;
  }

  Future<T> create<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      endpoint,
      data: body,
    );
    final envelope = ApiEnvelope.fromJson(
      response.data ?? const {},
      (data) => parser(data as Map<String, dynamic>),
    );
    return envelope.data;
  }

  Future<T> update<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(endpoint, data: body);
    final envelope = ApiEnvelope.fromJson(
      response.data ?? const {},
      (data) => parser(data as Map<String, dynamic>),
    );
    return envelope.data;
  }

  Future<void> delete(String endpoint) => _dio.delete<void>(endpoint);
}
