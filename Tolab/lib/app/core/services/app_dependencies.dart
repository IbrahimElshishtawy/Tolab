import '../../modules/auth/repositories/auth_repository.dart';
import '../../modules/auth/services/auth_service.dart';
import '../../modules/content_management/repositories/content_repository.dart';
import '../../modules/course_offerings/repositories/course_offerings_repository.dart';
import '../../modules/dashboard/repositories/dashboard_repository.dart';
import '../../modules/departments/repositories/departments_repository.dart';
import '../../modules/enrollments/repositories/enrollments_repository.dart';
import '../../modules/moderation/repositories/moderation_repository.dart';
import '../../modules/notifications/repositories/notifications_repository.dart';
import '../../modules/roles_permissions/repositories/roles_repository.dart';
import '../../modules/schedule/repositories/schedule_repository.dart';
import '../../modules/sections/repositories/sections_repository.dart';
import '../../modules/settings/repositories/settings_repository.dart';
import '../../modules/staff/repositories/staff_repository.dart';
import '../../modules/students/repositories/students_repository.dart';
import '../../modules/subjects/repositories/subjects_repository.dart';
import '../../modules/uploads/repositories/uploads_repository.dart';
import '../network/api_client.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import 'demo_data_service.dart';
import 'notification_service.dart';

class AppDependencies {
  AppDependencies._({
    required this.localStorage,
    required this.secureStorage,
    required this.notificationService,
    required this.apiClient,
    required this.demoDataService,
    required this.authRepository,
    required this.authService,
    required this.dashboardRepository,
    required this.studentsRepository,
    required this.staffRepository,
    required this.departmentsRepository,
    required this.sectionsRepository,
    required this.subjectsRepository,
    required this.courseOfferingsRepository,
    required this.enrollmentsRepository,
    required this.contentRepository,
    required this.uploadsRepository,
    required this.scheduleRepository,
    required this.notificationsRepository,
    required this.moderationRepository,
    required this.rolesRepository,
    required this.settingsRepository,
  });

  final LocalStorageService localStorage;
  final SecureStorageService secureStorage;
  final NotificationService notificationService;
  final ApiClient apiClient;
  final DemoDataService demoDataService;
  final AuthRepository authRepository;
  final AuthService authService;
  final DashboardRepository dashboardRepository;
  final StudentsRepository studentsRepository;
  final StaffRepository staffRepository;
  final DepartmentsRepository departmentsRepository;
  final SectionsRepository sectionsRepository;
  final SubjectsRepository subjectsRepository;
  final CourseOfferingsRepository courseOfferingsRepository;
  final EnrollmentsRepository enrollmentsRepository;
  final ContentRepository contentRepository;
  final UploadsRepository uploadsRepository;
  final ScheduleRepository scheduleRepository;
  final NotificationsRepository notificationsRepository;
  final ModerationRepository moderationRepository;
  final RolesRepository rolesRepository;
  final SettingsRepository settingsRepository;

  static Future<AppDependencies> initialize() async {
    final localStorage = await LocalStorageService.initialize();
    final secureStorage = SecureStorageService();
    final notificationService = await NotificationService.initialize();
    final apiClient = ApiClient(secureStorage: secureStorage);
    final demoDataService = const DemoDataService();

    return AppDependencies._(
      localStorage: localStorage,
      secureStorage: secureStorage,
      notificationService: notificationService,
      apiClient: apiClient,
      demoDataService: demoDataService,
      authRepository: AuthRepository(apiClient, demoDataService),
      authService: AuthService(secureStorage),
      dashboardRepository: DashboardRepository(demoDataService),
      studentsRepository: StudentsRepository(),
      staffRepository: StaffRepository(demoDataService),
      departmentsRepository: DepartmentsRepository(apiClient, demoDataService),
      sectionsRepository: SectionsRepository(demoDataService),
      subjectsRepository: SubjectsRepository(demoDataService),
      courseOfferingsRepository: CourseOfferingsRepository(demoDataService),
      enrollmentsRepository: EnrollmentsRepository(demoDataService),
      contentRepository: ContentRepository(demoDataService),
      uploadsRepository: UploadsRepository(demoDataService),
      scheduleRepository: ScheduleRepository(demoDataService),
      notificationsRepository: NotificationsRepository(demoDataService),
      moderationRepository: ModerationRepository(demoDataService),
      rolesRepository: RolesRepository(demoDataService),
      settingsRepository: SettingsRepository(demoDataService),
    );
  }
}
