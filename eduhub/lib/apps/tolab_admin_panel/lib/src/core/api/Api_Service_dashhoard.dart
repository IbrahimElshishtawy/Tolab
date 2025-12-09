import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/dashboard/dashboard_state.dart';

class ApiServiceDashhoard {
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == "admin@tolab.com" && password == "123456") {
      return "FAKE_TOKEN_123";
    }
    throw Exception("Invalid credentials");
  }

  Future<DashboardState> fetchDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return DashboardState(
      isLoading: false,
      totalStudents: 1250,
      totalDoctors: 42,
      totalSubjects: 36,
      pendingRequests: 8,
      recentActivity: [
        "طالب جديد: Ahmed تم تسجيله في CS",
        "تعديل مادة: Algorithms 101",
        "طلب انضمام جديد من الطالبة: Sara",
        "Doctor Ahmed logged in منذ 1 ساعة",
      ],
    );
  }
}
