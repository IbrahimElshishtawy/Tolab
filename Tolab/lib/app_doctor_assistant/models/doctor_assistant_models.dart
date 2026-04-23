import 'package:flutter/material.dart';

class WorkspaceOverviewMetric {
  const WorkspaceOverviewMetric({
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

class WorkspaceQuickAction {
  const WorkspaceQuickAction({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
}

class WorkspaceUpcomingItem {
  const WorkspaceUpcomingItem({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.statusLabel,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String statusLabel;
  final IconData icon;
}

class TeachingLecture {
  const TeachingLecture({
    required this.id,
    required this.title,
    required this.audience,
    required this.dayLabel,
    required this.timeLabel,
    required this.room,
    required this.statusLabel,
    required this.weekLabel,
    this.description,
    this.startsAtIso,
    this.endsAtIso,
    this.deliveryMode,
    this.meetingUrl,
    this.locationLabel,
    this.attachmentLabel,
    this.publisherName,
  });

  final String id;
  final String title;
  final String audience;
  final String dayLabel;
  final String timeLabel;
  final String room;
  final String statusLabel;
  final String weekLabel;
  final String? description;
  final String? startsAtIso;
  final String? endsAtIso;
  final String? deliveryMode;
  final String? meetingUrl;
  final String? locationLabel;
  final String? attachmentLabel;
  final String? publisherName;
}

class TeachingSection {
  const TeachingSection({
    required this.id,
    required this.title,
    required this.assistantName,
    required this.dayLabel,
    required this.timeLabel,
    required this.room,
    required this.statusLabel,
    required this.groupLabel,
    this.description,
    this.scheduledAtIso,
    this.durationMinutes,
    this.deliveryMode,
    this.locationLabel,
    this.meetingLink,
    this.notes,
    this.expectedStudents,
    this.addedToSchedule = false,
    this.sendNotification = false,
    this.attachmentName,
  });

  final String id;
  final String title;
  final String assistantName;
  final String dayLabel;
  final String timeLabel;
  final String room;
  final String statusLabel;
  final String groupLabel;
  final String? description;
  final String? scheduledAtIso;
  final int? durationMinutes;
  final String? deliveryMode;
  final String? locationLabel;
  final String? meetingLink;
  final String? notes;
  final int? expectedStudents;
  final bool addedToSchedule;
  final bool sendNotification;
  final String? attachmentName;
}

class TeachingQuiz {
  const TeachingQuiz({
    required this.id,
    required this.title,
    required this.windowLabel,
    required this.statusLabel,
    required this.attemptsLabel,
    required this.scopeLabel,
    this.description,
    this.startAtIso,
    this.endAtIso,
    this.durationMinutes,
    this.attemptsAllowed,
    this.totalMarks,
    this.questionCount,
    this.audienceLabel,
    this.totalStudents,
    this.enteredStudents,
    this.completedStudents,
    this.passRate,
    this.averageScore,
    this.liveParticipants,
    this.attachmentName,
    this.questions = const <TeachingQuizQuestion>[],
    this.submissions = const <TeachingQuizSubmission>[],
  });

  final String id;
  final String title;
  final String windowLabel;
  final String statusLabel;
  final String attemptsLabel;
  final String scopeLabel;
  final String? description;
  final String? startAtIso;
  final String? endAtIso;
  final int? durationMinutes;
  final int? attemptsAllowed;
  final int? totalMarks;
  final int? questionCount;
  final String? audienceLabel;
  final int? totalStudents;
  final int? enteredStudents;
  final int? completedStudents;
  final double? passRate;
  final double? averageScore;
  final int? liveParticipants;
  final String? attachmentName;
  final List<TeachingQuizQuestion> questions;
  final List<TeachingQuizSubmission> submissions;
}

class TeachingQuizQuestion {
  const TeachingQuizQuestion({
    required this.id,
    required this.prompt,
    required this.type,
    this.options = const <String>[],
    this.correctAnswers = const <String>[],
    required this.marks,
    this.isRequired = true,
  });

  final String id;
  final String prompt;
  final String type;
  final List<String> options;
  final List<String> correctAnswers;
  final int marks;
  final bool isRequired;
}

class TeachingQuizSubmission {
  const TeachingQuizSubmission({
    required this.studentName,
    required this.studentCode,
    required this.statusLabel,
    this.score,
    this.startedAtIso,
    this.submittedAtIso,
    this.progress = 0,
  });

  final String studentName;
  final String studentCode;
  final String statusLabel;
  final double? score;
  final String? startedAtIso;
  final String? submittedAtIso;
  final double progress;
}

class TeachingTask {
  const TeachingTask({
    required this.id,
    required this.title,
    required this.deadlineLabel,
    required this.statusLabel,
    required this.progressLabel,
    required this.scopeLabel,
  });

  final String id;
  final String title;
  final String deadlineLabel;
  final String statusLabel;
  final String progressLabel;
  final String scopeLabel;
}

class TeachingSubject {
  const TeachingSubject({
    required this.id,
    required this.code,
    required this.name,
    required this.department,
    required this.academicTerm,
    required this.description,
    required this.studentCount,
    required this.sectionCount,
    required this.progress,
    required this.accentColor,
    required this.lectures,
    required this.sections,
    required this.quizzes,
    required this.tasks,
  });

  final int id;
  final String code;
  final String name;
  final String department;
  final String academicTerm;
  final String description;
  final int studentCount;
  final int sectionCount;
  final double progress;
  final Color accentColor;
  final List<TeachingLecture> lectures;
  final List<TeachingSection> sections;
  final List<TeachingQuiz> quizzes;
  final List<TeachingTask> tasks;
}

class WorkspaceNotificationItem {
  const WorkspaceNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.statusLabel,
    required this.courseLabel,
    required this.isRead,
    required this.icon,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final String statusLabel;
  final String courseLabel;
  final bool isRead;
  final IconData icon;
}

class WorkspaceProfileSnapshot {
  const WorkspaceProfileSnapshot({
    required this.roleHeadline,
    required this.roleSummary,
    required this.focusAreas,
    required this.officeHours,
    required this.locationLabel,
    required this.phoneLabel,
    required this.primaryStats,
  });

  final String roleHeadline;
  final String roleSummary;
  final List<String> focusAreas;
  final String officeHours;
  final String locationLabel;
  final String phoneLabel;
  final List<WorkspaceOverviewMetric> primaryStats;
}

class WorkspaceHomeSnapshot {
  const WorkspaceHomeSnapshot({
    required this.dateLabel,
    required this.metrics,
    required this.upcoming,
    required this.quickActions,
  });

  final String dateLabel;
  final List<WorkspaceOverviewMetric> metrics;
  final List<WorkspaceUpcomingItem> upcoming;
  final List<WorkspaceQuickAction> quickActions;
}
