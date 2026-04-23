class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/workspace/home';
  static const subjects = '/workspace/subjects';
  static const lectures = '/workspace/lectures';
  static const addLecture = '/workspace/lectures/new';
  static const sectionContent = '/workspace/sections';
  static const quizzes = '/workspace/quizzes';
  static const tasks = '/workspace/tasks';
  static const results = '/workspace/results';
  static const students = '/workspace/students';
  static const schedule = '/workspace/schedule';
  static const notifications = '/workspace/notifications';
  static const announcements = '/workspace/announcements';
  static const analytics = '/workspace/analytics';
  static const uploads = '/workspace/uploads';
  static const staff = '/workspace/staff';
  static const admin = '/workspace/admin';
  static const settings = '/workspace/settings';

  static String subjectDetails(int id) => '$subjects/$id';

  static String subjectGroup(int id) => '${subjectDetails(id)}/group';

  static String addSubjectPost(int id) => '${subjectGroup(id)}/new';

  static String quizDetails(int id) => '$quizzes/$id';

  static String quizPreview(int id) => '${quizDetails(id)}/preview';

  static String quizResults(int id) => '${quizDetails(id)}/results';

  static String editLecture(int id) => '$lectures/edit/$id';

  static String subjectResults(int id) => '$results/$id';

  static String gradeEntry(int id) => '${subjectResults(id)}/grade-entry';
}
