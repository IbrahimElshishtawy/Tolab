import 'package:dio/dio.dart';

class ApiEndpoints {
  static const String baseUrl = "http://localhost:8000"; // Update for real device

  static const String login = "/auth/login";
  static const String forgotPassword = "/auth/forgot-password";
  static const String verifyOtp = "/auth/verify-otp";
  static const String resetPassword = "/auth/reset-password";

  static const String homeSummary = "/home/summary";
  static const String subjects = "/subjects";

  static String lectures(int subjectId) => "/subjects/$subjectId/lectures";
  static String sections(int subjectId) => "/subjects/$subjectId/sections";
  static String quizzes(int subjectId) => "/subjects/$subjectId/quizzes";
  static String tasks(int subjectId) => "/subjects/$subjectId/tasks";

  static const String schedule = "/schedule";
  static const String posts = "/community/posts";
  static String comments(int postId) => "/community/posts/$postId/comments";
  static String reactions(int postId) => "/community/posts/$postId/reactions";

  static const String notifications = "/notifications";
  static String markRead(int id) => "/notifications/$id/read";
  static const String notificationSettings = "/settings/notifications";
  static const String profileMe = "/profile/me";
}
