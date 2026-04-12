import 'notification_item.dart';
import 'quiz_models.dart';
import 'student_profile.dart';
import 'subject_models.dart';

class HomeDashboardData {
  const HomeDashboardData({
    required this.profile,
    required this.notifications,
    required this.upcomingLectures,
    required this.upcomingQuizzes,
  });

  final StudentProfile profile;
  final List<AppNotificationItem> notifications;
  final List<LectureItem> upcomingLectures;
  final List<QuizItem> upcomingQuizzes;
}
