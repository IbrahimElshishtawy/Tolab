import 'package:flutter/material.dart';

class StaffAdminRecord {
  const StaffAdminRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.employeeId,
    required this.role,
    required this.doctorType,
    required this.department,
    required this.status,
    required this.accountCreationStatus,
    required this.roleSummary,
    required this.recentActivity,
    required this.createdAtLabel,
    required this.lastActiveLabel,
    required this.attendanceRate,
    required this.engagementRate,
    required this.permissionCoverage,
    required this.subjectsAssigned,
    required this.lecturesUploaded,
    required this.tasksCreated,
    required this.postsCreated,
    required this.uploadsCount,
    required this.scheduleUpdates,
    required this.subjects,
    required this.permissionGroups,
    required this.timeline,
    required this.attendanceTrend,
    required this.engagementTrend,
  });

  final String id;
  final String fullName;
  final String email;
  final String employeeId;
  final String role;
  final String? doctorType;
  final String department;
  final String status;
  final String accountCreationStatus;
  final String roleSummary;
  final String recentActivity;
  final String createdAtLabel;
  final String lastActiveLabel;
  final double attendanceRate;
  final double engagementRate;
  final double permissionCoverage;
  final int subjectsAssigned;
  final int lecturesUploaded;
  final int tasksCreated;
  final int postsCreated;
  final int uploadsCount;
  final int scheduleUpdates;
  final List<StaffSubjectAssignment> subjects;
  final List<StaffPermissionGroup> permissionGroups;
  final List<StaffTimelineEvent> timeline;
  final List<StaffMetricPoint> attendanceTrend;
  final List<StaffMetricPoint> engagementTrend;

  bool get isDoctor => role == 'Doctor';
  bool get isAssistant => role == 'Assistant';
  bool get isInternalDoctor => doctorType == 'Internal faculty doctor';
  bool get isDelegatedDoctor => isDoctor && !isInternalDoctor;

  int get enabledPermissionsCount => permissionGroups.fold<int>(
    0,
    (sum, group) =>
        sum +
        group.permissions.where((permission) => permission.enabled).length,
  );

  int get totalPermissionsCount => permissionGroups.fold<int>(
    0,
    (sum, group) => sum + group.permissions.length,
  );

  int get totalAcademicOutputs =>
      lecturesUploaded + tasksCreated + postsCreated + uploadsCount;

  bool get needsAttention =>
      attendanceRate < 75 ||
      permissionCoverage < 72 ||
      status != 'Active' ||
      engagementRate < 68;

  String get permissionsSummary =>
      '$enabledPermissionsCount/$totalPermissionsCount active';

  String get roleTypeLabel => doctorType ?? 'Teaching assistant';
  String get attendanceSummary => '${attendanceRate.round()}% present';
  String get engagementSummary => '${engagementRate.round()}% engagement';
  String get activitySummary =>
      '$totalAcademicOutputs academic outputs • $scheduleUpdates schedule changes';
  String get monitoringSummary =>
      '$accountCreationStatus • Last active $lastActiveLabel';

  String get attendanceBand {
    if (attendanceRate >= 90) return 'Excellent';
    if (attendanceRate >= 80) return 'Stable';
    if (attendanceRate >= 70) return 'Watch';
    return 'Critical';
  }

  String get engagementBand {
    if (engagementRate >= 88) return 'High output';
    if (engagementRate >= 76) return 'Healthy';
    if (engagementRate >= 65) return 'Moderate';
    return 'Low activity';
  }

  String get accountHealthBand {
    if (needsAttention) return 'Needs review';
    if (permissionCoverage >= 88 && attendanceRate >= 88) return 'Controlled';
    return 'Monitored';
  }

  StaffAdminRecord copyWith({
    List<StaffPermissionGroup>? permissionGroups,
    double? permissionCoverage,
  }) {
    return StaffAdminRecord(
      id: id,
      fullName: fullName,
      email: email,
      employeeId: employeeId,
      role: role,
      doctorType: doctorType,
      department: department,
      status: status,
      accountCreationStatus: accountCreationStatus,
      roleSummary: roleSummary,
      recentActivity: recentActivity,
      createdAtLabel: createdAtLabel,
      lastActiveLabel: lastActiveLabel,
      attendanceRate: attendanceRate,
      engagementRate: engagementRate,
      permissionCoverage: permissionCoverage ?? this.permissionCoverage,
      subjectsAssigned: subjectsAssigned,
      lecturesUploaded: lecturesUploaded,
      tasksCreated: tasksCreated,
      postsCreated: postsCreated,
      uploadsCount: uploadsCount,
      scheduleUpdates: scheduleUpdates,
      subjects: subjects,
      permissionGroups: permissionGroups ?? this.permissionGroups,
      timeline: timeline,
      attendanceTrend: attendanceTrend,
      engagementTrend: engagementTrend,
    );
  }
}

class StaffPermissionGroup {
  const StaffPermissionGroup({
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
  final List<StaffPermission> permissions;

  StaffPermissionGroup copyWith({List<StaffPermission>? permissions}) {
    return StaffPermissionGroup(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      permissions: permissions ?? this.permissions,
    );
  }
}

class StaffPermission {
  const StaffPermission({
    required this.id,
    required this.title,
    required this.description,
    required this.enabled,
  });

  final String id;
  final String title;
  final String description;
  final bool enabled;

  StaffPermission copyWith({bool? enabled}) {
    return StaffPermission(
      id: id,
      title: title,
      description: description,
      enabled: enabled ?? this.enabled,
    );
  }
}

class StaffSubjectAssignment {
  const StaffSubjectAssignment({
    required this.code,
    required this.title,
    required this.section,
    required this.lectures,
    required this.tasks,
    required this.posts,
    required this.uploads,
    required this.engagementRate,
    required this.status,
  });

  final String code;
  final String title;
  final String section;
  final int lectures;
  final int tasks;
  final int posts;
  final int uploads;
  final double engagementRate;
  final String status;
}

class StaffTimelineEvent {
  const StaffTimelineEvent({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.emphasis,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String emphasis;
}

class StaffMetricPoint {
  const StaffMetricPoint({required this.label, required this.value});

  final String label;
  final double value;
}
