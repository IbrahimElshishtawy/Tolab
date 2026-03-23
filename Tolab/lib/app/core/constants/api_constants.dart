class ApiConstants {
  const ApiConstants._();

  static const authLogin = '/auth/login';
  static const authRefresh = '/auth/refresh';
  static const authLogout = '/auth/logout';
  static const me = '/me';
  static const profile = '/me/profile';
  static const notifications = '/notifications';
  static const courses = '/student/courses';
  static const timetable = '/student/timetable';

  static String courseDetails(String id) => '$courses/$id';
  static String courseContent(String id) => '$courses/$id/content';
  static String courseGrades(String id) => '$courses/$id/grades';
  static String groupDetails(String id) => '/groups/$id';
  static String groupPosts(String id) => '/groups/$id/posts';
  static String groupMessages(String id) => '/groups/$id/messages';
}
