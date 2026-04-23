import 'package:flutter/material.dart';

import '../models/session_user.dart';
import '../widgets/app_shell.dart';
import 'app_routes.dart';

class DoctorAssistantNavigationItem {
  const DoctorAssistantNavigationItem({
    required this.label,
    required this.path,
    required this.icon,
    this.opensMoreMenu = false,
  });

  final String label;
  final String path;
  final IconData icon;
  final bool opensMoreMenu;
}

class DoctorAssistantNavigationConfig {
  const DoctorAssistantNavigationConfig({
    required this.sidebarItems,
    required this.mobilePrimaryItems,
    required this.mobileMoreItems,
  });

  final List<DoctorAssistantNavigationItem> sidebarItems;
  final List<DoctorAssistantNavigationItem> mobilePrimaryItems;
  final List<DoctorAssistantNavigationItem> mobileMoreItems;

  String labelForLocation(String location) {
    for (final item in sidebarItems) {
      if (_matchesLocation(location, item.path)) {
        return item.label;
      }
    }
    return mobilePrimaryItems.last.label;
  }

  int mobileSelectedIndex(String location) {
    final directIndex = mobilePrimaryItems.indexWhere(
      (item) => !item.opensMoreMenu && _matchesLocation(location, item.path),
    );
    if (directIndex >= 0) {
      return directIndex;
    }
    return mobilePrimaryItems.length - 1;
  }
}

DoctorAssistantNavigationConfig buildDoctorAssistantNavigationConfig(
  SessionUser user,
) {
  final homeItem = const DoctorAssistantNavigationItem(
    label: 'home',
    path: AppRoutes.dashboard,
    icon: Icons.grid_view_rounded,
  );
  final subjectsItem = const DoctorAssistantNavigationItem(
    label: 'subjects',
    path: AppRoutes.subjects,
    icon: Icons.menu_book_rounded,
  );
  final scheduleItem = const DoctorAssistantNavigationItem(
    label: 'schedule',
    path: AppRoutes.schedule,
    icon: Icons.calendar_month_rounded,
  );
  final studentsItem = DoctorAssistantNavigationItem(
    label: user.hasPermission('students.view') ? 'الطلاب' : 'Profile',
    path: user.hasPermission('students.view')
        ? AppRoutes.students
        : AppRoutes.staff,
    icon: user.hasPermission('students.view')
        ? Icons.school_rounded
        : Icons.person_rounded,
  );

  final moreItems = <DoctorAssistantNavigationItem>[
    if (user.hasPermission('lectures.view'))
      const DoctorAssistantNavigationItem(
        label: 'المحاضرات',
        path: AppRoutes.lectures,
        icon: Icons.slideshow_rounded,
      ),
    if (user.hasPermission('section_content.view'))
      const DoctorAssistantNavigationItem(
        label: 'السكاشن',
        path: AppRoutes.sectionContent,
        icon: Icons.widgets_rounded,
      ),
    if (user.hasPermission('quizzes.view'))
      const DoctorAssistantNavigationItem(
        label: 'الاختبارات',
        path: AppRoutes.quizzes,
        icon: Icons.fact_check_rounded,
      ),
    if (user.hasPermission('tasks.view'))
      const DoctorAssistantNavigationItem(
        label: 'التكليفات',
        path: AppRoutes.tasks,
        icon: Icons.assignment_rounded,
      ),
    if (user.hasPermission('results.view'))
      const DoctorAssistantNavigationItem(
        label: 'النتائج',
        path: AppRoutes.results,
        icon: Icons.grading_rounded,
      ),
    const DoctorAssistantNavigationItem(
      label: 'التنبيهات',
      path: AppRoutes.notifications,
      icon: Icons.notifications_active_rounded,
    ),
    if (user.hasPermission('announcements.view'))
      const DoctorAssistantNavigationItem(
        label: 'الإعلانات',
        path: AppRoutes.announcements,
        icon: Icons.campaign_rounded,
      ),
    const DoctorAssistantNavigationItem(
      label: 'الإعدادات',
      path: AppRoutes.settings,
      icon: Icons.tune_rounded,
    ),
    if (user.hasPermission('students.view'))
      const DoctorAssistantNavigationItem(
        label: 'Profile',
        path: AppRoutes.staff,
        icon: Icons.person_rounded,
      ),
    if (user.hasPermission('uploads.view'))
      const DoctorAssistantNavigationItem(
        label: 'الاضفات',
        path: AppRoutes.uploads,
        icon: Icons.upload_file_rounded,
      ),
    if (user.hasPermission('analytics.view'))
      const DoctorAssistantNavigationItem(
        label: 'Analytics',
        path: AppRoutes.analytics,
        icon: Icons.insights_rounded,
      ),
    if (user.isAdmin)
      const DoctorAssistantNavigationItem(
        label: 'Home',
        path: AppRoutes.admin,
        icon: Icons.admin_panel_settings_rounded,
      ),
  ];

  final sidebarItems = <DoctorAssistantNavigationItem>[
    homeItem,
    subjectsItem,
    scheduleItem,
    studentsItem,
    ...moreItems,
  ];

  return DoctorAssistantNavigationConfig(
    sidebarItems: sidebarItems,
    mobilePrimaryItems: [
      homeItem,
      subjectsItem,
      scheduleItem,
      studentsItem,
      const DoctorAssistantNavigationItem(
        label: 'المزيد',
        path: '__more__',
        icon: Icons.more_horiz_rounded,
        opensMoreMenu: true,
      ),
    ],
    mobileMoreItems: moreItems,
  );
}

bool _matchesLocation(String location, String path) {
  return location == path || location.startsWith('$path/');
}

List<ShellNavItem> buildNavigationItems(SessionUser user) {
  return buildDoctorAssistantNavigationConfig(user).sidebarItems
      .map(
        (item) =>
            ShellNavItem(label: item.label, path: item.path, icon: item.icon),
      )
      .toList(growable: false);
}
