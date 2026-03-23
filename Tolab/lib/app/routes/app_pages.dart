import 'package:get/get.dart';

import '../core/middleware/auth_middleware.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/courses/views/course_content_view.dart';
import '../modules/courses/views/course_detail_view.dart';
import '../modules/courses/views/grades_view.dart';
import '../modules/file_preview/views/file_preview_view.dart';
import '../modules/group/views/group_view.dart';
import '../modules/group/views/post_details_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/search/views/search_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/shell/bindings/shell_binding.dart';
import '../modules/shell/views/shell_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import 'app_routes.dart';
import 'app_transitions.dart';

class AppPages {
  const AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: SplashView.new,
      binding: SplashBinding(),
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: OnboardingView.new,
      binding: OnboardingBinding(),
      middlewares: [AuthMiddleware(allowGuestsOnly: true)],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.login,
      page: LoginView.new,
      binding: AuthBinding(),
      middlewares: [AuthMiddleware(allowGuestsOnly: true)],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: ForgotPasswordView.new,
      binding: AuthBinding(),
      middlewares: [AuthMiddleware(allowGuestsOnly: true)],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.shell,
      page: ShellView.new,
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.courseDetails,
      page: CourseDetailView.new,
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.courseContent,
      page: CourseContentView.new,
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.grades,
      page: GradesView.new,
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.group,
      page: GroupView.new,
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.postDetails,
      page: PostDetailsView.new,
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.search,
      page: SearchView.new,
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: SettingsView.new,
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.filePreview,
      page: FilePreviewView.new,
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      customTransition: CupertinoSlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 420),
    ),
  ];
}
