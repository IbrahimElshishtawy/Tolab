import 'package:dio/dio.dart';
import '../../config/env.dart';
import '../storage/secure_store.dart';

class ApiClient {
  late Dio dio;
  final SecureStore _secureStore = SecureStore();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStore.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('/auth/refresh')) {
          final refreshToken = await _secureStore.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await Dio(BaseOptions(baseUrl: Env.baseUrl))
                  .post('/auth/refresh', data: {'refresh_token': refreshToken});

              final newToken = response.data['access_token'];
              final newRefreshToken = response.data['refresh_token'];

              await _secureStore.saveToken(newToken);
              if (newRefreshToken != null) {
                await _secureStore.saveRefreshToken(newRefreshToken);
              }

              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final retryResponse = await dio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            } catch (_) {
              await _secureStore.clearAll();
            }
          }
        }

        // Format error for StateView
        String errorMessage = "An unexpected error occurred";
        if (e.response?.data is Map && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = "Connection timed out";
        }

        return handler.next(e.copyWith(message: errorMessage));
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> postForm(String path, Map<String, dynamic> data) async {
    return await dio.post(path, data: FormData.fromMap(data));
  }

  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}
