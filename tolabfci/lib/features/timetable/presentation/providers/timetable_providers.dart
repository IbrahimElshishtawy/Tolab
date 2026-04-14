import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/timetable_item.dart';
import '../../../../core/router/route_names.dart';
import '../../../home/presentation/providers/home_providers.dart';

final timetableItemsProvider = Provider<AsyncValue<List<TimetableItem>>>((ref) {
  final dashboardAsync = ref.watch(homeDashboardProvider);

  return dashboardAsync.whenData((dashboard) {
    final lectures = dashboard.upcomingLectures
        .where((item) => item.startsAt != null && item.endsAt != null)
        .map(
          (lecture) => TimetableItem(
            id: lecture.id,
            subjectId: lecture.subjectId,
            subjectName: lecture.subjectName ?? 'المادة',
            title: lecture.title,
            typeLabel: 'محاضرة',
            locationLabel: lecture.locationLabel ?? (lecture.isOnline ? 'أونلاين' : 'القاعة'),
            hostName: lecture.instructorName ?? 'الدكتور',
            startsAt: lecture.startsAt!,
            endsAt: lecture.endsAt!,
            routeName: RouteNames.subjectDetails,
            pathParameters: {'subjectId': lecture.subjectId},
          ),
        );

    final sections = dashboard.upcomingSections
        .where((item) => item.startsAt != null && item.endsAt != null)
        .map(
          (section) => TimetableItem(
            id: section.id,
            subjectId: section.subjectId,
            subjectName: section.subjectName ?? 'المادة',
            title: section.title,
            typeLabel: 'سكشن',
            locationLabel: section.location,
            hostName: section.assistantName,
            startsAt: section.startsAt!,
            endsAt: section.endsAt!,
            routeName: RouteNames.subjectDetails,
            pathParameters: {'subjectId': section.subjectId},
          ),
        );

    final quizzes = dashboard.upcomingQuizzes
        .where((item) => item.startsAt != null && item.closesAt != null)
        .map(
          (quiz) => TimetableItem(
            id: quiz.id,
            subjectId: quiz.subjectId,
            subjectName: quiz.subjectName ?? 'المادة',
            title: quiz.title,
            typeLabel: 'كويز',
            locationLabel: quiz.locationLabel ?? 'على التطبيق',
            hostName: quiz.isOnline ? 'أونلاين' : 'داخل الجامعة',
            startsAt: quiz.startsAt!,
            endsAt: quiz.closesAt!,
            routeName: RouteNames.quizEntry,
            pathParameters: {'subjectId': quiz.subjectId, 'quizId': quiz.id},
          ),
        );

    final assignments = dashboard.tasks
        .where((item) => item.dueAt != null)
        .map(
          (task) => TimetableItem(
            id: task.id,
            subjectId: task.subjectId,
            subjectName: task.subjectName ?? 'المادة',
            title: task.title,
            typeLabel: 'موعد تسليم',
            locationLabel: 'رفع عبر التطبيق',
            hostName: task.status,
            startsAt: task.dueAt!,
            endsAt: task.dueAt!,
            routeName: RouteNames.assignmentUpload,
            pathParameters: {'subjectId': task.subjectId, 'taskId': task.id},
          ),
        );

    final items = [...lectures, ...sections, ...quizzes, ...assignments].toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    return items;
  });
});
