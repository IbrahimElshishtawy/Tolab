import 'package:flutter/material.dart';

import '../models/session_user.dart';
import '../widgets/app_shell.dart';
import 'app_routes.dart';

List<ShellNavItem> buildNavigationItems(SessionUser user) {
  final items = <ShellNavItem>[
    const ShellNavItem(
      label: 'layout.doctor.nav.home',
      path: AppRoutes.dashboard,
      icon: Icons.grid_view_rounded,
    ),
    const ShellNavItem(
      label: 'layout.doctor.nav.subjects',
      path: AppRoutes.subjects,
      icon: Icons.menu_book_rounded,
    ),
  ];

  if (user.hasPermission('lectures.view')) {
    items.add(
      const ShellNavItem(
        label: 'layout.doctor.nav.lectures',
        path: AppRoutes.lectures,
        icon: Icons.slideshow_rounded,
      ),
    );
  }

  if (user.hasPermission('section_content.view')) {
    items.add(
      const ShellNavItem(
        label: 'layout.doctor.nav.sections',
        path: AppRoutes.sectionContent,
        icon: Icons.widgets_rounded,
      ),
    );
  }

  if (user.hasPermission('quizzes.view')) {
    items.add(
      const ShellNavItem(
        label: 'layout.doctor.nav.quizzes',
        path: AppRoutes.quizzes,
        icon: Icons.fact_check_rounded,
      ),
    );
  }

  if (user.hasPermission('tasks.view')) {
    items.add(
      const ShellNavItem(
        label: 'layout.doctor.nav.tasks',
        path: AppRoutes.tasks,
        icon: Icons.assignment_rounded,
      ),
    );
  }

  if (user.hasPermission('results.view')) {
    items.add(
      const ShellNavItem(
        label: 'Results',
        path: AppRoutes.results,
        icon: Icons.grading_rounded,
      ),
    );
  }

  if (user.hasPermission('students.view')) {
    items.add(
      const ShellNavItem(
        label: 'Students',
        path: AppRoutes.students,
        icon: Icons.school_rounded,
      ),
    );
  }

  items.addAll([
    const ShellNavItem(
      label: 'layout.doctor.nav.schedule',
      path: AppRoutes.schedule,
      icon: Icons.calendar_month_rounded,
    ),
    const ShellNavItem(
      label: 'layout.doctor.nav.alerts',
      path: AppRoutes.notifications,
      icon: Icons.notifications_active_rounded,
    ),
  ]);

  if (user.hasPermission('announcements.view')) {
    items.add(
      const ShellNavItem(
        label: 'Announcements',
        path: AppRoutes.announcements,
        icon: Icons.campaign_rounded,
      ),
    );
  }

  if (user.hasPermission('analytics.view')) {
    items.add(
      const ShellNavItem(
        label: 'Analytics',
        path: AppRoutes.analytics,
        icon: Icons.insights_rounded,
      ),
    );
  }

  if (user.hasPermission('uploads.view')) {
    items.add(
      const ShellNavItem(
        label: 'layout.doctor.nav.uploads',
        path: AppRoutes.uploads,
        icon: Icons.upload_file_rounded,
      ),
    );
  }

  items.add(
    const ShellNavItem(
      label: 'Profile',
      path: AppRoutes.staff,
      icon: Icons.person_rounded,
    ),
  );

  if (user.isAdmin) {
    items.add(
      const ShellNavItem(
        label: 'layout.doctor.nav.admin',
        path: AppRoutes.admin,
        icon: Icons.admin_panel_settings_rounded,
      ),
    );
  }

  items.add(
    const ShellNavItem(
      label: 'layout.doctor.nav.settings',
      path: AppRoutes.settings,
      icon: Icons.tune_rounded,
    ),
  );

  return items;
}
