class MockStudentResult {
  const MockStudentResult({
    required this.id,
    required this.studentName,
    required this.studentCode,
    required this.subjectCode,
    required this.subjectName,
    required this.assessmentTitle,
    required this.score,
    required this.maxScore,
    required this.statusLabel,
    required this.updatedAt,
  });

  final String id;
  final String studentName;
  final String studentCode;
  final String subjectCode;
  final String subjectName;
  final String assessmentTitle;
  final double score;
  final double maxScore;
  final String statusLabel;
  final DateTime updatedAt;

  double get percentage => maxScore == 0 ? 0 : (score / maxScore) * 100;
}

class MockAnnouncementItem {
  const MockAnnouncementItem({
    required this.id,
    required this.title,
    required this.body,
    required this.subjectCode,
    required this.audienceLabel,
    required this.priorityLabel,
    required this.isPinned,
    required this.publishedAt,
    required this.authorName,
  });

  final String id;
  final String title;
  final String body;
  final String subjectCode;
  final String audienceLabel;
  final String priorityLabel;
  final bool isPinned;
  final DateTime publishedAt;
  final String authorName;
}

class MockStudentDirectoryEntry {
  const MockStudentDirectoryEntry({
    required this.id,
    required this.name,
    required this.code,
    required this.email,
    required this.subjectCode,
    required this.sectionLabel,
    required this.attendanceRate,
    required this.averageScore,
    required this.engagementScore,
    required this.riskLabel,
    required this.lastActiveAt,
  });

  final String id;
  final String name;
  final String code;
  final String email;
  final String subjectCode;
  final String sectionLabel;
  final int attendanceRate;
  final double averageScore;
  final int engagementScore;
  final String riskLabel;
  final DateTime lastActiveAt;
}

class MockAnalyticsKpi {
  const MockAnalyticsKpi({
    required this.label,
    required this.value,
    required this.deltaLabel,
    required this.tone,
  });

  final String label;
  final String value;
  final String deltaLabel;
  final String tone;
}

class MockAnalyticsPoint {
  const MockAnalyticsPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class MockAnalyticsSubjectPulse {
  const MockAnalyticsSubjectPulse({
    required this.subjectCode,
    required this.subjectName,
    required this.healthScore,
    required this.completionRate,
    required this.riskLabel,
  });

  final String subjectCode;
  final String subjectName;
  final int healthScore;
  final int completionRate;
  final String riskLabel;
}

class MockAnalyticsSnapshot {
  const MockAnalyticsSnapshot({
    required this.summary,
    required this.kpis,
    required this.activityTrend,
    required this.completionTrend,
    required this.subjectPulse,
  });

  final String summary;
  final List<MockAnalyticsKpi> kpis;
  final List<MockAnalyticsPoint> activityTrend;
  final List<MockAnalyticsPoint> completionTrend;
  final List<MockAnalyticsSubjectPulse> subjectPulse;
}

class MockGroupPost {
  const MockGroupPost({
    required this.id,
    required this.subjectCode,
    required this.authorName,
    required this.body,
    required this.reactionsCount,
    required this.commentsCount,
    required this.createdAt,
  });

  final String id;
  final String subjectCode;
  final String authorName;
  final String body;
  final int reactionsCount;
  final int commentsCount;
  final DateTime createdAt;
}

class MockMessageThread {
  const MockMessageThread({
    required this.id,
    required this.title,
    required this.participantsLabel,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String participantsLabel;
  final String lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
}
