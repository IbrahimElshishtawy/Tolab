import '../state/app_state.dart';

bool selectIsAuthenticated(AppState state) {
  return state.authState.isAuthenticated;
}

bool selectIsAuthLoading(AppState state) {
  return state.authState.isLoading;
}

String? selectUserRole(AppState state) {
  return state.authState.role;
}

String? selectAuthError(AppState state) {
  return state.authState.error;
}

String? selectUserEmail(AppState state) {
  return state.authState.email;
}
