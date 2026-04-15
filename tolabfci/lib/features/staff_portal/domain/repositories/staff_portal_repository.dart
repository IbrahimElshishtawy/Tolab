import '../../../../core/models/notification_item.dart';
import '../models/staff_portal_models.dart';

abstract class StaffPortalRepository {
  Future<StaffDashboardData> fetchDashboard();

  Future<StaffProfile> fetchProfile();

  Future<List<StaffCourseSummary>> fetchCourses();

  Future<StaffSubjectWorkspace> fetchSubjectWorkspace(String subjectId);

  Future<List<StaffScheduleEvent>> fetchSchedule();

  Future<List<AppNotificationItem>> fetchNotifications();

  Stream<List<AppNotificationItem>> watchNotifications();

  Future<void> markNotificationAsRead(String notificationId);

  Future<StaffQuiz> saveQuiz({
    required String subjectId,
    required StaffQuiz quiz,
  });

  Future<StaffAnnouncement> saveAnnouncement({
    required String subjectId,
    required StaffAnnouncement announcement,
  });

  Future<void> deleteAnnouncement({
    required String subjectId,
    required String announcementId,
  });

  Future<StaffAnnouncement> toggleAnnouncementPublication({
    required String subjectId,
    required String announcementId,
  });

  Future<StaffGroupPost> savePost({
    required String subjectId,
    required StaffGroupPost post,
  });

  Future<void> addComment({
    required String subjectId,
    required String postId,
    required StaffGroupComment comment,
  });

  Future<StaffSessionLink> saveSession({
    required String subjectId,
    required StaffSessionLink session,
  });

  Future<StaffScheduleEvent> saveScheduleEvent({
    required String subjectId,
    required StaffScheduleEvent event,
  });

  Future<void> deleteScheduleEvent({
    required String subjectId,
    required String eventId,
  });
}
