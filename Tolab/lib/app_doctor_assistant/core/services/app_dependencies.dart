import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../app/core/config/backend_mode.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';
import '../../modules/admin/repositories/admin_repository.dart';
import '../../modules/auth/repositories/auth_repository.dart';
import '../../modules/auth/services/auth_service.dart';
import '../../modules/dashboard/repositories/dashboard_repository.dart';
import '../../modules/groups/repositories/groups_repository.dart';
import '../../modules/lectures/repositories/lectures_repository.dart';
import '../../modules/notifications/repositories/notifications_repository.dart';
import '../../modules/quizzes/repositories/quizzes_repository.dart';
import '../../modules/results/repositories/results_repository.dart';
import '../../modules/schedule/repositories/schedule_repository.dart';
import '../../modules/section_content/repositories/section_content_repository.dart';
import '../../modules/settings/repositories/settings_repository.dart';
import '../../modules/staff/repositories/staff_repository.dart';
import '../../modules/subjects/repositories/subjects_repository.dart';
import '../../modules/tasks/repositories/tasks_repository.dart';

import '../../mock/doctor_assistant_mock_repository.dart';

class AppDependencies {
  AppDependencies._({
    required this.tokenStorage,
    required this.apiClient,
    required this.authService,
    required this.authRepository,
    required this.dashboardRepository,
    required this.subjectsRepository,
    required this.groupsRepository,
    required this.lecturesRepository,
    required this.resultsRepository,
    required this.sectionContentRepository,
    required this.quizzesRepository,
    required this.tasksRepository,
    required this.scheduleRepository,
    required this.notificationsRepository,

    required this.settingsRepository,
    required this.staffRepository,
    required this.adminRepository,
  });

  final TokenStorage tokenStorage;
  final ApiClient apiClient;
  final AuthService authService;
  final AuthRepository authRepository;
  final DashboardRepository dashboardRepository;
  final SubjectsRepository subjectsRepository;
  final GroupsRepository groupsRepository;
  final LecturesRepository lecturesRepository;
  final ResultsRepository resultsRepository;
  final SectionContentRepository sectionContentRepository;
  final QuizzesRepository quizzesRepository;
  final TasksRepository tasksRepository;
  final ScheduleRepository scheduleRepository;
  final NotificationsRepository notificationsRepository;

  final SettingsRepository settingsRepository;
  final StaffRepository staffRepository;
  final AdminRepository adminRepository;

  static Future<AppDependencies> initialize() async {
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final apiClient = ApiClient(tokenStorage: tokenStorage);
    final authService = AuthService(apiClient);
    final mockRepository = DoctorAssistantMockRepository.instance;
    final useMockBackend = BackendModeConfig.isMockMode;

    return AppDependencies._(
      tokenStorage: tokenStorage,
      apiClient: apiClient,
      authService: authService,
      authRepository: useMockBackend
          ? MockAuthRepository(tokenStorage, mockRepository)
          : ApiAuthRepository(authService, tokenStorage),
      dashboardRepository: useMockBackend
          ? MockDashboardRepository(tokenStorage, mockRepository)
          : ApiDashboardRepository(apiClient),
      subjectsRepository: useMockBackend
          ? MockSubjectsRepository(tokenStorage, mockRepository)
          : ApiSubjectsRepository(apiClient),
      groupsRepository: useMockBackend
          ? MockGroupsRepository(tokenStorage, mockRepository)
          : ApiGroupsRepository(apiClient),
      lecturesRepository: useMockBackend
          ? MockLecturesRepository(tokenStorage, mockRepository)
          : ApiLecturesRepository(apiClient),
      resultsRepository: useMockBackend
          ? MockResultsRepository(tokenStorage, mockRepository)
          : ApiResultsRepository(apiClient),
      sectionContentRepository: useMockBackend
          ? MockSectionContentRepository(tokenStorage, mockRepository)
          : ApiSectionContentRepository(apiClient),
      quizzesRepository: useMockBackend
          ? MockQuizzesRepository(tokenStorage, mockRepository)
          : ApiQuizzesRepository(apiClient),
      tasksRepository: useMockBackend
          ? MockTasksRepository(tokenStorage, mockRepository)
          : ApiTasksRepository(apiClient),
      scheduleRepository: useMockBackend
          ? MockScheduleRepository(tokenStorage, mockRepository)
          : ApiScheduleRepository(apiClient),
      notificationsRepository: useMockBackend
          ? MockNotificationsRepository(tokenStorage, mockRepository)
          : ApiNotificationsRepository(apiClient),
      settingsRepository: useMockBackend
          ? MockSettingsRepository(tokenStorage, mockRepository)
          : ApiSettingsRepository(apiClient, tokenStorage),
      staffRepository: useMockBackend
          ? MockStaffRepository(mockRepository)
          : ApiStaffRepository(apiClient),
      adminRepository: useMockBackend
          ? MockAdminRepository(mockRepository)
          : ApiAdminRepository(apiClient),
    );
  }
}
