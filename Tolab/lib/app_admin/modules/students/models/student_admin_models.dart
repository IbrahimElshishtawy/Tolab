class StudentAdminRecord {
  const StudentAdminRecord({
    required this.id,
    required this.nationalId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.department,
    required this.batch,
    required this.academicLevel,
    required this.section,
    required this.status,
    required this.advisorName,
    required this.termGpa,
    required this.cumulativeGpa,
    required this.attendanceRate,
    required this.subjectActivityRate,
    required this.doctorInteractionRate,
    required this.earnedCreditHours,
    required this.remainingCreditHours,
    required this.totalCreditHours,
    required this.quizzesTaken,
    required this.examsTaken,
    required this.lecturesAttended,
    required this.totalLectures,
    required this.appSessionsThisWeek,
    required this.messagesWithDoctors,
    required this.lastActiveLabel,
    required this.registrationWindowLabel,
    required this.registrationAccessSent,
    required this.overallGrade,
    required this.permissions,
    required this.activeCourses,
    required this.completedCourses,
    required this.timeline,
    required this.engagementTrend,
  });

  final String id;
  final String nationalId;
  final String fullName;
  final String email;
  final String phone;
  final String department;
  final String batch;
  final String academicLevel;
  final String section;
  final String status;
  final String advisorName;
  final double termGpa;
  final double cumulativeGpa;
  final double attendanceRate;
  final double subjectActivityRate;
  final double doctorInteractionRate;
  final int earnedCreditHours;
  final int remainingCreditHours;
  final int totalCreditHours;
  final int quizzesTaken;
  final int examsTaken;
  final int lecturesAttended;
  final int totalLectures;
  final int appSessionsThisWeek;
  final int messagesWithDoctors;
  final String lastActiveLabel;
  final String registrationWindowLabel;
  final bool registrationAccessSent;
  final String overallGrade;
  final List<StudentPermission> permissions;
  final List<StudentCourseProgress> activeCourses;
  final List<StudentCourseProgress> completedCourses;
  final List<StudentTimelineEvent> timeline;
  final List<StudentTrendPoint> engagementTrend;

  double get graduationProgress =>
      totalCreditHours == 0 ? 0 : earnedCreditHours / totalCreditHours;

  double get currentTermProgress {
    if (activeCourses.isEmpty) return 0;
    final total = activeCourses.fold<double>(
      0,
      (sum, course) => sum + course.progress,
    );
    return total / activeCourses.length;
  }

  bool get isAtRisk =>
      cumulativeGpa < 2.5 || attendanceRate < 75 || status == 'Watchlist';
}

class StudentPermission {
  const StudentPermission({
    required this.title,
    required this.description,
    required this.enabled,
  });

  final String title;
  final String description;
  final bool enabled;
}

class StudentCourseProgress {
  const StudentCourseProgress({
    required this.code,
    required this.title,
    required this.instructor,
    required this.credits,
    required this.progress,
    required this.attendanceRate,
    required this.currentMark,
    required this.status,
  });

  final String code;
  final String title;
  final String instructor;
  final int credits;
  final double progress;
  final double attendanceRate;
  final double currentMark;
  final String status;
}

class StudentTimelineEvent {
  const StudentTimelineEvent({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.kind,
    required this.emphasis,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String kind;
  final String emphasis;
}

class StudentTrendPoint {
  const StudentTrendPoint({required this.label, required this.value});

  final String label;
  final double value;
}
