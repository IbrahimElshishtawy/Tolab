import 'package:redux/redux.dart';
import 'package:tolab_fci/features/auth/ReduX/reducers/auth_reducer.dart';
import 'package:tolab_fci/redux/reducers/ui_reducer.dart';
import '../state/app_state.dart';

/// Root Reducer
final Reducer<AppState> appReducer = combineReducers<AppState>([_appReducer]);

AppState _appReducer(AppState state, dynamic action) {
  return AppState(
    authState: authReducer(state.authState, action),
    uiState: uiReducer(state.uiState, action),
  );
}
