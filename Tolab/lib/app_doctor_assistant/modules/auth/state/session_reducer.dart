import 'session_actions.dart';
import 'session_state.dart';

SessionState sessionReducer(SessionState state, dynamic action) {
  switch (action.runtimeType) {
    case SessionEstablishedAction:
      return state.copyWith(user: (action as SessionEstablishedAction).user);
    case SessionClearedAction:
      return state.copyWith(clear: true);
    default:
      return state;
  }
}
