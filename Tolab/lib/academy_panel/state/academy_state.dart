import 'package:flutter/material.dart';

import '../../modules/admin/state/admin_state.dart';
import '../../modules/doctor/state/doctor_state.dart';
import '../../modules/student/state/student_state.dart';
import '../models/academy_models.dart';

class AcademySessionState {
  const AcademySessionState({
    this.status = PanelLoadStatus.initial,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });

  final PanelLoadStatus status;
  final AcademyUser? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AcademySessionState copyWith({
    PanelLoadStatus? status,
    AcademyUser? user,
    String? accessToken,
    String? refreshToken,
    String? errorMessage,
    bool clearUser = false,
    bool clearTokens = false,
    bool clearError = false,
  }) {
    return AcademySessionState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      accessToken: clearTokens ? null : accessToken ?? this.accessToken,
      refreshToken: clearTokens ? null : refreshToken ?? this.refreshToken,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AcademyAppState {
  const AcademyAppState({
    required this.session,
    required this.themeMode,
    required this.toastQueue,
    required this.adminState,
    required this.studentState,
    required this.doctorState,
  });

  final AcademySessionState session;
  final ThemeMode themeMode;
  final List<AcademyToast> toastQueue;
  final AdminState adminState;
  final StudentState studentState;
  final DoctorState doctorState;

  factory AcademyAppState.initial() {
    return AcademyAppState(
      session: const AcademySessionState(),
      themeMode: ThemeMode.system,
      toastQueue: const [],
      adminState: AdminState.initial(),
      studentState: StudentState.initial(),
      doctorState: DoctorState.initial(),
    );
  }
}
