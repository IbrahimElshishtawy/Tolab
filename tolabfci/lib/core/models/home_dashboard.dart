import 'notification_item.dart';
import 'quiz_models.dart';
import 'student_profile.dart';
import 'subject_models.dart';

class HomeDashboardData {
  const HomeDashboardData({
    required this.profile,
    required this.notifications,
    required this.subjects,
    required this.upcomingLectures,
    required this.upcomingSections,
    required this.upcomingQuizzes,
    required this.tasks,
    required this.courseActivities,
    required this.studyInsights,
  });

  final StudentProfile profile;
  final List<AppNotificationItem> notifications;
  final List<SubjectOverview> subjects;
  final List<LectureItem> upcomingLectures;
  final List<SectionItem> upcomingSections;
  final List<QuizItem> upcomingQuizzes;
  final List<TaskItem> tasks;
  final List<CourseActivityItem> courseActivities;
  final StudyInsightsData studyInsights;
}

class CourseActivityItem {
  const CourseActivityItem({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAtLabel,
    required this.createdAt,
  });

  final String id;
  final String subjectId;
  final String subjectName;
  final String title;
  final String description;
  final CourseActivityType type;
  final String createdAtLabel;
  final DateTime createdAt;
}

enum CourseActivityType { lecture, quiz, assignment, groupPost, announcement }

class StudyInsightsData {
  const StudyInsightsData({
    required this.completedTasks,
    required this.pendingTasks,
    required this.viewedLectures,
    required this.engagementScore,
    required this.engagementLabel,
  });

  final int completedTasks;
  final int pendingTasks;
  final int viewedLectures;
  final double engagementScore;
  final String engagementLabel;
}
