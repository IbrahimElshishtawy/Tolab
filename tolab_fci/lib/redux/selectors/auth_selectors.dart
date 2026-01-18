import '../state/app_state.dart';

/// هل المستخدم مسجّل دخول
bool selectIsAuthenticated(AppState state) {
  return state.authState.isAuthenticated;
}

/// هل في عملية Auth شغّالة (loading)
bool selectAuthLoading(AppState state) {
  return state.authState.isLoading;
}

/// الدور الحالي (student | doctor | ta | it)
String? selectUserRole(AppState state) {
  return state.authState.role;
}

/// البريد الإلكتروني
String? selectUserEmail(AppState state) {
  return state.authState.email;
}

/// UID
String? selectUserUid(AppState state) {
  return state.authState.uid;
}

/// رسالة الخطأ (لو موجودة)
String? selectAuthError(AppState state) {
  return state.authState.error;
}
