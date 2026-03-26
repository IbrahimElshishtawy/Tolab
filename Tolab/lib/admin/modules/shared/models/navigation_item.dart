import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';

enum NavigationItem {
  dashboard('Dashboard', AppRoutes.dashboard, Icons.grid_view_rounded),
  students('Students', AppRoutes.students, Icons.people_alt_rounded),
  doctors('Doctors', AppRoutes.doctors, Icons.medical_services_rounded),
  assistants('Assistants', AppRoutes.assistants, Icons.groups_3_rounded),
  departments('Departments', AppRoutes.departments, Icons.account_tree_rounded),
  academicYears(
    'Academic Years',
    AppRoutes.academicYears,
    Icons.date_range_rounded,
  ),
  batches('Batches', AppRoutes.batches, Icons.layers_rounded),
  subjects('Subjects', AppRoutes.subjects, Icons.menu_book_rounded),
  assignments(
    'Assignments',
    AppRoutes.assignments,
    Icons.assignment_turned_in_rounded,
  ),
  offerings('Course Offerings', AppRoutes.courseOfferings, Icons.class_rounded),
  enrollments('Enrollments', AppRoutes.enrollments, Icons.fact_check_rounded),
  schedule('Schedule', AppRoutes.schedule, Icons.calendar_month_rounded),
  notifications(
    'Notifications',
    AppRoutes.notifications,
    Icons.notifications_active_rounded,
  ),
  settings('Settings', AppRoutes.settings, Icons.tune_rounded),
  profile('Profile', AppRoutes.profile, Icons.person_rounded);

  const NavigationItem(this.label, this.route, this.icon);

  final String label;
  final String route;
  final IconData icon;

  static NavigationItem fromRoute(String route) {
    return NavigationItem.values.firstWhere(
      (item) => route.startsWith(item.route),
      orElse: () => NavigationItem.dashboard,
    );
  }
}
