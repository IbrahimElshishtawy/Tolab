import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/home_dashboard.dart';
import '../../../../core/models/quiz_models.dart';
import '../../../../core/models/subject_models.dart';
import '../../../../core/models/timetable_item.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../domain/repositories/timetable_repository.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return MockTimetableRepository(ref.watch(mockBackendServiceProvider));
});

class MockTimetableRepository implements TimetableRepository {
  const MockTimetableRepository(this._backendService);

  final MockBackendService _backendService;

  @override
  Future<List<TimetableItem>> getStudentTimetable({
    String weekPattern = 'all',
    DateTime? date,
  }) async {
    final dashboard = await _backendService.fetchHomeDashboard();
    return _filterByWeekPattern(_fromDashboard(dashboard), weekPattern);
  }

  @override
  Future<List<TimetableItem>> getDoctorTimetable({
    String weekPattern = 'all',
    DateTime? date,
  }) {
    return getStudentTimetable(weekPattern: weekPattern, date: date);
  }

  @override
  Future<List<TimetableItem>> getAdminSchedule({
    Map<String, Object?> filters = const {},
  }) {
    return getStudentTimetable();
  }

  List<TimetableItem> _fromDashboard(HomeDashboardData dashboard) {
    final lectures = dashboard.upcomingLectures
        .where((item) => item.startsAt != null && item.endsAt != null)
        .map(_lectureToItem);
    final sections = dashboard.upcomingSections
        .where((item) => item.startsAt != null && item.endsAt != null)
        .map(_sectionToItem);
    final quizzes = dashboard.upcomingQuizzes
        .where((item) => item.startsAt != null && item.closesAt != null)
        .map(_quizToItem);
    final tasks = dashboard.tasks.where((item) => item.dueAt != null).map(
          _taskToItem,
        );

    final items = [...lectures, ...sections, ...quizzes, ...tasks]
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return items;
  }

  TimetableItem _lectureToItem(LectureItem lecture) {
    return TimetableItem(
      id: lecture.id,
      subjectId: lecture.subjectId,
      subjectName: lecture.subjectName ?? 'Course',
      title: lecture.title,
      typeLabel: 'Lecture',
      locationLabel:
          lecture.locationLabel ?? (lecture.isOnline ? 'Online' : 'Hall'),
      hostName: lecture.instructorName ?? 'Doctor',
      startsAt: lecture.startsAt!,
      endsAt: lecture.endsAt!,
      routeName: RouteNames.subjectDetails,
      pathParameters: {'subjectId': lecture.subjectId},
    );
  }

  TimetableItem _sectionToItem(SectionItem section) {
    return TimetableItem(
      id: section.id,
      subjectId: section.subjectId,
      subjectName: section.subjectName ?? 'Course',
      title: section.title,
      typeLabel: 'Section',
      locationLabel: section.location,
      hostName: section.assistantName,
      startsAt: section.startsAt!,
      endsAt: section.endsAt!,
      routeName: RouteNames.subjectDetails,
      pathParameters: {'subjectId': section.subjectId},
    );
  }

  TimetableItem _quizToItem(QuizItem quiz) {
    return TimetableItem(
      id: quiz.id,
      subjectId: quiz.subjectId,
      subjectName: quiz.subjectName ?? 'Course',
      title: quiz.title,
      typeLabel: 'Quiz',
      locationLabel: quiz.locationLabel ?? 'App',
      hostName: quiz.isOnline ? 'Online' : 'Campus',
      startsAt: quiz.startsAt!,
      endsAt: quiz.closesAt!,
      routeName: RouteNames.quizEntry,
      pathParameters: {'subjectId': quiz.subjectId, 'quizId': quiz.id},
    );
  }

  TimetableItem _taskToItem(TaskItem task) {
    return TimetableItem(
      id: task.id,
      subjectId: task.subjectId,
      subjectName: task.subjectName ?? 'Course',
      title: task.title,
      typeLabel: 'Task Due',
      locationLabel: 'Upload in app',
      hostName: task.status,
      startsAt: task.dueAt!,
      endsAt: task.dueAt!,
      routeName: RouteNames.assignmentUpload,
      pathParameters: {'subjectId': task.subjectId, 'taskId': task.id},
    );
  }

  List<TimetableItem> _filterByWeekPattern(
    List<TimetableItem> items,
    String weekPattern,
  ) {
    if (weekPattern == 'all') {
      return items;
    }

    return items.where((item) {
      final weekNumber =
          ((item.startsAt.difference(DateTime(item.startsAt.year)).inDays) ~/
                  7) +
              1;
      final isOdd = weekNumber.isOdd;
      return weekPattern == 'odd' ? isOdd : !isOdd;
    }).toList();
  }
}
