import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/dashboard_theme_tokens.dart';

Color dashboardToneColor(DashboardThemeTokens tokens, String tone) {
  switch (tone.toLowerCase()) {
    case 'success':
    case 'healthy':
      return tokens.success;
    case 'warning':
    case 'watch':
    case 'medium':
      return tokens.warning;
    case 'danger':
    case 'high':
    case 'at_risk':
      return tokens.danger;
    case 'secondary':
      return tokens.secondary;
    default:
      return tokens.primary;
  }
}

IconData dashboardIconForQuickAction(String icon) {
  switch (icon) {
    case 'lecture':
      return Icons.co_present_rounded;
    case 'section':
      return Icons.widgets_rounded;
    case 'quiz':
      return Icons.quiz_rounded;
    case 'task':
      return Icons.assignment_rounded;
    case 'announcement':
      return Icons.campaign_rounded;
    default:
      return Icons.bolt_rounded;
  }
}

IconData dashboardIconForActionType(String type) {
  switch (type) {
    case 'LECTURE_MISSING':
    case 'SECTION_CONTENT_MISSING':
      return Icons.upload_file_rounded;
    case 'PENDING_GRADING':
      return Icons.grading_rounded;
    case 'MISSING_SUBMISSIONS':
      return Icons.warning_amber_rounded;
    case 'QUIZ_UNPUBLISHED':
      return Icons.quiz_outlined;
    case 'TASK_UNPUBLISHED':
      return Icons.assignment_late_rounded;
    default:
      return Icons.task_alt_rounded;
  }
}

IconData dashboardIconForTimelineType(String type) {
  switch (type) {
    case 'LECTURE':
      return Icons.co_present_rounded;
    case 'SECTION':
      return Icons.science_rounded;
    case 'QUIZ':
      return Icons.quiz_rounded;
    case 'TASK':
      return Icons.assignment_rounded;
    default:
      return Icons.calendar_today_rounded;
  }
}

IconData dashboardIconForActivityType(String type) {
  switch (type) {
    case 'POST':
      return Icons.forum_rounded;
    case 'COMMENT':
      return Icons.mode_comment_rounded;
    case 'MESSAGE':
      return Icons.mark_chat_unread_rounded;
    default:
      return Icons.dynamic_feed_rounded;
  }
}

String dashboardRelativeTime(DateTime? value) {
  if (value == null) {
    return '';
  }

  final now = DateTime.now();
  final difference = now.difference(value);
  if (difference.inMinutes < 1) {
    return 'Just now';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }
  return DateFormat('MMM d').format(value);
}

String dashboardFormattedPercent(double? value) {
  if (value == null) {
    return '--';
  }
  return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}%';
}

List<DashboardTimelineGroup> nonEmptyTimelineGroups(DashboardTimeline timeline) {
  return timeline.groups.where((group) => group.items.isNotEmpty).toList();
}
