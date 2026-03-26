import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/middleware/auth_middleware.dart';
import '../modules/academic_years/bindings/academic_years_binding.dart';
import '../modules/academic_years/views/academic_years_view.dart';
import '../modules/assignments/bindings/assignments_binding.dart';
import '../modules/assignments/views/assignments_view.dart';
import '../modules/assistants/bindings/assistants_binding.dart';
import '../modules/assistants/views/assistants_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/batches/bindings/batches_binding.dart';
import '../modules/batches/views/batches_view.dart';
import '../modules/course_offerings/bindings/course_offerings_binding.dart';
import '../modules/course_offerings/views/course_offerings_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/departments/bindings/departments_binding.dart';
import '../modules/departments/views/departments_view.dart';
import '../modules/doctors/bindings/doctors_binding.dart';
import '../modules/doctors/views/doctors_view.dart';
import '../modules/enrollments/bindings/enrollments_binding.dart';
import '../modules/enrollments/views/enrollments_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/broadcast_notification_view.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/schedule/bindings/schedule_binding.dart';
import '../modules/schedule/views/schedule_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/shell/views/shell_view.dart';
import '../modules/shared/models/navigation_item.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/students/bindings/students_binding.dart';
import '../modules/students/views/student_details_view.dart';
import '../modules/students/views/student_form_view.dart';
import '../modules/students/views/students_view.dart';
import '../modules/subjects/bindings/subjects_binding.dart';
import '../modules/subjects/views/subjects_view.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: SplashView.new,
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: LoginView.new,
      binding: AuthBinding(),
      middlewares: [AuthMiddleware(allowGuestsOnly: true)],
    ),
    _shell(
      route: AppRoutes.dashboard,
      title: 'Dashboard',
      item: NavigationItem.dashboard,
      page: const DashboardView(),
      binding: DashboardBinding(),
    ),
    _shell(
      route: AppRoutes.students,
      title: 'Students',
      item: NavigationItem.students,
      page: const StudentsView(),
      binding: StudentsBinding(),
    ),
    _shell(
      route: AppRoutes.studentDetails,
      title: 'Student Details',
      item: NavigationItem.students,
      page: const StudentDetailsView(),
      binding: StudentsBinding(),
    ),
    _shell(
      route: AppRoutes.studentForm,
      title: 'Student Form',
      item: NavigationItem.students,
      page: const StudentFormView(),
      binding: StudentsBinding(),
    ),
    _shell(
      route: AppRoutes.doctors,
      title: 'Doctors',
      item: NavigationItem.doctors,
      page: const DoctorsView(),
      binding: DoctorsBinding(),
    ),
    _shell(
      route: AppRoutes.assistants,
      title: 'Assistants',
      item: NavigationItem.assistants,
      page: const AssistantsView(),
      binding: AssistantsBinding(),
    ),
    _shell(
      route: AppRoutes.departments,
      title: 'Departments',
      item: NavigationItem.departments,
      page: const DepartmentsView(),
      binding: DepartmentsBinding(),
    ),
    _shell(
      route: AppRoutes.academicYears,
      title: 'Academic Years',
      item: NavigationItem.academicYears,
      page: const AcademicYearsView(),
      binding: AcademicYearsBinding(),
    ),
    _shell(
      route: AppRoutes.batches,
      title: 'Batches',
      item: NavigationItem.batches,
      page: const BatchesView(),
      binding: BatchesBinding(),
    ),
    _shell(
      route: AppRoutes.subjects,
      title: 'Subjects',
      item: NavigationItem.subjects,
      page: const SubjectsView(),
      binding: SubjectsBinding(),
    ),
    _shell(
      route: AppRoutes.assignments,
      title: 'Assignments',
      item: NavigationItem.assignments,
      page: const AssignmentsView(),
      binding: AssignmentsBinding(),
    ),
    _shell(
      route: AppRoutes.courseOfferings,
      title: 'Course Offerings',
      item: NavigationItem.offerings,
      page: const CourseOfferingsView(),
      binding: CourseOfferingsBinding(),
    ),
    _shell(
      route: AppRoutes.enrollments,
      title: 'Enrollments',
      item: NavigationItem.enrollments,
      page: const EnrollmentsView(),
      binding: EnrollmentsBinding(),
    ),
    _shell(
      route: AppRoutes.schedule,
      title: 'Schedule',
      item: NavigationItem.schedule,
      page: const ScheduleView(),
      binding: ScheduleBinding(),
    ),
    _shell(
      route: AppRoutes.notifications,
      title: 'Notifications',
      item: NavigationItem.notifications,
      page: const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    _shell(
      route: AppRoutes.broadcastNotifications,
      title: 'Broadcast Notifications',
      item: NavigationItem.notifications,
      page: const BroadcastNotificationView(),
      binding: NotificationsBinding(),
    ),
    _shell(
      route: AppRoutes.settings,
      title: 'Settings',
      item: NavigationItem.settings,
      page: const SettingsView(),
      binding: SettingsBinding(),
    ),
    _shell(
      route: AppRoutes.profile,
      title: 'Profile',
      item: NavigationItem.profile,
      page: const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];

  static GetPage<dynamic> _shell({
    required String route,
    required String title,
    required NavigationItem item,
    required Widget page,
    required Bindings binding,
  }) {
    return GetPage(
      name: route,
      page: () => ShellView(title: title, currentItem: item, child: page),
      binding: binding,
      middlewares: [AuthMiddleware()],
    );
  }
}
