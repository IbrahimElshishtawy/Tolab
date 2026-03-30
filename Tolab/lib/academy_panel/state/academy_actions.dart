import 'package:flutter/material.dart';

import 'academy_state.dart';
import '../models/academy_models.dart';

class AcademyLoginRequestedAction {
  AcademyLoginRequestedAction({
    required this.email,
    required this.password,
    required this.preferredRole,
  });

  final String email;
  final String password;
  final AcademyRole preferredRole;
}

class AcademyLoginSucceededAction {
  AcademyLoginSucceededAction({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final AcademyUser user;
  final String accessToken;
  final String refreshToken;
}

class AcademyLoginFailedAction {
  AcademyLoginFailedAction(this.message);

  final String message;
}

class AcademyLogoutRequestedAction {}

class AcademyLogoutCompletedAction {}

class AcademyThemeModeToggledAction {}

class AcademyToastQueuedAction {
  AcademyToastQueuedAction(this.toast);

  final AcademyToast toast;
}

class AcademyToastDequeuedAction {
  AcademyToastDequeuedAction(this.toastId);

  final String toastId;
}

AcademySessionState academySessionReducer(
  AcademySessionState state,
  dynamic action,
) {
  switch (action) {
    case AcademyLoginRequestedAction():
      return state.copyWith(status: PanelLoadStatus.loading, clearError: true);
    case AcademyLoginSucceededAction():
      return state.copyWith(
        status: PanelLoadStatus.success,
        user: action.user,
        accessToken: action.accessToken,
        refreshToken: action.refreshToken,
        clearError: true,
      );
    case AcademyLoginFailedAction():
      return state.copyWith(
        status: PanelLoadStatus.failure,
        errorMessage: action.message,
      );
    case AcademyLogoutCompletedAction():
      return const AcademySessionState();
    default:
      return state;
  }
}

ThemeMode academyThemeReducer(ThemeMode mode, dynamic action) {
  switch (action) {
    case AcademyThemeModeToggledAction():
      return switch (mode) {
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
        ThemeMode.system => ThemeMode.light,
      };
    default:
      return mode;
  }
}

List<AcademyToast> academyToastReducer(
  List<AcademyToast> state,
  dynamic action,
) {
  switch (action) {
    case AcademyToastQueuedAction():
      return [...state, action.toast];
    case AcademyToastDequeuedAction():
      return state.where((toast) => toast.id != action.toastId).toList();
    default:
      return state;
  }
}
