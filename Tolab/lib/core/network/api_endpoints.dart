class ApiEndpoints {
  static const String login = "/login/access-token";
  static const String me = "/me";
  static const String subjects = "/subjects";
  static const String lectures = "/subjects/{id}/lectures";
  static const String sections = "/subjects/{id}/sections";
  static const String tasks = "/subjects/{id}/tasks";
  static const String submissions = "/tasks/{id}/submissions";
  static const String notifications = "/notifications";
  static const String community = "/posts";
  static const String quizzes = "/quizzes";
  static const String schedule = "/schedule";
  static const String refresh = "/auth/refresh";
  static const String announcements = "/subjects/{id}/announcements";
  static const String attendance = "/subjects/{id}/attendance";
  static const String attendanceSessions = "/subjects/{id}/attendance/sessions";
  static const String gradebook = "/subjects/{id}/gradebook";
  static const String progress = "/subjects/{id}/progress";
}
