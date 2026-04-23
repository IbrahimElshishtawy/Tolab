import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../mock/mock_portal_models.dart';
import '../../../../models/doctor_assistant_models.dart';

class SectionsWorkspaceData {
  const SectionsWorkspaceData({
    required this.metrics,
    required this.quickActions,
    required this.sections,
    required this.upcomingToday,
    required this.needsAttention,
    required this.recentActivity,
    required this.latestSections,
    required this.quickInsights,
    required this.healthLabel,
    required this.healthTone,
    required this.healthSummary,
  });

  final List<WorkspaceOverviewMetric> metrics;
  final List<WorkspaceQuickAction> quickActions;
  final List<SectionWorkspaceItem> sections;
  final List<SectionWorkspaceItem> upcomingToday;
  final List<SectionWorkspaceAlert> needsAttention;
  final List<SectionWorkspaceActivity> recentActivity;
  final List<SectionWorkspaceItem> latestSections;
  final List<String> quickInsights;
  final String healthLabel;
  final String healthTone;
  final String healthSummary;
}

class SectionWorkspaceItem {
  const SectionWorkspaceItem({
    required this.id,
    required this.subjectId,
    required this.subjectLabel,
    required this.subjectCode,
    required this.title,
    required this.assistantName,
    required this.deliveryType,
    required this.locationLabel,
    required this.statusLabel,
    required this.statusTone,
    required this.scheduledAt,
    required this.dateLabel,
    required this.timeLabel,
    required this.durationMinutes,
    required this.expectedStudents,
    required this.accentColor,
    required this.needsLink,
    required this.needsUpdate,
    required this.description,
    this.meetingLink,
    this.notes,
    this.attachmentName,
  });

  final int id;
  final int subjectId;
  final String subjectLabel;
  final String subjectCode;
  final String title;
  final String assistantName;
  final String deliveryType;
  final String locationLabel;
  final String statusLabel;
  final String statusTone;
  final DateTime scheduledAt;
  final String dateLabel;
  final String timeLabel;
  final int durationMinutes;
  final int expectedStudents;
  final Color accentColor;
  final bool needsLink;
  final bool needsUpdate;
  final String description;
  final String? meetingLink;
  final String? notes;
  final String? attachmentName;

  bool get isToday => _sameDay(scheduledAt, _workspaceNow);
  bool get isUpcoming =>
      scheduledAt.isAfter(_workspaceNow) &&
      scheduledAt.isBefore(_workspaceNow.add(const Duration(days: 7)));
  bool get isLive => statusLabel == 'Live';
}

