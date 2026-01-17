import 'package:redux/redux.dart';
import '../state/app_state.dart';
import 'auth_reducer.dart';

/// Root Reducer
final Reducer<AppState> appReducer = combineReducers<AppState>([
  TypedReducer<AppState, dynamic>(_authReducer).call,
]);

AppState _authReducer(AppState state, dynamic action) {
  return state.copyWith(authState: authReducer(state.authState, action));
}
