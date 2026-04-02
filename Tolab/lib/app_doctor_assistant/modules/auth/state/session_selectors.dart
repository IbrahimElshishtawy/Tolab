import '../../../core/models/session_user.dart';
import '../../../state/app_state.dart';
import 'session_state.dart';

SessionState getSessionState(DoctorAssistantAppState state) => state.sessionState;

SessionUser? getCurrentUser(DoctorAssistantAppState state) =>
    state.sessionState.user;
