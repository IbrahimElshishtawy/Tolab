import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/models/content_models.dart';
import '../../../../mock/mock_portal_models.dart';
import '../../../../models/doctor_assistant_models.dart';

class TasksWorkspaceData {
  const TasksWorkspaceData({
    required this.metrics,
    required this.quickActions,
    required this.tasks,
    required this.attentionItems,
    required this.recentActivity,
    required this.studentAttention,
    required this.quickInsights,
    required this.upcomingDeadlines,
    required this.completionTrend,
    required this.totalSubmitted,
    required this.totalPending,
    required this.submissionRate,
    required this.healthLabel,
    required this.healthTone,
    required this.healthSummary,
  });

  final List<WorkspaceOverviewMetric> metrics;
  final List<WorkspaceQuickAction> quickActions;
  final List<TaskWorkspaceTask> tasks;
  final List<TaskWorkspaceAttentionItem> attentionItems;
  final List<TaskWorkspaceActivityItem> recentActivity;
  final List<TaskWorkspaceStudentAlert> studentAttention;
  final List<String> quickInsights;
  final List<TaskWorkspaceDeadlineItem> upcomingDeadlines;
  final List<TaskWorkspaceTrendPoint> completionTrend;
  final int totalSubmitted;
  final int totalPending;
  final double submissionRate;
  final String healthLabel;
  final String healthTone;
  final String healthSummary;
}

class TaskWorkspaceTask {
  const TaskWorkspaceTask({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.subjectLabel,
    required this.scopeLabel,
    required this.deadlineLabel,
    required this.statusLabel,
    required this.statusTone,
    required this.submissionsCount,
    required this.pendingStudentsCount,
    required this.totalStudents,
    required this.needsReviewCount,
    required this.completionRatio,
    required this.healthLabel,
    required this.healthTone,
    required this.quickInsight,
    required this.accentColor,
    required this.isPublished,
    required this.dueAt,
  });

  final int id;
  final int subjectId;
  final String title;
  final String subjectLabel;
  final String scopeLabel;
  final String deadlineLabel;
  final String statusLabel;
  final String statusTone;
  final int submissionsCount;
  final int pendingStudentsCount;
  final int totalStudents;
  final int needsReviewCount;
  final double completionRatio;
  final String healthLabel;
  final String healthTone;
  final String quickInsight;
  final Color accentColor;
  final bool isPublished;
  final DateTime? dueAt;
}