class SectionWorkspaceAlert {
  const SectionWorkspaceAlert({
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

class SectionWorkspaceActivity {
  const SectionWorkspaceActivity({
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

SectionsWorkspaceData buildSectionsWorkspaceData({
  required List<TeachingSubject> subjects,
  required List<WorkspaceNotificationItem> notifications,
  required List<MockAnnouncementItem> announcements,
}) {
  final items = <SectionWorkspaceItem>[];
  for (final subject in subjects) {
    final sectionCount = subject.sections.isEmpty ? 1 : subject.sections.length;
    for (var index = 0; index < subject.sections.length; index++) {
      items.add(
        _buildSectionWorkspaceItem(
          subject: subject,
          section: subject.sections[index],
          fallbackExpectedStudents: (subject.studentCount / sectionCount)
              .ceil(),
          index: index,
        ),
      );
    }
  }

  items.sort((left, right) => left.scheduledAt.compareTo(right.scheduledAt));
  final upcomingToday = items
      .where((item) => item.isToday)
      .toList(growable: false);
  final needsAttention = _buildAttentionItems(items);
  final recentActivity = _buildRecentActivity(
    items: items,
    notifications: notifications,
    announcements: announcements,
  );
  final latestSections = List<SectionWorkspaceItem>.from(items)
    ..sort((left, right) => right.scheduledAt.compareTo(left.scheduledAt));
  final sectionsThisWeek = items
      .where(
        (item) =>
            item.scheduledAt.isAfter(
              _workspaceNow.subtract(const Duration(days: 3)),
            ) &&
            item.scheduledAt.isBefore(
              _workspaceNow.add(const Duration(days: 4)),
            ),
      )
      .length;
  final upcomingWithoutLink = items
      .where(
        (item) => item.needsLink && item.scheduledAt.isAfter(_workspaceNow),
      )
      .length;
  final expectedAttendance = items
      .where((item) => item.scheduledAt.isAfter(_workspaceNow))
      .fold<int>(0, (sum, item) => sum + item.expectedStudents);
  final publishedCount = items
      .where(
        (item) => item.statusLabel == 'Published' || item.statusLabel == 'Live',
      )
      .length;
  final draftCount = items.where((item) => item.statusLabel == 'Draft').length;
  final quickInsights = <String>[
    if (upcomingToday.isNotEmpty)
      '${upcomingToday.length} section${upcomingToday.length == 1 ? '' : 's'} still need active delivery tracking today.',
    if (upcomingWithoutLink > 0)
      '$upcomingWithoutLink online section${upcomingWithoutLink == 1 ? '' : 's'} still need a meeting link.',
    if (latestSections.isNotEmpty)
      'Latest section added: ${latestSections.first.title} for ${latestSections.first.subjectCode}.',
    if (needsAttention.isNotEmpty) needsAttention.first.caption,
  ].take(4).toList(growable: false);

  final healthTone = needsAttention.isEmpty
      ? 'success'
      : needsAttention.any((item) => item.tone == 'danger')
      ? 'danger'
      : 'warning';
  final healthLabel = switch (healthTone) {
    'success' => 'Delivery On Track',
    'danger' => 'Needs Immediate Action',
    _ => 'Watch List',
  };

  return SectionsWorkspaceData(
    metrics: [
      WorkspaceOverviewMetric(
        label: 'Sections this week',
        value: '$sectionsThisWeek',
        caption: 'Live and upcoming section slots in the weekly run',
        icon: Icons.calendar_view_week_rounded,
        color: const Color(0xFF2563EB),
      ),
      WorkspaceOverviewMetric(
        label: 'Upcoming today',
        value: '${upcomingToday.length}',
        caption: 'Sections that still require monitoring today',
        icon: Icons.today_rounded,
        color: const Color(0xFF14B8A6),
      ),
      WorkspaceOverviewMetric(
        label: 'Without links',
        value: '$upcomingWithoutLink',
        caption: 'Online section rooms still missing access details',
        icon: Icons.link_off_rounded,
        color: const Color(0xFFF59E0B),
      ),
      WorkspaceOverviewMetric(
        label: 'Expected attendance',
        value: '$expectedAttendance',
        caption: 'Students expected across upcoming section delivery',
        icon: Icons.groups_rounded,
        color: const Color(0xFF7C3AED),
      ),
      WorkspaceOverviewMetric(
        label: 'Published',
        value: '$publishedCount',
        caption: 'Sections already visible to learners',
        icon: Icons.publish_rounded,
        color: const Color(0xFF0EA5E9),
      ),
      WorkspaceOverviewMetric(
        label: 'Draft',
        value: '$draftCount',
        caption: 'Items still being prepared inside the builder',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFFF43F5E),
      ),
    ],
    quickActions: const [
      WorkspaceQuickAction(
        title: 'Open schedule',
        subtitle: 'Check section timing against the calendar',
        route: '/workspace/schedule',
        icon: Icons.calendar_month_rounded,
      ),
      WorkspaceQuickAction(
        title: 'View students',
        subtitle: 'Open cohort and attendance follow-up',
        route: '/workspace/students',
        icon: Icons.school_rounded,
      ),
      WorkspaceQuickAction(
        title: 'Send announcement',
        subtitle: 'Push a section reminder or update',
        route: '/workspace/announcements',
        icon: Icons.campaign_rounded,
      ),
      WorkspaceQuickAction(
        title: 'Create quiz',
        subtitle: 'Launch assessment right after the section',
        route: '/workspace/quizzes',
        icon: Icons.quiz_rounded,
      ),
    ],
    sections: items,
    upcomingToday: upcomingToday,
    needsAttention: needsAttention,
    recentActivity: recentActivity,
    latestSections: latestSections.take(3).toList(growable: false),
    quickInsights: quickInsights,
    healthLabel: healthLabel,
    healthTone: healthTone,
    healthSummary: needsAttention.isEmpty
        ? 'Section publishing, delivery, and access details are aligned across the current mock timetable.'
        : '${needsAttention.length} section item${needsAttention.length == 1 ? '' : 's'} still need action before the next delivery cycle.',
  );
}

SectionWorkspaceItem _buildSectionWorkspaceItem({
  required TeachingSubject subject,
  required TeachingSection section,
  required int fallbackExpectedStudents,
  required int index,
}) {
  final scheduledAt = _resolveSectionDate(section, index);
  final durationMinutes =
      section.durationMinutes ?? _durationFromLabel(section.timeLabel) ?? 90;
  final deliveryType =
      section.deliveryMode ?? _deliveryTypeFromSection(section, index);
  final meetingLink =
      (section.meetingLink != null && section.meetingLink!.trim().isNotEmpty)
      ? section.meetingLink
      : deliveryType == 'Online' && index.isEven
      ? 'https://meet.tolab.edu/${subject.code.toLowerCase()}-${section.groupLabel.toLowerCase()}'
      : null;
  final statusLabel = _sectionStatusLabel(
    section.statusLabel,
    scheduledAt,
    durationMinutes,
  );
  final needsLink =
      deliveryType == 'Online' && (meetingLink == null || meetingLink.isEmpty);
  final description =
      section.description ??
      'Section flow, teaching notes, and student-facing instructions are managed from the smart builder.';
  final needsUpdate =
      needsLink ||
      (scheduledAt.isBefore(_workspaceNow.add(const Duration(hours: 24))) &&
          description.length < 70);
  final locationLabel = deliveryType == 'Online'
      ? (meetingLink ?? 'Meeting link required')
      : (section.locationLabel ?? section.room);

  return SectionWorkspaceItem(
    id: _numericId(section.id),
    subjectId: subject.id,
    subjectLabel: '${subject.code} - ${subject.name}',
    subjectCode: subject.code,
    title: section.title,
    assistantName: section.assistantName,
    deliveryType: deliveryType,
    locationLabel: locationLabel,
    statusLabel: statusLabel,
    statusTone: _toneForStatus(statusLabel),
    scheduledAt: scheduledAt,
    dateLabel: DateFormat('EEE, d MMM').format(scheduledAt),
    timeLabel: _timeWindowLabel(scheduledAt, durationMinutes),
    durationMinutes: durationMinutes,
    expectedStudents: section.expectedStudents ?? fallbackExpectedStudents,
    accentColor: subject.accentColor,
    needsLink: needsLink,
    needsUpdate: needsUpdate,
    description: description,
    meetingLink: meetingLink,
    notes: section.notes,
    attachmentName: section.attachmentName,
  );
}

List<SectionWorkspaceAlert> _buildAttentionItems(
  List<SectionWorkspaceItem> items,
) {
  final alerts = <SectionWorkspaceAlert>[];
  for (final item in items) {
    if (item.needsLink) {
      alerts.add(
        SectionWorkspaceAlert(
          title: item.title,
          subtitle: 'Meeting link missing',
          caption:
              '${item.subjectCode} is online but still has no join link for students.',
          tone: 'danger',
          icon: Icons.link_off_rounded,
        ),
      );
    }
    if (item.needsUpdate) {
      alerts.add(
        SectionWorkspaceAlert(
          title: item.title,
          subtitle: 'Needs builder review',
          caption:
              'Delivery notes or readiness details should be tightened before the next section.',
          tone: 'warning',
          icon: Icons.edit_note_rounded,
        ),
      );
    }
    if (item.isToday && item.statusLabel == 'Published') {
      alerts.add(
        SectionWorkspaceAlert(
          title: item.title,
          subtitle: 'Starts today',
          caption:
              '${item.expectedStudents} students are expected in today\'s section window.',
          tone: 'primary',
          icon: Icons.alarm_rounded,
        ),
      );
    }
  }
  return alerts.take(5).toList(growable: false);
}

List<SectionWorkspaceActivity> _buildRecentActivity({
  required List<SectionWorkspaceItem> items,
  required List<WorkspaceNotificationItem> notifications,
  required List<MockAnnouncementItem> announcements,
}) {
  final activities = <MapEntry<DateTime, SectionWorkspaceActivity>>[];
  for (final item in items.take(3)) {
    activities.add(
      MapEntry(
        item.scheduledAt.subtract(const Duration(hours: 6)),
        SectionWorkspaceActivity(
          title: 'Section updated: ${item.title}',
          subtitle: '${item.subjectCode} - ${item.assistantName}',
          timeLabel: _relativeTime(
            item.scheduledAt.subtract(const Duration(hours: 6)),
          ),
          tone: item.statusTone,
          icon: item.isLive ? Icons.live_tv_rounded : Icons.widgets_rounded,
        ),
      ),
    );
  }

  for (final notification in notifications.take(3)) {
    activities.add(
      MapEntry(
        _workspaceNow.subtract(const Duration(minutes: 25)),
        SectionWorkspaceActivity(
          title: notification.title,
          subtitle: notification.body,
          timeLabel: notification.timeLabel,
          tone: notification.isRead ? 'primary' : 'warning',
          icon: notification.icon,
        ),
      ),
    );
  }

  for (final announcement in announcements.take(2)) {
    activities.add(
      MapEntry(
        announcement.publishedAt,
        SectionWorkspaceActivity(
          title: announcement.title,
          subtitle:
              '${announcement.subjectCode} - ${announcement.audienceLabel}',
          timeLabel: _relativeTime(announcement.publishedAt),
          tone: announcement.priorityLabel.toLowerCase() == 'urgent'
              ? 'danger'
              : 'primary',
          icon: Icons.campaign_rounded,
        ),
      ),
    );
  }

  activities.sort((left, right) => right.key.compareTo(left.key));
  return activities.map((entry) => entry.value).take(6).toList(growable: false);
}

DateTime _resolveSectionDate(TeachingSection section, int index) {
  final explicit = DateTime.tryParse(section.scheduledAtIso ?? '');
  if (explicit != null) {
    return explicit;
  }
  if (section.statusLabel.toLowerCase() == 'live') {
    return _workspaceNow.subtract(Duration(minutes: 20 + (index * 5)));
  }

  final weekday =
      _weekdayNumber(section.dayLabel) ??
      ((_workspaceNow.weekday + index + 1) % 7) + 1;
  final time = _parseTimeLabel(section.timeLabel);
  var daysOffset = weekday - _workspaceNow.weekday;
  if (section.statusLabel.toLowerCase() == 'scheduled' && daysOffset < 0) {
    daysOffset += 7;
  }
  final baseDate = _workspaceNow.add(Duration(days: daysOffset));
  return DateTime(
    baseDate.year,
    baseDate.month,
    baseDate.day,
    time.$1,
    time.$2,
  );
}

String _sectionStatusLabel(
  String rawStatus,
  DateTime scheduledAt,
  int durationMinutes,
) {
  final normalized = rawStatus.toLowerCase();
  if (normalized.contains('draft')) {
    return 'Draft';
  }
  final endAt = scheduledAt.add(Duration(minutes: durationMinutes));
  if (_workspaceNow.isAfter(endAt)) {
    return 'Finished';
  }
  if (_workspaceNow.isAfter(scheduledAt)) {
    return 'Live';
  }
  return 'Published';
}

String _deliveryTypeFromSection(TeachingSection section, int index) {
  final raw =
      '${section.room} ${section.locationLabel ?? ''} ${section.meetingLink ?? ''}'
          .toLowerCase();
  if (raw.contains('meet') ||
      raw.contains('zoom') ||
      raw.contains('online') ||
      raw.contains('http')) {
    return 'Online';
  }
  return index % 3 == 1 ? 'Online' : 'In person';
}

String _toneForStatus(String statusLabel) {
  return switch (statusLabel) {
    'Live' => 'danger',
    'Draft' => 'warning',
    'Finished' => 'success',
    _ => 'primary',
  };
}

String _timeWindowLabel(DateTime startAt, int durationMinutes) {
  final endAt = startAt.add(Duration(minutes: durationMinutes));
  return '${DateFormat('h:mm a').format(startAt)} - ${DateFormat('h:mm a').format(endAt)}';
}

int? _durationFromLabel(String raw) {
  final match = RegExp(
    r'(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})',
  ).firstMatch(raw);
  if (match == null) {
    return null;
  }
  final startHour = int.tryParse(match.group(1) ?? '');
  final startMinute = int.tryParse(match.group(2) ?? '');
  final endHour = int.tryParse(match.group(3) ?? '');
  final endMinute = int.tryParse(match.group(4) ?? '');
  if (startHour == null ||
      startMinute == null ||
      endHour == null ||
      endMinute == null) {
    return null;
  }
  return ((endHour * 60) + endMinute) - ((startHour * 60) + startMinute);
}

(int, int) _parseTimeLabel(String raw) {
  final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
  final hour = int.tryParse(match?.group(1) ?? '') ?? 9;
  final minute = int.tryParse(match?.group(2) ?? '') ?? 0;
  return (hour, minute);
}

int? _weekdayNumber(String raw) {
  return switch (raw.toLowerCase()) {
    'monday' => DateTime.monday,
    'tuesday' => DateTime.tuesday,
    'wednesday' => DateTime.wednesday,
    'thursday' => DateTime.thursday,
    'friday' => DateTime.friday,
    'saturday' => DateTime.saturday,
    'sunday' => DateTime.sunday,
    _ => null,
  };
}

String _relativeTime(DateTime value) {
  final difference = _workspaceNow.difference(value);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} hr ago';
  }
  return '${difference.inDays} day ago';
}

int _numericId(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(digits) ?? raw.hashCode.abs();
}

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

final DateTime _workspaceNow = DateTime(2026, 4, 23, 12);
