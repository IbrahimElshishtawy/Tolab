import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../helpers/json_types.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  ApiClient({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage,
      _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: AppConfig.connectTimeout,
          sendTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: {'Accept': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/refresh')) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final accessToken = await _secureStorage.readAccessToken();
              final retry = await _dio.fetch<dynamic>(
                error.requestOptions.copyWith(
                  headers: {
                    ...error.requestOptions.headers,
                    if (accessToken != null)
                      'Authorization': 'Bearer $accessToken',
                  },
                ),
              );
              handler.resolve(retry);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );

    if (AppConfig.enableVerboseNetworkLogs) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          requestHeader: false,
          responseBody: false,
          compact: true,
        ),
      );
    }
  }

  final Dio _dio;
  final SecureStorageService _secureStorage;
  static const int _maxRetryAttempts = 2;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    required T Function(dynamic json) decoder,
  }) async {
    return _request(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
      decoder: decoder,
    );
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
    required T Function(dynamic json) decoder,
  }) async {
    return _request(
      () => _dio.post<dynamic>(path, data: data, cancelToken: cancelToken),
      decoder: decoder,
    );
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
    required T Function(dynamic json) decoder,
  }) async {
    return _request(
      () => _dio.put<dynamic>(path, data: data, cancelToken: cancelToken),
      decoder: decoder,
    );
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
    required T Function(dynamic json) decoder,
  }) async {
    return _request(
      () => _dio.patch<dynamic>(path, data: data, cancelToken: cancelToken),
      decoder: decoder,
    );
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
    required T Function(dynamic json) decoder,
  }) async {
    return _request(
      () => _dio.delete<dynamic>(path, data: data, cancelToken: cancelToken),
      decoder: decoder,
    );
  }

  Future<T> multipart<T>(
    String path, {
    required FormData data,
    required T Function(dynamic json) decoder,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    return _request(
      () => _dio.post<dynamic>(
        path,
        data: data,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      ),
      decoder: decoder,
    );
  }

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() request, {
    required T Function(dynamic json) decoder,
  }) async {
    for (var attempt = 0; attempt <= _maxRetryAttempts; attempt++) {
      try {
        final response = await request();
        final payload = response.data;
        if (payload is JsonMap && payload['success'] == false) {
          throw AppException(
            payload['message']?.toString() ??
                'The request failed unexpectedly.',
            statusCode: response.statusCode,
          );
        }
        final dynamic data = payload is JsonMap && payload.containsKey('data')
            ? payload['data']
            : payload;
        return decoder(data);
      } on DioException catch (error) {
        if (attempt < _maxRetryAttempts && _shouldRetry(error)) {
          continue;
        }
        throw AppException(
          _mapDioError(error),
          statusCode: error.response?.statusCode,
        );
      }
    }
    throw AppException('Unable to complete your request.');
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _dio.post<dynamic>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final payload = response.data;
      if (payload is! JsonMap) {
        return false;
      }
      final data = payload['data'];
      if (data is! JsonMap) {
        return false;
      }
      final accessToken =
          data['access_token']?.toString() ?? data['accessToken']?.toString();
      final nextRefreshToken =
          data['refresh_token']?.toString() ??
          data['refreshToken']?.toString() ??
          refreshToken;
      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }
      await _secureStorage.writeAccessToken(accessToken);
      await _secureStorage.writeRefreshToken(nextRefreshToken);
      return true;
    } catch (_) {
      await _secureStorage.clearSession();
      return false;
    }
  }

  bool _shouldRetry(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        statusCode >= 500;
  }

  String _mapDioError(DioException error) {
    final responseData = error.response?.data;
    if (responseData is JsonMap) {
      final message = responseData['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'The server took too long to respond. Please try again.',
      DioExceptionType.connectionError =>
        'Unable to reach the server. Check your connection and try again.',
      DioExceptionType.cancel => 'The request was cancelled.',
      DioExceptionType.badResponse =>
        error.message ?? 'The server could not complete the request.',
      _ => error.message ?? 'Network request failed.',
    };
  }
}
