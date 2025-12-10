// ignore_for_file: file_names

import 'package:eduhub/fake_data/data.dart';
import 'package:flutter/foundation.dart';
import '../../state/dashboard/dashboard_state.dart';

class ApiServiceDashboard {
  /// Fetch Dashboard Summary From Fake Data
  Future<DashboardState> fetchDashboardState() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      if (kDebugMode) {
        print("===== Fetching Dashboard Fake Data =====");
      }

      // ----------------------------------------------------------
      // COUNT STUDENTS
      // ----------------------------------------------------------
      int totalStudents = students.length;
      if (kDebugMode) {
        print("Total Students: $totalStudents");
      }

      // ----------------------------------------------------------
      // COUNT PROFESSORS
      // ----------------------------------------------------------
      int totalDoctors = professors.length;
      if (kDebugMode) {
        print("Total Professors: $totalDoctors");
      }

      // ----------------------------------------------------------
      // COUNT UNIQUE SUBJECTS
      // ----------------------------------------------------------
      final Set<String> subjectsSet = {};

      for (var student in students) {
        final subjectsMap = student["subjects_grades"] as Map<String, dynamic>;
        subjectsSet.addAll(subjectsMap.keys);
      }

      int totalSubjects = subjectsSet.length;
      if (kDebugMode) {
        print("Total Unique Subjects: $totalSubjects");
      }
      if (kDebugMode) {
        print("Subjects List: $subjectsSet");
      }

      // ----------------------------------------------------------
      // PENDING REQUESTS (Fake logic)
      // ----------------------------------------------------------
      int pendingRequests = assistants.length ~/ 2;
      if (kDebugMode) {
        print("Pending Requests: $pendingRequests");
      }

      // ----------------------------------------------------------
      // Recent Activity
      // ----------------------------------------------------------
      List<String> recentActivity = [
        "Student added: ${students.last["name"]}",
        "Professor logged in: ${professors.first["name"]}",
        "AI Ethics subject updated",
        "${students[2]["name"]} achieved GPA ${students[2]["gpa_current"]}",
      ];

      if (kDebugMode) {
        print("Recent Activity:");
      }
      for (var activity in recentActivity) {
        if (kDebugMode) {
          print(" - $activity");
        }
      }

      if (kDebugMode) {
        print("===== Dashboard Fake Data Loaded Successfully =====");
      }

      // ----------------------------------------------------------
      // RETURN DASHBOARD STATE
      // ----------------------------------------------------------
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
      if (kDebugMode) {
        print("ERROR Loading Dashboard Data: $e");
      }

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
