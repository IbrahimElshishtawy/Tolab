import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? error;
  final String? role;

  AuthState({required this.status, this.error, this.role});

  AuthState copyWith({AuthStatus? status, String? error, String? role}) {
    return AuthState(
      status: status ?? this.status,
      error: error ?? this.error,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(status: AuthStatus.unauthenticated));

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    // Mock login logic
    await Future.delayed(const Duration(seconds: 1));
    if (email.contains('doctor') || email.contains('assistant')) {
      state = state.copyWith(status: AuthStatus.authenticated, role: email.contains('doctor') ? 'doctor' : 'assistant');
    } else {
      state = state.copyWith(status: AuthStatus.error, error: 'Only doctors and assistants can access this app');
    }
  }

  void logout() {
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
final userRoleProvider = Provider<String?>((ref) => ref.watch(authProvider).role);
