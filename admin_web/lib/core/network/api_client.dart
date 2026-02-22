import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_web/core/network/secure_storage.dart';

final apiClientProvider = Provider((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api/v1', // Should be from config
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await ref.read(secureStoreProvider).getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ));

  return dio;
});
