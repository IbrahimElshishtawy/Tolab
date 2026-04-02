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
  });

  final String id;
  final String title;
  final String audience;
  final String dayLabel;
  final String timeLabel;
  final String room;
  final String statusLabel;
  final String weekLabel;
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
  });

  final String id;
  final String title;
  final String assistantName;
  final String dayLabel;
  final String timeLabel;
  final String room;
  final String statusLabel;
  final String groupLabel;
}

class TeachingQuiz {
  const TeachingQuiz({
    required this.id,
    required this.title,
    required this.windowLabel,
    required this.statusLabel,
    required this.attemptsLabel,
    required this.scopeLabel,
  });

  final String id;
  final String title;
  final String windowLabel;
  final String statusLabel;
  final String attemptsLabel;
  final String scopeLabel;
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
