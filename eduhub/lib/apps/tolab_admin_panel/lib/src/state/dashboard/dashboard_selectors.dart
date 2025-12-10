// ignore_for_file: library_prefixes

import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/app_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/dashboard/dashboard_state.dart';

/// Selector: يرجّع state كامل للداشبورد
DashboardState selectDashboardState(AppState state) {
  return state.dashboard;
}

/// Selector: عدد الطلاب
int selectTotalStudents(AppState state) {
  return state.dashboard.totalStudents;
}

/// Selector: عدد الدكاترة
int selectTotalDoctors(AppState state) {
  return state.dashboard.totalDoctors;
}

/// Selector: عدد المواد
int selectTotalSubjects(AppState state) {
  return state.dashboard.totalSubjects;
}

/// Selector: الطلبات المعلّقة
int selectPendingRequests(AppState state) {
  return state.dashboard.pendingRequests;
}

/// Selector: آخر الأنشطة
List<String> selectRecentActivity(AppState state) {
  return state.dashboard.recentActivity;
}

/// Selector: حالة التحميل
bool selectDashboardLoading(AppState state) {
  return state.dashboard.isLoading;
}

/// Selector: الأخطاء
String? selectDashboardError(AppState state) {
  return state.dashboard.error;
}
