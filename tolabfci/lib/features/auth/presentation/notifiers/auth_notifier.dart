import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/app_session.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../state/auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final sessionBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(authNotifierProvider.notifier).restoreSession();
});

final currentUserRoleProvider = Provider<AppUserRole>((ref) {
  return ref.watch(authNotifierProvider).role;
});

final isStaffUserProvider = Provider<bool>((ref) {
  return ref.watch(currentUserRoleProvider).isStaff;
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> restoreSession() async {
    final (stage, role, nationalId) = await ref
        .read(authRepositoryProvider)
        .restoreSession();
    state = state.copyWith(
      stage: stage,
      role: role,
      nationalId: nationalId,
      clearNationalId: nationalId == null,
      clearError: true,
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      final isStudent = session.role == AppUserRole.student;
      state = state.copyWith(
        stage: isStudent
            ? AuthStage.authenticated
            : AuthStage.awaitingNationalId,
        role: session.role,
        nationalId: isStudent ? null : session.nationalId,
        isSubmitting: false,
        clearNationalId: isStudent,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
    }
  }

  Future<void> verifyNationalId(String nationalId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final expectedNationalId = state.nationalId?.trim().replaceAll(
        RegExp(r'\s+'),
        '',
      );
      await ref
          .read(authRepositoryProvider)
          .verifyNationalId(
            nationalId,
            expectedNationalId:
                expectedNationalId != null && expectedNationalId.isNotEmpty
                ? expectedNationalId
                : null,
          );
      state = state.copyWith(
        stage: AuthStage.authenticated,
        isSubmitting: false,
        clearNationalId: true,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState.initial();
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    state = state.copyWith(clearError: true);
  }
}
