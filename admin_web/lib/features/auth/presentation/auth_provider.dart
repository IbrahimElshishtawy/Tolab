import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_web/core/network/api_client.dart';
import 'package:admin_web/core/network/secure_storage.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? role;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.role,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? role,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _ref.read(secureStoreProvider).getToken();
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _ref.read(apiClientProvider).post(
        '/login/access-token',
        data: FormData.fromMap({
          'username': email,
          'password': password,
        }),
      );

      final token = response.data['access_token'];
      final role = response.data['role'];

      if (role != 'it') {
        state = state.copyWith(isLoading: false, error: 'Access denied: Admin only');
        return;
      }

      await _ref.read(secureStoreProvider).saveToken(token);
      state = state.copyWith(isLoading: false, isAuthenticated: true, role: role);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed: Incorrect email or password');
    }
  }

  Future<void> logout() async {
    await _ref.read(secureStoreProvider).deleteToken();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
final isAuthenticatedProvider = Provider((ref) => ref.watch(authProvider).isAuthenticated);
