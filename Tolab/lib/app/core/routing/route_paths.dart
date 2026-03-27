class RoutePaths {
  const RoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const students = '/students';
  static const staff = '/staff';
  static const departments = '/departments';
  static const departmentDetailsPattern = '/departments/:departmentId';
  static const sections = '/sections';
  static const subjects = '/subjects';
  static const courseOfferings = '/course-offerings';
  static const courseOfferingDetailsPattern = '/course-offerings/:offeringId';
  static const enrollments = '/enrollments';
  static const content = '/content';
  static const schedule = '/schedule';
  static const uploads = '/uploads';
  static const notifications = '/notifications';
  static const moderation = '/moderation';
  static const roles = '/roles';
  static const settings = '/settings';

  static String departmentDetails(String departmentId) =>
      '$departments/$departmentId';

  static String courseOfferingDetails(String offeringId) =>
      '$courseOfferings/$offeringId';
}
