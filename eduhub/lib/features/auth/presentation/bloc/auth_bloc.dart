// features/auth/presentation/cubit/auth_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/entities/user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthInitial());

  /// استدعِها في الـ Splash عشان يعرف هل في User مسجّل ولا لا
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final UserEntity? user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Login من شاشة الدخول
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _loginUseCase(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));

      emit(const AuthUnauthenticated());
    }
  }

  /// Logout من أي مكان (زر Logout)
  Future<void> logout() async {
    await _logoutUseCase();
    emit(const AuthUnauthenticated());
  }
}
