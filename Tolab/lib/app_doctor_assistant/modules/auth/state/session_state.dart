import '../../../core/models/session_user.dart';

class SessionState {
  const SessionState({
    this.user,
  });

  final SessionUser? user;

  bool get isAuthenticated => user != null;

  SessionState copyWith({
    SessionUser? user,
    bool clear = false,
  }) {
    return SessionState(
      user: clear ? null : user ?? this.user,
    );
  }
}
