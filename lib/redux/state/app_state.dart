import 'package:tolab_fci/redux/reducers/ui_reducer.dart';
import 'package:tolab_fci/features/auth/ReduX/states/auth_state.dart';

class AppState {
  final AuthState authState;
  final UIState uiState;

  AppState({required this.authState, required this.uiState});

  factory AppState.initial() {
    return AppState(authState: AuthState.initial(), uiState: UIState.initial());
  }
}
