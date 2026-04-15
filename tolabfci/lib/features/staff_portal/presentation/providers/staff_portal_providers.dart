import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/notification_item.dart';
import '../../data/repositories/mock_staff_portal_repository.dart';
import '../../domain/models/staff_portal_models.dart';

final staffDashboardProvider = FutureProvider<StaffDashboardData>((ref) {
  return ref.watch(staffPortalRepositoryProvider).fetchDashboard();
});

final staffProfileProvider = FutureProvider<StaffProfile>((ref) {
  return ref.watch(staffPortalRepositoryProvider).fetchProfile();
});

final staffCoursesProvider = FutureProvider<List<StaffCourseSummary>>((ref) {
  return ref.watch(staffPortalRepositoryProvider).fetchCourses();
});

final staffSubjectWorkspaceProvider =
    FutureProvider.family<StaffSubjectWorkspace, String>((ref, subjectId) {
      return ref
          .watch(staffPortalRepositoryProvider)
          .fetchSubjectWorkspace(subjectId);
    });

final staffScheduleProvider = FutureProvider<List<StaffScheduleEvent>>((ref) {
  return ref.watch(staffPortalRepositoryProvider).fetchSchedule();
});

final staffNotificationsStreamProvider =
    StreamProvider<List<AppNotificationItem>>((ref) {
      return ref.watch(staffPortalRepositoryProvider).watchNotifications();
    });
