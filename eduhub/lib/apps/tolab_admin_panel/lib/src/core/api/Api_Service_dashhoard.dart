// ignore_for_file: file_names

import 'dart:async';

import 'package:eduhub/fake_data/data.dart';

import '../../state/dashboard/dashboard_state.dart';

class ApiServiceDashboard {
  // -------------------------------------------------------------------
  // Dashboard: Return Stats From Fake Data
  // -------------------------------------------------------------------
  Future<DashboardState> fetchDashboardState() async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      // ----------------------------
      // COUNT STUDENTS
      // ----------------------------
      final int totalStudents = students.length;

      // ----------------------------
      // COUNT PROFESSORS
      // ----------------------------
      final int totalDoctors = professors.length;

      // ----------------------------
      // COUNT UNIQUE SUBJECTS
      // ----------------------------
      final Set<String> subjectSet = {};

      for (var student in students) {
        final subjects = student["subjects_grades"] as Map<String, dynamic>;
        subjectSet.addAll(subjects.keys);
      }

      final int totalSubjects = subjectSet.length;

      // ----------------------------
      // PENDING REQUESTS (Fake)
      // ----------------------------
      final int pendingRequests = 5;

      // ----------------------------
      // RECENT ACTIVITY (Fake)
      // ----------------------------
      final List<String> recentActivity = [
        "تم تسجيل طالب جديد: ${students.first['name']}",
        "تعديل مادة Machine Learning",
        "دخول دكتور جديد للنظام",
        "رفع واجب جديد في AI Fundamentals",
      ];

      return DashboardState(
        isLoading: false,
        totalStudents: totalStudents,
        totalDoctors: totalDoctors,
        totalSubjects: totalSubjects,
        pendingRequests: pendingRequests,
        recentActivity: recentActivity,
        error: null,
      );
    } catch (e) {
      return DashboardState(
        isLoading: false,
        totalStudents: 0,
        totalDoctors: 0,
        totalSubjects: 0,
        pendingRequests: 0,
        recentActivity: [],
        error: e.toString(),
      );
    }
  }
}
