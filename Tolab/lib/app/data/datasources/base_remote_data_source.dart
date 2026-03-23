import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/api_exception_mapper.dart';

class BaseRemoteDataSource {
  BaseRemoteDataSource({required this.dio});

  final Dio dio;

  Future<ApiEnvelope<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic raw) parser,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return _parse(response.data, parser);
    } catch (error) {
      throw ApiExceptionMapper.map(error);
    }
  }

  Future<ApiEnvelope<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic raw) parser,
    bool skipAuth = false,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          extra: {'skipAuth': skipAuth, 'skipRefresh': skipAuth},
        ),
      );
      return _parse(response.data, parser);
    } catch (error) {
      throw ApiExceptionMapper.map(error);
    }
  }

  Future<ApiEnvelope<T>> upload<T>(
    String path, {
    required Map<String, dynamic> fields,
    required T Function(dynamic raw) parser,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        path,
        data: FormData.fromMap(fields),
      );
      return _parse(response.data, parser);
    } catch (error) {
      throw ApiExceptionMapper.map(error);
    }
  }

  ApiEnvelope<T> _parse<T>(
    Map<String, dynamic>? json,
    T Function(dynamic raw) parser,
  ) {
    final payload = json ?? <String, dynamic>{};
    final envelope = ApiEnvelope<T>.fromJson(payload, parser: parser);
    if (!envelope.success) {
      throw ValidationException(
        envelope.message.isNotEmpty ? envelope.message : 'Request failed',
        envelope.errors,
      );
    }
    return envelope;
  }
}
