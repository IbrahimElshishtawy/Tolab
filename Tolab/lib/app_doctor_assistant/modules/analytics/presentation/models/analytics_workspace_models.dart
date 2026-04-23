import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/models/session_user.dart';
import '../../../../mock/doctor_assistant_mock_repository.dart';
import '../../../../mock/mock_portal_models.dart';

class AnalyticsWorkspaceData {
  const AnalyticsWorkspaceData({
    required this.summary,
    required this.kpis,
    required this.alerts,
    required this.subjectInsights,
    required this.topPerformers,
    required this.studentsNeedingAttention,
    required this.distribution,
    required this.successCount,
    required this.failureCount,
    required this.periodInsights,
  });

  final String summary;
  final List<AnalyticsKpiItem> kpis;
  final List<AnalyticsAlertItem> alerts;
  final List<AnalyticsSubjectInsight> subjectInsights;
  final List<AnalyticsStudentInsight> topPerformers;
  final List<AnalyticsStudentInsight> studentsNeedingAttention;
  final List<AnalyticsDistributionBucket> distribution;
  final int successCount;
  final int failureCount;
  final List<AnalyticsPeriodInsight> periodInsights;
}

class AnalyticsKpiItem {
  const AnalyticsKpiItem({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;
}

class AnalyticsAlertItem {
  const AnalyticsAlertItem({
    required this.title,
    required this.description,
    required this.severity,
    required this.icon,
  });

  final String title;
  final String description;
  final AnalyticsSeverity severity;
  final IconData icon;
}

class AnalyticsSubjectInsight {
  const AnalyticsSubjectInsight({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.averageGrade,
    required this.attendanceTrend,
    required this.engagementScore,
    required this.completionRate,
    required this.riskLevel,
    required this.healthScore,
    required this.quizParticipation,
    required this.pendingReviewCount,
    required this.route,
  });

  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final double averageGrade;
  final int attendanceTrend;
  final int engagementScore;
  final int completionRate;
  final String riskLevel;
  final int healthScore;
  final int quizParticipation;
  final int pendingReviewCount;
  final String route;
}

class AnalyticsStudentInsight {
  const AnalyticsStudentInsight({
    required this.name,
    required this.code,
    required this.subjectCode,
    required this.sectionLabel,
    required this.averageScore,
    required this.attendanceRate,
    required this.engagementScore,
    required this.riskLabel,
    required this.lastActiveLabel,
  });

  final String name;
  final String code;
  final String subjectCode;
  final String sectionLabel;
  final double averageScore;
  final int attendanceRate;
  final int engagementScore;
  final String riskLabel;
  final String lastActiveLabel;
}

class AnalyticsDistributionBucket {
  const AnalyticsDistributionBucket({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

class AnalyticsPeriodInsight {
  const AnalyticsPeriodInsight({
    required this.label,
    required this.value,
    required this.deltaLabel,
    required this.description,
    required this.color,
  });

  final String label;
  final String value;
  final String deltaLabel;
  final String description;
  final Color color;
}

enum AnalyticsSeverity { low, medium, high }

extension AnalyticsSeverityX on AnalyticsSeverity {
  String get label => switch (this) {
    AnalyticsSeverity.low => 'Observe',
    AnalyticsSeverity.medium => 'Attention',
    AnalyticsSeverity.high => 'Action now',
  };

  Color get color => switch (this) {
    AnalyticsSeverity.low => const Color(0xFF0EA5E9),
    AnalyticsSeverity.medium => const Color(0xFFF59E0B),
    AnalyticsSeverity.high => const Color(0xFFDC2626),
  };
}

AnalyticsWorkspaceData buildAnalyticsWorkspace(
  DoctorAssistantMockRepository repository,
  SessionUser user,
) {
  final subjects = repository.subjectsFor(user);
  final students = repository.studentsFor(user);
  final posts = repository.groupPostsFor(user);
  final results = repository.resultsFor(user);
  final schedule = repository.scheduleFor(user);
  final subjectInsights = subjects
      .map(
        (subject) => _buildSubjectInsight(
          repository: repository,
          user: user,
          subjectId: subject.id,
        ),
      )
      .toList(growable: false)
    ..sort((left, right) => left.healthScore.compareTo(right.healthScore));

  final weightedStudents = students
      .map((student) => _buildStudentInsight(student))
      .toList(growable: false);

  final topPerformers = [...weightedStudents]
    ..sort((left, right) => _studentPower(right).compareTo(_studentPower(left)));
  final weakStudents = [...weightedStudents]
    ..sort((left, right) => _attentionScore(right).compareTo(_attentionScore(left)));

  final averageAttendance = students.isEmpty
      ? 0
      : students.fold<int>(0, (sum, student) => sum + student.attendanceRate) ~/
            students.length;
  final averageGrade = students.isEmpty
      ? 0
      : students.fold<double>(
              0,
              (sum, student) => sum + student.averageScore,
            ) /
            students.length;
  final averageEngagement = students.isEmpty
      ? 0
      : students.fold<int>(
              0,
              (sum, student) => sum + student.engagementScore,
            ) ~/
            students.length;
  final completionRate = subjectInsights.isEmpty
      ? 0
      : subjectInsights.fold<int>(
              0,
              (sum, subject) => sum + subject.completionRate,
            ) ~/
            subjectInsights.length;
  final highRiskCount = students
      .where((student) => student.riskLabel.toLowerCase().contains('high'))
      .length;

  final alerts = <AnalyticsAlertItem>[
    if (highRiskCount > 0)
      AnalyticsAlertItem(
        title: '$highRiskCount students are high risk',
        description:
            'Attendance, grade trend, and engagement dropped below the safe band. Open Students to intervene.',
        severity: AnalyticsSeverity.high,
        icon: Icons.warning_amber_rounded,
      ),
    for (final subject in subjectInsights.where((item) => item.averageGrade < 65))
      AnalyticsAlertItem(
        title: '${subject.subjectCode} success rate is slipping',
        description:
            '${subject.subjectName} is averaging ${subject.averageGrade.toStringAsFixed(1)} with ${subject.pendingReviewCount} grade items still pending.',
        severity: AnalyticsSeverity.high,
        icon: Icons.trending_down_rounded,
      ),
    for (final subject in subjectInsights.where((item) => item.quizParticipation < 70))
      AnalyticsAlertItem(
        title: '${subject.subjectCode} quiz participation is low',
        description:
            'Only ${subject.quizParticipation}% of the cohort entered the latest quiz window.',
        severity: AnalyticsSeverity.medium,
        icon: Icons.quiz_rounded,
      ),
    for (final subject in subjectInsights.where((item) => item.engagementScore < 65))
      AnalyticsAlertItem(
        title: '${subject.subjectCode} interaction is fading',
        description:
            'Discussion and student activity are down. Consider a post, reminder, or tutorial intervention.',
        severity: AnalyticsSeverity.medium,
        icon: Icons.forum_rounded,
      ),
    if (averageAttendance < 80)
      AnalyticsAlertItem(
        title: 'Attendance is below policy threshold',
        description:
            'The monitored cohort is averaging $averageAttendance% attendance across active sections.',
        severity: AnalyticsSeverity.high,
        icon: Icons.how_to_reg_rounded,
      ),
  ];

  final distribution = _buildDistribution(students);
  final successCount =
      students.where((student) => student.averageScore >= 60).length;
  final failureCount = max(0, students.length - successCount);

  final weeklyAttendance = averageAttendance;
  final monthlyActivity = min(100, 48 + (posts.length * 9));
  final gradingProgress = min(
    100,
    subjects.isEmpty
        ? 0
        : subjectInsights.fold<int>(
              0,
              (sum, insight) => sum + (100 - (insight.pendingReviewCount * 8)),
            ) ~/
            subjects.length,
  );
  final quizParticipation = subjectInsights.isEmpty
      ? 0
      : subjectInsights.fold<int>(
              0,
              (sum, insight) => sum + insight.quizParticipation,
            ) ~/
            subjectInsights.length;

  return AnalyticsWorkspaceData(
    summary:
        'Academic health is combining delivery progress, attendance, grading momentum, and course-group activity for the current teaching scope.',
    kpis: [
      AnalyticsKpiItem(
        label: 'Average grade',
        value: '${averageGrade.toStringAsFixed(1)}%',
        caption: 'Across ${results.length} tracked result rows',
        icon: Icons.auto_graph_rounded,
        color: const Color(0xFF2563EB),
      ),
      AnalyticsKpiItem(
        label: 'Attendance health',
        value: '$averageAttendance%',
        caption: 'Current monitored attendance baseline',
        icon: Icons.how_to_reg_rounded,
        color: const Color(0xFF14B8A6),
      ),
      AnalyticsKpiItem(
        label: 'Engagement score',
        value: '$averageEngagement',
        caption: 'Course-group and activity intensity',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFF59E0B),
      ),
      AnalyticsKpiItem(
        label: 'Completion rate',
        value: '$completionRate%',
        caption: '${schedule.length} calendar items and delivery tasks in flow',
        icon: Icons.task_alt_rounded,
        color: const Color(0xFF7C3AED),
      ),
    ],
    alerts: alerts,
    subjectInsights: subjectInsights,
    topPerformers: topPerformers.take(4).toList(growable: false),
    studentsNeedingAttention: weakStudents.take(4).toList(growable: false),
    distribution: distribution,
    successCount: successCount,
    failureCount: failureCount,
    periodInsights: [
      AnalyticsPeriodInsight(
        label: 'Weekly attendance',
        value: '$weeklyAttendance%',
        deltaLabel: weeklyAttendance >= 85 ? '+3 this week' : '-4 this week',
        description:
            'Tracks section and lecture presence to catch attendance pressure before assessment week.',
        color: const Color(0xFF0EA5E9),
      ),
      AnalyticsPeriodInsight(
        label: 'Monthly activity',
        value: '$monthlyActivity',
        deltaLabel: posts.length >= 2 ? '+12 interactions' : '-8 interactions',
        description:
            'Posts, comments, and replies show whether students are still interacting with the course feed.',
        color: const Color(0xFF8B5CF6),
      ),
      AnalyticsPeriodInsight(
        label: 'Grading progress',
        value: '$gradingProgress%',
        deltaLabel: '${subjects.length} subjects monitored',
        description:
            'Balances published marks against draft or review queues so release risk is visible early.',
        color: const Color(0xFF14B8A6),
      ),
      AnalyticsPeriodInsight(
        label: 'Quiz participation',
        value: '$quizParticipation%',
        deltaLabel: '${subjectInsights.where((item) => item.quizParticipation < 70).length} subjects below target',
        description:
            'Shows how many students actually enter quiz windows, not just how many are enrolled.',
        color: const Color(0xFFF97316),
      ),
    ],
  );
}

AnalyticsSubjectInsight _buildSubjectInsight({
  required DoctorAssistantMockRepository repository,
  required SessionUser user,
  required int subjectId,
}) {
  final subject = repository.subjectById(subjectId);
  final subjectResults = repository.subjectResultsById(subjectId, user);
  final relatedStudents = repository
      .studentsFor(user)
      .where((student) => student.subjectCode == subject.code)
      .toList(growable: false);
  final attendance = relatedStudents.isEmpty
      ? 0
      : relatedStudents.fold<int>(
              0,
              (sum, student) => sum + student.attendanceRate,
            ) ~/
            relatedStudents.length;
  final engagement = relatedStudents.isEmpty
      ? 0
      : relatedStudents.fold<int>(
              0,
              (sum, student) => sum + student.engagementScore,
            ) ~/
            relatedStudents.length;
  final completionRate = (subject.progress * 100).round();
  final latestQuiz = subject.quizzes.isEmpty ? null : subject.quizzes.first;
  final quizParticipation = latestQuiz == null || (latestQuiz.totalStudents ?? 0) == 0
      ? completionRate
      : (((latestQuiz.enteredStudents ?? 0) / (latestQuiz.totalStudents ?? 1)) * 100)
            .round();
  final healthScore = ((subjectResults.averageScore * 0.45) +
          (attendance * 0.25) +
          (engagement * 0.15) +
          (completionRate * 0.15))
      .round();
  final attendanceTrend = attendance - (72 + (subjectId % 13));

  return AnalyticsSubjectInsight(
    subjectId: subjectId,
    subjectCode: subject.code,
    subjectName: subject.name,
    averageGrade: subjectResults.averageScore,
    attendanceTrend: attendanceTrend,
    engagementScore: engagement,
    completionRate: completionRate,
    riskLevel: _riskFromMetrics(
      score: subjectResults.averageScore,
      attendance: attendance,
      engagement: engagement,
    ),
    healthScore: healthScore.clamp(0, 100),
    quizParticipation: quizParticipation.clamp(0, 100),
    pendingReviewCount: subjectResults.pendingReviewCount,
    route: '/workspace/subjects/$subjectId',
  );
}

AnalyticsStudentInsight _buildStudentInsight(MockStudentDirectoryEntry student) {
  return AnalyticsStudentInsight(
    name: student.name,
    code: student.code,
    subjectCode: student.subjectCode,
    sectionLabel: student.sectionLabel,
    averageScore: student.averageScore,
    attendanceRate: student.attendanceRate,
    engagementScore: student.engagementScore,
    riskLabel: student.riskLabel,
    lastActiveLabel: _relativeTime(student.lastActiveAt),
  );
}

List<AnalyticsDistributionBucket> _buildDistribution(
  List<MockStudentDirectoryEntry> students,
) {
  final buckets = <String, int>{
    '0-49': 0,
    '50-59': 0,
    '60-69': 0,
    '70-79': 0,
    '80-89': 0,
    '90+': 0,
  };
  for (final student in students) {
    final score = student.averageScore;
    if (score < 50) {
      buckets['0-49'] = buckets['0-49']! + 1;
    } else if (score < 60) {
      buckets['50-59'] = buckets['50-59']! + 1;
    } else if (score < 70) {
      buckets['60-69'] = buckets['60-69']! + 1;
    } else if (score < 80) {
      buckets['70-79'] = buckets['70-79']! + 1;
    } else if (score < 90) {
      buckets['80-89'] = buckets['80-89']! + 1;
    } else {
      buckets['90+'] = buckets['90+']! + 1;
    }
  }

  final colors = <Color>[
    const Color(0xFFDC2626),
    const Color(0xFFF97316),
    const Color(0xFFF59E0B),
    const Color(0xFF0EA5E9),
    const Color(0xFF2563EB),
    const Color(0xFF14B8A6),
  ];

  return buckets.entries
      .toList(growable: false)
      .asMap()
      .entries
      .map(
        (entry) => AnalyticsDistributionBucket(
          label: entry.value.key,
          count: entry.value.value,
          color: colors[entry.key],
        ),
      )
      .toList(growable: false);
}

double _studentPower(AnalyticsStudentInsight student) {
  return (student.averageScore * 0.5) +
      (student.attendanceRate * 0.25) +
      (student.engagementScore * 0.25);
}

double _attentionScore(AnalyticsStudentInsight student) {
  final riskWeight = switch (student.riskLabel.toLowerCase()) {
    'high risk' => 100,
    'watch' => 70,
    'stable' => 35,
    _ => 15,
  };
  return riskWeight +
      (100 - student.averageScore) +
      (100 - student.attendanceRate) +
      (100 - student.engagementScore);
}

String _riskFromMetrics({
  required double score,
  required int attendance,
  required int engagement,
}) {
  if (score < 60 || attendance < 70 || engagement < 55) {
    return 'High Risk';
  }
  if (score < 72 || attendance < 80 || engagement < 68) {
    return 'Watch';
  }
  if (score >= 85 && attendance >= 90 && engagement >= 85) {
    return 'Healthy';
  }
  return 'Stable';
}

String _relativeTime(DateTime time) {
  final now = DateTime(2026, 4, 23, 12);
  final difference = now.difference(time);
  if (difference.inHours < 1) {
    return '${max(1, difference.inMinutes)}m ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours}h ago';
  }
  return '${difference.inDays}d ago';
}
