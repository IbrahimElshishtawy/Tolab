import '../../../../core/models/session_user.dart';

class FacultySettingsDraft {
  const FacultySettingsDraft({
    required this.languageCode,
    required this.phone,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.remindersEnabled,
    required this.quizAlertsEnabled,
    required this.lectureAlertsEnabled,
    required this.themeMode,
    required this.compactMode,
    required this.coursePublishBehavior,
    required this.attendancePolicy,
    required this.quizRule,
    required this.assistantCanEditContent,
    required this.assistantCanPublishPosts,
    required this.assistantCanManageGrades,
    required this.assistantScopeLabel,
    required this.assignmentWeight,
    required this.midtermWeight,
    required this.oralWeight,
    required this.attendanceWeight,
    required this.finalWeight,
  });

  final String languageCode;
  final String phone;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool remindersEnabled;
  final bool quizAlertsEnabled;
  final bool lectureAlertsEnabled;
  final String themeMode;
  final bool compactMode;
  final String coursePublishBehavior;
  final String attendancePolicy;
  final String quizRule;
  final bool assistantCanEditContent;
  final bool assistantCanPublishPosts;
  final bool assistantCanManageGrades;
  final String assistantScopeLabel;
  final double assignmentWeight;
  final double midtermWeight;
  final double oralWeight;
  final double attendanceWeight;
  final double finalWeight;

  double get totalWeight =>
      assignmentWeight +
      midtermWeight +
      oralWeight +
      attendanceWeight +
      finalWeight;

  factory FacultySettingsDraft.fromUser(SessionUser user) {
    final isArabic = user.language.toLowerCase() == 'ar';
    return FacultySettingsDraft(
      languageCode: isArabic ? 'ar' : 'en',
      phone: user.phone ?? '',
      pushEnabled: user.notificationEnabled,
      emailEnabled: true,
      remindersEnabled: true,
      quizAlertsEnabled: true,
      lectureAlertsEnabled: true,
      themeMode: 'system',
      compactMode: true,
      coursePublishBehavior: 'Require review before publish',
      attendancePolicy: 'Warn below 75% attendance',
      quizRule: 'Allow one graded attempt',
      assistantCanEditContent: user.isDoctor,
      assistantCanPublishPosts: user.isDoctor,
      assistantCanManageGrades: false,
      assistantScopeLabel: user.isDoctor
          ? 'Assistant can operate inside assigned sections only.'
          : 'Assistant scope is limited to assigned teaching activities.',
      assignmentWeight: 20,
      midtermWeight: 25,
      oralWeight: 10,
      attendanceWeight: 10,
      finalWeight: 35,
    );
  }
}

String? validateFacultySettings(FacultySettingsDraft draft) {
  if (draft.totalWeight.round() != 100) {
    return 'Academic weight distribution must total 100%.';
  }
  if (draft.phone.trim().isEmpty) {
    return 'Add a contact phone for operational follow-up.';
  }
  return null;
}
