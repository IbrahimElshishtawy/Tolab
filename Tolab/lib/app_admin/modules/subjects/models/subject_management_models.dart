import 'package:flutter/material.dart';

class SubjectRecord {
  const SubjectRecord({
    required this.id,
    required this.code,
    required this.name,
    required this.department,
    required this.academicYear,
    required this.creditHours,
    required this.contactHours,
    required this.status,
    required this.doctor,
    required this.assistant,
    required this.eligibleStudents,
    required this.enrolledStudents,
    required this.group,
    required this.posts,
    required this.summaries,
    required this.access,
    required this.permissions,
    required this.students,
    required this.timeline,
    required this.activity,
    required this.updatedAtLabel,
    required this.lateRegistrationEnabled,
  });

  final String id;
  final String code;
  final String name;
  final String department;
  final String academicYear;
  final int creditHours;
  final int contactHours;
  final String status;
  final SubjectStaffMember doctor;
  final SubjectStaffMember assistant;
  final int eligibleStudents;
  final int enrolledStudents;
  final SubjectGroupInfo group;
  final SubjectPostsInfo posts;
  final SubjectSummariesInfo summaries;
  final SubjectAccessInfo access;
  final List<SubjectPermissionCategory> permissions;
  final List<SubjectStudentItem> students;
  final List<SubjectTimelineEvent> timeline;
  final List<SubjectActivityPoint> activity;
  final String updatedAtLabel;
  final bool lateRegistrationEnabled;

  double get fillRate =>
      eligibleStudents == 0 ? 0 : enrolledStudents / eligibleStudents;

  int get postsAndSummaries => posts.count + summaries.count;
}

class SubjectStaffMember {
  const SubjectStaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.channelLabel,
    required this.status,
    required this.color,
  });

  final String id;
  final String name;
  final String role;
  final String email;
  final String channelLabel;
  final String status;
  final Color color;
}

class SubjectGroupInfo {
  const SubjectGroupInfo({
    required this.enabled,
    required this.name,
    required this.members,
    required this.moderationLabel,
    required this.engagementLabel,
  });

  final bool enabled;
  final String name;
  final int members;
  final String moderationLabel;
  final String engagementLabel;
}

class SubjectPostsInfo {
  const SubjectPostsInfo({
    required this.count,
    required this.openingScope,
    required this.monitoringScope,
    required this.recent,
  });

  final int count;
  final String openingScope;
  final String monitoringScope;
  final List<SubjectPostItem> recent;
}

class SubjectPostItem {
  const SubjectPostItem({
    required this.title,
    required this.author,
    required this.timeLabel,
    required this.status,
  });

  final String title;
  final String author;
  final String timeLabel;
  final String status;
}

class SubjectSummariesInfo {
  const SubjectSummariesInfo({
    required this.count,
    required this.accessScope,
    required this.latest,
  });

  final int count;
  final String accessScope;
  final List<SubjectSummaryItem> latest;
}

class SubjectSummaryItem {
  const SubjectSummaryItem({
    required this.title,
    required this.versionLabel,
    required this.updatedAtLabel,
  });

  final String title;
  final String versionLabel;
  final String updatedAtLabel;
}

class SubjectAccessInfo {
  const SubjectAccessInfo({
    required this.code,
    required this.link,
    required this.lateJoinLabel,
    required this.regeneratedAtLabel,
  });

  final String code;
  final String link;
  final String lateJoinLabel;
  final String regeneratedAtLabel;
}

class SubjectPermissionCategory {
  const SubjectPermissionCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.permissions,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<SubjectPermissionRule> permissions;
}

class SubjectPermissionRule {
  const SubjectPermissionRule({
    required this.id,
    required this.title,
    required this.description,
    required this.enabled,
  });

  final String id;
  final String title;
  final String description;
  final bool enabled;
}

class SubjectStudentItem {
  const SubjectStudentItem({
    required this.id,
    required this.name,
    required this.section,
    required this.level,
    required this.status,
    required this.privacyLabel,
    required this.lateJoin,
  });

  final String id;
  final String name;
  final String section;
  final String level;
  final String status;
  final String privacyLabel;
  final bool lateJoin;
}

class SubjectTimelineEvent {
  const SubjectTimelineEvent({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String tone;
}

class SubjectActivityPoint {
  const SubjectActivityPoint(this.label, this.value);

  final String label;
  final double value;
}
