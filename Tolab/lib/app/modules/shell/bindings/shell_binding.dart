import 'package:get/get.dart';

import '../../../core/services/app_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../data/datasources/base_remote_data_source.dart';
import '../../../data/datasources/courses_remote_data_source.dart';
import '../../../data/datasources/group_remote_data_source.dart';
import '../../../data/datasources/notifications_remote_data_source.dart';
import '../../../data/datasources/profile_remote_data_source.dart';
import '../../../data/datasources/schedule_remote_data_source.dart';
import '../../../data/repositories/courses_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/notifications_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../courses/controllers/course_content_controller.dart';
import '../../courses/controllers/course_detail_controller.dart';
import '../../courses/controllers/courses_controller.dart';
import '../../courses/controllers/grades_controller.dart';
import '../../group/controllers/group_controller.dart';
import '../../group/controllers/post_details_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../schedule/controllers/schedule_controller.dart';
import '../../search/controllers/search_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../controllers/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoursesRemoteDataSource>(
      () => CoursesRemoteDataSource(Get.find<BaseRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<NotificationsRemoteDataSource>(
      () => NotificationsRemoteDataSource(Get.find<BaseRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<ScheduleRemoteDataSource>(
      () => ScheduleRemoteDataSource(Get.find<BaseRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(Get.find<BaseRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<GroupRemoteDataSource>(
      () => GroupRemoteDataSource(Get.find<BaseRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<CoursesRepository>(
      () => CoursesRepository(Get.find<CoursesRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<NotificationsRepository>(
      () => NotificationsRepository(Get.find<NotificationsRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<ScheduleRepository>(
      () => ScheduleRepository(Get.find<ScheduleRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(Get.find<ProfileRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<GroupRepository>(
      () => GroupRepository(Get.find<GroupRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<ShellController>(() => ShellController(), fenix: true);
    Get.lazyPut<HomeController>(
      () => HomeController(
        coursesRepository: Get.find<CoursesRepository>(),
        notificationsRepository: Get.find<NotificationsRepository>(),
        scheduleRepository: Get.find<ScheduleRepository>(),
        sessionService: Get.find<SessionService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CoursesController>(
      () => CoursesController(Get.find<CoursesRepository>()),
      fenix: true,
    );
    Get.lazyPut<CourseDetailController>(
      () => CourseDetailController(Get.find<CoursesRepository>()),
      fenix: true,
    );
    Get.lazyPut<CourseContentController>(
      () => CourseContentController(Get.find<CoursesRepository>()),
      fenix: true,
    );
    Get.lazyPut<GradesController>(
      () => GradesController(Get.find<CoursesRepository>()),
      fenix: true,
    );
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(Get.find<NotificationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<ScheduleController>(
      () => ScheduleController(Get.find<ScheduleRepository>()),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<ProfileRepository>(),
        Get.find<SessionService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<SettingsController>(
      () => SettingsController(
        Get.find<ThemeService>(),
        Get.find<AppService>(),
        Get.find<AuthController>(),
      ),
      fenix: true,
    );
    Get.lazyPut<GroupController>(
      () => GroupController(Get.find<GroupRepository>()),
      fenix: true,
    );
    Get.lazyPut<PostDetailsController>(
      () => PostDetailsController(Get.find<GroupRepository>()),
      fenix: true,
    );
    Get.lazyPut<SearchController>(
      () => SearchController(Get.find<CoursesRepository>()),
      fenix: true,
    );
  }
}
