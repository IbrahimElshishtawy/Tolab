import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../core/network/dio_client.dart';
import '../core/services/app_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/session_service.dart';
import '../core/services/theme_service.dart';
import '../core/services/upload_service.dart';
import '../core/storage/local_storage_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../data/datasources/admin/admin_resource_remote_data_source.dart';
import '../data/repositories/admin/admin_entity_repositories.dart';
import '../data/repositories/admin/dashboard_repository.dart';
import '../data/repositories/admin/notifications_repository.dart';
import '../data/repositories/admin/profile_repository.dart';
import '../data/repositories/admin/settings_repository.dart';
import '../modules/auth/datasources/auth_remote_data_source.dart';
import '../modules/auth/repositories/auth_repository.dart';

class AdminBootstrap {
  const AdminBootstrap._();

  static Future<void> initialize() async {
    final localStorage = await LocalStorageService().init();
    final secureStorage = SecureStorageService();
    final appService = Get.put(AppService(), permanent: true);
    final connectivity = await Get.putAsync(
      () async => ConnectivityService().init(),
      permanent: true,
    );
    final session = await Get.putAsync(
      () async => SessionService(
        secureStorage: secureStorage,
        localStorage: localStorage,
      ).init(),
      permanent: true,
    );
    await Get.putAsync(
      () async => ThemeService(localStorage).init(),
      permanent: true,
    );
    await Get.putAsync(
      () async => NotificationService(localStorage).init(),
      permanent: true,
    );
    Get.put(UploadService(), permanent: true);

    final dio = DioClient.build(
      connectivityService: connectivity,
      sessionService: session,
    );
    Get.put<Dio>(dio, permanent: true);

    final remoteDataSource = AdminResourceRemoteDataSource(dio);
    Get.put(remoteDataSource, permanent: true);
    Get.put(AuthRemoteDataSource(dio), permanent: true);
    Get.put(AuthRepository(Get.find<AuthRemoteDataSource>()), permanent: true);
    Get.put(DashboardRepository(remoteDataSource), permanent: true);
    Get.put(StudentsRepository(remoteDataSource), permanent: true);
    Get.put(DoctorsRepository(remoteDataSource), permanent: true);
    Get.put(AssistantsRepository(remoteDataSource), permanent: true);
    Get.put(DepartmentsRepository(remoteDataSource), permanent: true);
    Get.put(AcademicYearsRepository(remoteDataSource), permanent: true);
    Get.put(BatchesRepository(remoteDataSource), permanent: true);
    Get.put(SubjectsRepository(remoteDataSource), permanent: true);
    Get.put(AssignmentsRepository(remoteDataSource), permanent: true);
    Get.put(CourseOfferingsRepository(remoteDataSource), permanent: true);
    Get.put(EnrollmentsRepository(remoteDataSource), permanent: true);
    Get.put(ScheduleRepository(remoteDataSource), permanent: true);
    Get.put(NotificationsRepository(remoteDataSource), permanent: true);
    Get.put(SettingsRepository(remoteDataSource), permanent: true);
    Get.put(ProfileRepository(remoteDataSource), permanent: true);

    appService.init();
  }
}