class TaskWorkspaceAttentionItem {
  const TaskWorkspaceAttentionItem({
    required this.title,
    required this.subtitle,
    required this.caption,
    required this.tone,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String caption;
  final String tone;
  final IconData icon;
}

class TaskWorkspaceActivityItem {
  const TaskWorkspaceActivityItem({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.tone,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String tone;
  final IconData icon;
}

class TaskWorkspaceStudentAlert {
  const TaskWorkspaceStudentAlert({
    required this.name,
    required this.subjectCode,
    required this.reason,
    required this.caption,
    required this.tone,
  });

  final String name;
  final String subjectCode;
  final String reason;
  final String caption;
  final String tone;
}

class TaskWorkspaceDeadlineItem {
  const TaskWorkspaceDeadlineItem({
    required this.title,
    required this.subjectLabel,
    required this.deadlineLabel,
    required this.pendingStudentsCount,
    required this.tone,
  });

  final String title;
  final String subjectLabel;
  final String deadlineLabel;
  final int pendingStudentsCount;
  final String tone;
}

class TaskWorkspaceTrendPoint {
  const TaskWorkspaceTrendPoint({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final double value;
  final String tone;
}

TasksWorkspaceData buildTasksWorkspaceData({
  required List<TaskModel> tasks,
  required List<TeachingSubject> subjects,
  required List<MockStudentResult> results,
  required List<MockAnnouncementItem> announcements,
  required List<MockStudentDirectoryEntry> students,
  required List<MockGroupPost> groupPosts,
  required List<WorkspaceNotificationItem> notifications,
}) {
  final subjectById = <int, TeachingSubject>{
    for (final subject in subjects) subject.id: subject,
  };
  final now = DateTime(2026, 4, 23, 12);
  final enrichedTasks = tasks
      .map(
        (task) => _buildEnrichedTask(
          task: task,
          subject: subjectById[task.subjectId],
          results: results,
          now: now,
        ),
      )
      .toList(growable: false);

  final totalStudents = subjects.fold<int>(
    0,
    (sum, subject) => sum + subject.studentCount,
  );
  final activeStudents = subjects.fold<int>(
    0,
    (sum, subject) =>
        sum + (subject.studentCount * max(subject.progress, 0.58)).round(),
  );
  final totalSubmitted = enrichedTasks.fold<int>(
    0,
    (sum, task) => sum + task.submissionsCount,
  );
  final totalPending = enrichedTasks.fold<int>(
    0,
    (sum, task) => sum + task.pendingStudentsCount,
  );
  final totalAssignable = enrichedTasks.fold<int>(
    0,
    (sum, task) => sum + task.totalStudents,
  );
  final double submissionRate = totalAssignable == 0
      ? 0.0
      : totalSubmitted / totalAssignable;
  final reviewCount = enrichedTasks.fold<int>(
    0,
    (sum, task) => sum + task.needsReviewCount,
  );

  final attentionItems = _buildAttentionItems(
    tasks: enrichedTasks,
    notifications: notifications,
    now: now,
  );
  final recentActivity = _buildRecentActivity(
    results: results,
    announcements: announcements,
    groupPosts: groupPosts,
    notifications: notifications,
    now: now,
  );
  final studentAttention = _buildStudentAttention(students);
  final upcomingDeadlines =
      enrichedTasks.where((task) => task.dueAt != null).toList()
        ..sort((left, right) => left.dueAt!.compareTo(right.dueAt!));
  final healthTone = attentionItems.isEmpty
      ? 'success'
      : attentionItems.length >= 3 ||
            enrichedTasks.any((task) => task.healthTone == 'danger')
      ? 'danger'
      : 'warning';
  final healthLabel = switch (healthTone) {
    'success' => 'On Track',
    'danger' => 'Overdue Risk',
    _ => 'Needs Attention',
  };

  final quickInsights = <String>[
    if (totalPending > 0) '$totalPending students still have open submissions.',
    if (reviewCount > 0) '$reviewCount submissions are waiting for review.',
    if (upcomingDeadlines.isNotEmpty)
      '${upcomingDeadlines.first.title} closes next for ${upcomingDeadlines.first.subjectLabel}.',
    if (studentAttention.isNotEmpty)
      '${studentAttention.first.name} needs follow-up on ${studentAttention.first.subjectCode}.',
  ].take(4).toList(growable: false);

  return TasksWorkspaceData(
    metrics: [
      WorkspaceOverviewMetric(
        label: 'Total students',
        value: '$totalStudents',
        caption: 'Across all active teaching subjects',
        icon: Icons.groups_rounded,
        color: const Color(0xFF2563EB),
      ),
      WorkspaceOverviewMetric(
        label: 'Active students',
        value: '$activeStudents',
        caption: 'Students showing current engagement signals',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF14B8A6),
      ),
      WorkspaceOverviewMetric(
        label: 'Submission rate',
        value: '${(submissionRate * 100).round()}%',
        caption: '$totalSubmitted received across live task windows',
        icon: Icons.assignment_turned_in_rounded,
        color: const Color(0xFFF59E0B),
      ),
      WorkspaceOverviewMetric(
        label: 'Pending submissions',
        value: '$totalPending',
        caption: 'Students still missing task delivery',
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFF43F5E),
      ),
    ],
    quickActions: const [
      WorkspaceQuickAction(
        title: 'Add Quiz',
        subtitle: 'Launch a graded or timed assessment',
        route: '/workspace/quizzes',
        icon: Icons.quiz_rounded,
      ),
      WorkspaceQuickAction(
        title: 'Add Lecture',
        subtitle: 'Publish the next lecture block',
        route: '/workspace/lectures',
        icon: Icons.menu_book_rounded,
      ),
      WorkspaceQuickAction(
        title: 'Add Announcement',
        subtitle: 'Broadcast urgent course updates',
        route: '/workspace/announcements',
        icon: Icons.campaign_rounded,
      ),
      WorkspaceQuickAction(
        title: 'View Students',
        subtitle: 'Open student follow-up and risk views',
        route: '/workspace/students',
        icon: Icons.school_rounded,
      ),
      WorkspaceQuickAction(
        title: 'Open Group',
        subtitle: 'Jump into course communication threads',
        route: '/workspace/announcements',
        icon: Icons.forum_rounded,
      ),
    ],
    tasks: enrichedTasks,
    attentionItems: attentionItems,
    recentActivity: recentActivity,
    studentAttention: studentAttention,
    quickInsights: quickInsights,
    upcomingDeadlines: upcomingDeadlines
        .take(3)
        .map(
          (task) => TaskWorkspaceDeadlineItem(
            title: task.title,
            subjectLabel: task.subjectLabel,
            deadlineLabel: task.deadlineLabel,
            pendingStudentsCount: task.pendingStudentsCount,
            tone: task.healthTone,
          ),
        )
        .toList(growable: false),
    completionTrend: enrichedTasks
        .take(4)
        .map(
          (task) => TaskWorkspaceTrendPoint(
            label: task.subjectLabel,
            value: task.completionRatio,
            tone: task.healthTone,
          ),
        )
        .toList(growable: false),
    totalSubmitted: totalSubmitted,
    totalPending: totalPending,
    submissionRate: submissionRate,
    healthLabel: healthLabel,
    healthTone: healthTone,
    healthSummary: attentionItems.isEmpty
        ? 'Publishing and submissions are moving cleanly across the current task set.'
        : '${attentionItems.length} items still need academic follow-up before the next deadline cycle.',
  );
}

TaskWorkspaceTask _buildEnrichedTask({
  required TaskModel task,
  required TeachingSubject? subject,
  required List<MockStudentResult> results,
  required DateTime now,
}) {
  final totalStudents = subject?.studentCount ?? 0;
  final matchingTasks =
      subject?.tasks
          .where((candidate) => candidate.title == task.title)
          .toList(growable: false) ??
      const <TeachingTask>[];
  final rawTask = matchingTasks.isEmpty ? null : matchingTasks.first;
  final percent = _parsePercent(rawTask?.progressLabel);
  final submissionsCount = percent == null
      ? task.isPublished
            ? min(totalStudents, max(0, totalStudents ~/ 3))
            : 0
      : ((totalStudents * percent) / 100).round();
  final pendingStudentsCount = max(0, totalStudents - submissionsCount);
  final matchingResults = results
      .where((result) {
        return result.subjectName == subject?.name &&
            result.assessmentTitle.toLowerCase() == task.title.toLowerCase();
      })
      .toList(growable: false);
  final needsReviewCount = matchingResults
      .where((result) => result.statusLabel.toLowerCase() != 'published')
      .length;
  final statusLabel =
      rawTask?.statusLabel ?? (task.isPublished ? 'Published' : 'Draft');
  final dueAt = _parseDeadlineLabel(task.dueDate);
  final hoursToDeadline = dueAt?.difference(now).inHours;

  final healthTone = !task.isPublished
      ? 'warning'
      : hoursToDeadline != null &&
            hoursToDeadline <= 24 &&
            pendingStudentsCount > 0
      ? 'danger'
      : needsReviewCount > 0
      ? 'warning'
      : 'success';
  final healthLabel = switch (healthTone) {
    'danger' => 'Overdue risk',
    'warning' => 'Needs review',
    _ => 'On track',
  };

  final quickInsight = !task.isPublished
      ? 'Still unpublished, so students cannot submit yet.'
      : needsReviewCount > 0
      ? '$needsReviewCount submission${needsReviewCount == 1 ? '' : 's'} still need grading.'
      : hoursToDeadline != null &&
            hoursToDeadline <= 24 &&
            pendingStudentsCount > 0
      ? '$pendingStudentsCount students still need to submit within 24 hours.'
      : '$submissionsCount of $totalStudents students already submitted.';

  return TaskWorkspaceTask(
    id: task.id,
    subjectId: task.subjectId,
    title: task.title,
    subjectLabel: subject == null
        ? task.ownerName
        : '${subject.code} - ${subject.name}',
    scopeLabel: task.referenceName,
    deadlineLabel: task.dueDate ?? 'No deadline configured',
    statusLabel: statusLabel,
    statusTone: _toneForStatus(statusLabel),
    submissionsCount: submissionsCount,
    pendingStudentsCount: pendingStudentsCount,
    totalStudents: totalStudents,
    needsReviewCount: needsReviewCount,
    completionRatio: totalStudents == 0 ? 0 : submissionsCount / totalStudents,
    healthLabel: healthLabel,
    healthTone: healthTone,
    quickInsight: quickInsight,
    accentColor: subject?.accentColor ?? const Color(0xFF2563EB),
    isPublished: task.isPublished,
    dueAt: dueAt,
  );
}

List<TaskWorkspaceAttentionItem> _buildAttentionItems({
  required List<TaskWorkspaceTask> tasks,
  required List<WorkspaceNotificationItem> notifications,
  required DateTime now,
}) {
  final items = <TaskWorkspaceAttentionItem>[];
  for (final task in tasks) {
    final hoursToDeadline = task.dueAt?.difference(now).inHours;
    if (!task.isPublished) {
      items.add(
        TaskWorkspaceAttentionItem(
          title: task.title,
          subtitle: 'Task is still unpublished',
          caption:
              'Students will not see this task until it is published from the builder.',
          tone: 'warning',
          icon: Icons.visibility_off_rounded,
        ),
      );
    }
    if (hoursToDeadline != null &&
        hoursToDeadline <= 24 &&
        task.pendingStudentsCount > 0) {
      items.add(
        TaskWorkspaceAttentionItem(
          title: task.title,
          subtitle: 'Deadline is within 24 hours',
          caption:
              '${task.pendingStudentsCount} students are still pending submission before the window closes.',
          tone: 'danger',
          icon: Icons.access_time_filled_rounded,
        ),
      );
    }
    if (task.needsReviewCount > 0) {
      items.add(
        TaskWorkspaceAttentionItem(
          title: task.title,
          subtitle: 'Submissions need review',
          caption:
              '${task.needsReviewCount} submission${task.needsReviewCount == 1 ? '' : 's'} still need marking or release review.',
          tone: 'warning',
          icon: Icons.rate_review_rounded,
        ),
      );
    }
  }

  for (final notification in notifications.take(2)) {
    if (notification.statusLabel.toLowerCase() == 'pending') {
      items.add(
        TaskWorkspaceAttentionItem(
          title: notification.title,
          subtitle: notification.courseLabel,
          caption: notification.body,
          tone: 'primary',
          icon: notification.icon,
        ),
      );
    }
  }

  return items.take(5).toList(growable: false);
}

List<TaskWorkspaceActivityItem> _buildRecentActivity({
  required List<MockStudentResult> results,
  required List<MockAnnouncementItem> announcements,
  required List<MockGroupPost> groupPosts,
  required List<WorkspaceNotificationItem> notifications,
  required DateTime now,
}) {
  final items = <MapEntry<DateTime, TaskWorkspaceActivityItem>>[];

  for (var index = 0; index < notifications.length; index++) {
    final notification = notifications[index];
    items.add(
      MapEntry(
        now.subtract(Duration(minutes: index * 25)),
        TaskWorkspaceActivityItem(
          title: notification.title,
          subtitle: notification.body,
          timeLabel: notification.timeLabel,
          tone: notification.isRead ? 'primary' : 'warning',
          icon: notification.icon,
        ),
      ),
    );
  }

  for (final result in results) {
    items.add(
      MapEntry(
        result.updatedAt,
        TaskWorkspaceActivityItem(
          title: '${result.studentName} updated ${result.assessmentTitle}',
          subtitle: '${result.subjectCode} - ${result.statusLabel}',
          timeLabel: _relativeTime(result.updatedAt, now),
          tone: result.statusLabel.toLowerCase() == 'needs review'
              ? 'warning'
              : 'success',
          icon: Icons.assignment_turned_in_rounded,
        ),
      ),
    );
  }

  for (final announcement in announcements) {
    items.add(
      MapEntry(
        announcement.publishedAt,
        TaskWorkspaceActivityItem(
          title: announcement.title,
          subtitle:
              '${announcement.subjectCode} - ${announcement.audienceLabel}',
          timeLabel: _relativeTime(announcement.publishedAt, now),
          tone: announcement.priorityLabel.toLowerCase() == 'urgent'
              ? 'danger'
              : 'primary',
          icon: Icons.campaign_rounded,
        ),
      ),
    );
  }

  for (final post in groupPosts) {
    items.add(
      MapEntry(
        post.createdAt,
        TaskWorkspaceActivityItem(
          title: 'New student interaction in ${post.subjectCode}',
          subtitle: '${post.authorName} - ${post.commentsCount} replies',
          timeLabel: _relativeTime(post.createdAt, now),
          tone: 'primary',
          icon: Icons.forum_rounded,
        ),
      ),
    );
  }

  items.sort((left, right) => right.key.compareTo(left.key));
  return items.map((item) => item.value).take(6).toList(growable: false);
}

List<TaskWorkspaceStudentAlert> _buildStudentAttention(
  List<MockStudentDirectoryEntry> students,
) {
  final severity = <String, int>{
    'high risk': 3,
    'watch': 2,
    'stable': 1,
    'healthy': 0,
  };
  final sorted = List<MockStudentDirectoryEntry>.from(students)
    ..sort((left, right) {
      final leftWeight = severity[left.riskLabel.toLowerCase()] ?? 0;
      final rightWeight = severity[right.riskLabel.toLowerCase()] ?? 0;
      final compare = rightWeight.compareTo(leftWeight);
      if (compare != 0) {
        return compare;
      }
      return left.engagementScore.compareTo(right.engagementScore);
    });

  return sorted
      .take(3)
      .map((student) {
        final tone = student.riskLabel.toLowerCase().contains('high')
            ? 'danger'
            : student.engagementScore < 60
            ? 'warning'
            : 'primary';
        return TaskWorkspaceStudentAlert(
          name: student.name,
          subjectCode: student.subjectCode,
          reason:
              '${student.riskLabel} - attendance ${student.attendanceRate}% - engagement ${student.engagementScore}',
          caption:
              'Last active ${_relativeTime(student.lastActiveAt, DateTime(2026, 4, 23, 12))}',
          tone: tone,
        );
      })
      .toList(growable: false);
}

int? _parsePercent(String? label) {
  final match = RegExp(r'(\d{1,3})%').firstMatch(label ?? '');
  return int.tryParse(match?.group(1) ?? '');
}

String _toneForStatus(String statusLabel) {
  final normalized = statusLabel.toLowerCase();
  if (normalized.contains('published') || normalized.contains('live')) {
    return 'success';
  }
  if (normalized.contains('draft')) {
    return 'warning';
  }
  if (normalized.contains('pending') || normalized.contains('scheduled')) {
    return 'primary';
  }
  return 'primary';
}

DateTime? _parseDeadlineLabel(String? label) {
  if (label == null || label.isEmpty) {
    return null;
  }
  final match = RegExp(
    r'(?:Due\s+)?(?:[A-Za-z]{3}\s+)?(\d{1,2})\s+([A-Za-z]{3})',
    caseSensitive: false,
  ).firstMatch(label);
  if (match == null) {
    return null;
  }
  final day = int.tryParse(match.group(1) ?? '');
  final month = _monthNumber(match.group(2));
  if (day == null || month == null) {
    return null;
  }
  return DateTime(2026, month, day, 23, 59);
}

int? _monthNumber(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'jan':
      return 1;
    case 'feb':
      return 2;
    case 'mar':
      return 3;
    case 'apr':
      return 4;
    case 'may':
      return 5;
    case 'jun':
      return 6;
    case 'jul':
      return 7;
    case 'aug':
      return 8;
    case 'sep':
      return 9;
    case 'oct':
      return 10;
    case 'nov':
      return 11;
    case 'dec':
      return 12;
  }
  return null;
}

String _relativeTime(DateTime value, DateTime now) {
  final difference = now.difference(value);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} hr ago';
  }
  return '${difference.inDays} day ago';
}
