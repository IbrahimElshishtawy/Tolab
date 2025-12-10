// ignore_for_file: file_names

import '../app_state.dart';
import 'auth_state.dart';

/// يرجّع حالة تسجيل الدخول بالكامل
AuthState selectAuthState(AppState state) {
  return state.auth;
}

/// هل المستخدم مسجل دخول؟
bool selectIsLoggedIn(AppState state) {
  return state.auth.isloadingIn;
}

/// هل هناك عملية تسجيل دخول تُجرى الآن؟
bool selectAuthLoading(AppState state) {
  return state.auth.isloading;
}

/// الحصول على التوكن
String? selectAuthToken(AppState state) {
  return state.auth.token;
}

/// الحصول على البريد الإلكتروني الخاص بالمستخدم
String? selectUserEmail(AppState state) {
  return state.auth.email;
}

/// الحصول على رسالة الخطأ (إن وُجدت)
String? selectAuthError(AppState state) {
  return state.auth.errorMessage;
}
