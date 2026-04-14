import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'api_response.dart';

typedef JsonMap = Map<String, dynamic>;

class ApiClient {
  ApiClient({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage,
      _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          sendTimeout: AppConfig.sendTimeout,
          headers: const {'Accept': 'application/json'},
        ),
      ),
      _refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          sendTimeout: AppConfig.sendTimeout,
          headers: const {'Accept': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = await _tokenStorage.read();
          final token = session?['access_token']?.toString();
          final requiresAuth = options.extra['requiresAuth'] == true;

          if (requiresAuth && (token == null || token.isEmpty)) {
            await _handleUnauthorized(
              ApiException(
                message: 'Your session has expired. Please sign in again.',
                statusCode: 401,
              ),
            );
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<JsonMap>(
                  requestOptions: options,
                  statusCode: 401,
                  data: const {'message': 'Unauthenticated.'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final connectivity = await Connectivity().checkConnectivity();
          if (connectivity.contains(ConnectivityResult.none)) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'No internet connection.',
                type: DioExceptionType.connectionError,
              ),
            );
            return;
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final requestOptions = error.requestOptions;

          if (statusCode == 401 &&
              requestOptions.extra['retried'] != true &&
              !requestOptions.path.contains('/auth/refresh')) {
            final refreshed = await _refreshSession();
            if (refreshed) {
              requestOptions.extra['retried'] = true;
              final session = await _tokenStorage.read();
              final token = session?['access_token']?.toString();
              if (token != null && token.isNotEmpty) {
                requestOptions.headers['Authorization'] = 'Bearer $token';
              }

              final response = await _dio.fetch(requestOptions);
              handler.resolve(response);
              return;
            }

            await _handleUnauthorized(ApiException.fromDio(error));
          }

          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  final Dio _dio;
  final Dio _refreshDio;
  Future<void> Function(String message)? _unauthorizedHandler;
  bool _isHandlingUnauthorized = false;

  void setUnauthorizedHandler(Future<void> Function(String message) handler) {
    _unauthorizedHandler = handler;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool requiresAuth = false,
    required T Function(Object? value) parser,
  }) async {
    try {
      final response = await _dio.get<JsonMap>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      return ApiResponse<T>.fromJson(response.data!, parser);
    } catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool requiresAuth = false,
    required T Function(Object? value) parser,
  }) async {
    try {
      final response = await _dio.post<JsonMap>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      return ApiResponse<T>.fromJson(response.data!, parser);
    } catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? data,
    CancelToken? cancelToken,
    bool requiresAuth = false,
    required T Function(Object? value) parser,
  }) async {
    try {
      final response = await _dio.put<JsonMap>(
        path,
        data: data,
        cancelToken: cancelToken,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      return ApiResponse<T>.fromJson(response.data!, parser);
    } catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? data,
    CancelToken? cancelToken,
    bool requiresAuth = false,
    required T Function(Object? value) parser,
  }) async {
    try {
      final response = await _dio.patch<JsonMap>(
        path,
        data: data,
        cancelToken: cancelToken,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      return ApiResponse<T>.fromJson(response.data!, parser);
    } catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? data,
    CancelToken? cancelToken,
    bool requiresAuth = false,
    required T Function(Object? value) parser,
  }) async {
    try {
      final response = await _dio.delete<JsonMap>(
        path,
        data: data,
        cancelToken: cancelToken,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      return ApiResponse<T>.fromJson(response.data!, parser);
    } catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ApiResponse<T>> upload<T>(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    bool requiresAuth = false,
    required T Function(Object? value) parser,
  }) async {
    try {
      final response = await _dio.post<JsonMap>(
        path,
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );

      return ApiResponse<T>.fromJson(response.data!, parser);
    } catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<bool> _refreshSession() async {
    final session = await _tokenStorage.read();
    final refreshToken = session?['refresh_token']?.toString();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _refreshDio.post<JsonMap>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken, 'device_name': 'flutter-app'},
      );

      final payload = _normalizeTokenPayload(response.data?['data']);
      if (payload.isNotEmpty) {
        await _tokenStorage.write({
          ...session ?? <String, dynamic>{},
          ...payload,
        });
        return true;
      }
    } catch (_) {
      await _tokenStorage.clear();
    }

    return false;
  }

  Future<void> _handleUnauthorized(ApiException error) async {
    if (_isHandlingUnauthorized) {
      return;
    }

    _isHandlingUnauthorized = true;
    try {
      await _tokenStorage.clear();
      await _unauthorizedHandler?.call(
        error.message.isEmpty
            ? 'Your session has expired. Please sign in again.'
            : error.message,
      );
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  Map<String, dynamic> _normalizeTokenPayload(Object? value) {
    if (value is! Map) {
      return const <String, dynamic>{};
    }

    final data = Map<String, dynamic>.from(value);
    final accessToken =
        data['access_token']?.toString() ?? data['accessToken']?.toString();
    final refreshToken =
        data['refresh_token']?.toString() ?? data['refreshToken']?.toString();

    final normalized = <String, dynamic>{};
    if (accessToken != null && accessToken.isNotEmpty) {
      normalized['access_token'] = accessToken;
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      normalized['refresh_token'] = refreshToken;
    }

    return normalized;
  }
}
