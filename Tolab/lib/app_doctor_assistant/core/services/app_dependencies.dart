import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../storage/token_storage.dart';
import '../../modules/admin/repositories/admin_repository.dart';
import '../../modules/auth/repositories/auth_repository.dart';
import '../../modules/dashboard/repositories/dashboard_repository.dart';
import '../../modules/lectures/repositories/lectures_repository.dart';
import '../../modules/notifications/repositories/notifications_repository.dart';
import '../../modules/quizzes/repositories/quizzes_repository.dart';
import '../../modules/schedule/repositories/schedule_repository.dart';
import '../../modules/section_content/repositories/section_content_repository.dart';
import '../../modules/settings/repositories/settings_repository.dart';
import '../../modules/staff/repositories/staff_repository.dart';
import '../../modules/subjects/repositories/subjects_repository.dart';
import '../../modules/tasks/repositories/tasks_repository.dart';
import '../../modules/uploads/repositories/uploads_repository.dart';

class AppDependencies {
  AppDependencies._({
    required this.tokenStorage,
    required this.apiClient,
    required this.authRepository,
    required this.dashboardRepository,
    required this.subjectsRepository,
    required this.lecturesRepository,
    required this.sectionContentRepository,
    required this.quizzesRepository,
    required this.tasksRepository,
    required this.scheduleRepository,
    required this.notificationsRepository,
    required this.uploadsRepository,
    required this.settingsRepository,
    required this.staffRepository,
    required this.adminRepository,
  });

  final TokenStorage tokenStorage;
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final DashboardRepository dashboardRepository;
  final SubjectsRepository subjectsRepository;
  final LecturesRepository lecturesRepository;
  final SectionContentRepository sectionContentRepository;
  final QuizzesRepository quizzesRepository;
  final TasksRepository tasksRepository;
  final ScheduleRepository scheduleRepository;
  final NotificationsRepository notificationsRepository;
  final UploadsRepository uploadsRepository;
  final SettingsRepository settingsRepository;
  final StaffRepository staffRepository;
  final AdminRepository adminRepository;

  static Future<AppDependencies> initialize() async {
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final apiClient = ApiClient(tokenStorage: tokenStorage);

    return AppDependencies._(
      tokenStorage: tokenStorage,
      apiClient: apiClient,
      authRepository: AuthRepository(apiClient, tokenStorage),
      dashboardRepository: DashboardRepository(apiClient),
      subjectsRepository: SubjectsRepository(apiClient),
      lecturesRepository: LecturesRepository(apiClient),
      sectionContentRepository: SectionContentRepository(apiClient),
      quizzesRepository: QuizzesRepository(apiClient),
      tasksRepository: TasksRepository(apiClient),
      scheduleRepository: ScheduleRepository(apiClient),
      notificationsRepository: NotificationsRepository(apiClient),
      uploadsRepository: UploadsRepository(apiClient),
      settingsRepository: SettingsRepository(apiClient, tokenStorage),
      staffRepository: StaffRepository(apiClient),
      adminRepository: AdminRepository(apiClient),
    );
  }
}
