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
}
