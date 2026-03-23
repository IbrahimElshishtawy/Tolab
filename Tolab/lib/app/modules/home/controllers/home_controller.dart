import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../../../data/dto/pagination_query_dto.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/notification_item_model.dart';
import '../../../data/models/schedule_event_model.dart';
import '../../../data/repositories/courses_repository.dart';
import '../../../data/repositories/notifications_repository.dart';
import '../../../data/repositories/schedule_repository.dart';

class HomeController extends GetxController {
  HomeController({
    required CoursesRepository coursesRepository,
    required NotificationsRepository notificationsRepository,
    required ScheduleRepository scheduleRepository,
    required SessionService sessionService,
  }) : _coursesRepository = coursesRepository,
       _notificationsRepository = notificationsRepository,
       _scheduleRepository = scheduleRepository,
       _sessionService = sessionService;

  final CoursesRepository _coursesRepository;
  final NotificationsRepository _notificationsRepository;
  final ScheduleRepository _scheduleRepository;
  final SessionService _sessionService;

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<CourseModel> spotlightCourses = <CourseModel>[].obs;
  final RxList<NotificationItemModel> latestNotifications =
      <NotificationItemModel>[].obs;
  final RxList<ScheduleEventModel> todaySchedule = <ScheduleEventModel>[].obs;

  String get userName =>
      _sessionService.currentUser.value?.name ??
      _sessionService.currentUser.value?.email ??
      'Student';

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    error.value = '';

    final coursesResult = await _coursesRepository.list(
      const PaginationQueryDto(perPage: 4),
    );
    final notificationsResult = await _notificationsRepository.list(
      const PaginationQueryDto(perPage: 5),
    );
    final scheduleResult = await _scheduleRepository.list();

    coursesResult.when(
      success: (data) => spotlightCourses.assignAll(data.items),
      failure: (failure) => error.value = failure.message,
    );
    notificationsResult.when(
      success: (data) => latestNotifications.assignAll(data.items),
      failure: (failure) =>
          error.value = error.value.isEmpty ? failure.message : error.value,
    );
    scheduleResult.when(
      success: (data) => todaySchedule.assignAll(data.take(4)),
      failure: (failure) =>
          error.value = error.value.isEmpty ? failure.message : error.value,
    );

    isLoading.value = false;
  }
}
