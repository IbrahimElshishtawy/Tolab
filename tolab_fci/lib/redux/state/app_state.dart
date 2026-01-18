import 'auth_state.dart';
import 'ui_state.dart';

class AppState {
  final AuthState authState;
  final UIState uiState;

  AppState({required this.authState, required this.uiState});

  factory AppState.initial() {
    return AppState(authState: AuthState.initial(), uiState: UIState.initial());
  }

  AppState copyWith({AuthState? authState, UIState? uiState}) {
    return AppState(
      authState: authState ?? this.authState,
      uiState: uiState ?? this.uiState,
    );
  }
}
