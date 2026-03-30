import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef JsonMap = Map<String, dynamic>;

enum AcademyRole { admin, student, doctor }

extension AcademyRoleX on AcademyRole {
  String get label => switch (this) {
    AcademyRole.admin => 'Admin',
    AcademyRole.student => 'Student',
    AcademyRole.doctor => 'Doctor / Assistant',
  };

  String get routeSegment => switch (this) {
    AcademyRole.admin => 'admin',
    AcademyRole.student => 'student',
    AcademyRole.doctor => 'doctor',
  };

  String get shellTitle => switch (this) {
    AcademyRole.admin => 'Academy Control Center',
    AcademyRole.student => 'Student Learning Hub',
    AcademyRole.doctor => 'Doctor Teaching Studio',
  };

  static AcademyRole fromRaw(
    String raw, {
    AcademyRole fallback = AcademyRole.admin,
  }) {
    final normalized = raw.trim().toUpperCase();
    return switch (normalized) {
      'ADMIN' => AcademyRole.admin,
      'STUDENT' => AcademyRole.student,
      'DOCTOR' || 'TA' || 'ASSISTANT' => AcademyRole.doctor,
      _ => fallback,
    };
  }
}

enum PanelLoadStatus { initial, loading, success, failure }

extension PanelLoadStatusX on PanelLoadStatus {
  bool get isLoading => this == PanelLoadStatus.loading;
  bool get isFailure => this == PanelLoadStatus.failure;
  bool get isSuccess => this == PanelLoadStatus.success;
}

class AcademyUser {
  const AcademyUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.department,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final AcademyRole role;
  final String status;
  final String? department;
  final String? avatarUrl;

  factory AcademyUser.fromJson(JsonMap json, {AcademyRole? fallbackRole}) {
    return AcademyUser(
      id: json['id']?.toString() ?? '0',
      name:
          json['name']?.toString() ??
          json['username']?.toString() ??
          json['full_name']?.toString() ??
          'Tolab User',
      email: json['email']?.toString() ?? 'demo@tolab.edu',
      role: AcademyRoleX.fromRaw(
        json['role']?.toString() ?? '',
        fallback: fallbackRole ?? AcademyRole.admin,
      ),
      status:
          json['status']?.toString() ??
          (json['is_active'] == false ? 'inactive' : 'active'),
      department:
          json['department']?.toString() ?? json['department_name']?.toString(),
      avatarUrl:
          json['avatar_url']?.toString() ?? json['avatarUrl']?.toString(),
    );
  }
}

class AcademyNotificationItem {
  const AcademyNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.source,
    required this.role,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String source;
  final AcademyRole role;
  final bool isRead;

  String get relativeLabel {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} min ago';
    if (difference.inDays < 1) return '${difference.inHours} hr ago';
    return DateFormat('d MMM, HH:mm').format(createdAt);
  }

  AcademyNotificationItem copyWith({bool? isRead}) {
    return AcademyNotificationItem(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      source: source,
      role: role,
      isRead: isRead ?? this.isRead,
    );
  }
}

class AcademyToast {
  const AcademyToast({
    required this.id,
    required this.title,
    required this.message,
    required this.role,
    this.accentColor,
  });

  final String id;
  final String title;
  final String message;
  final AcademyRole role;
  final Color? accentColor;
}

class RoleNavItem {
  const RoleNavItem({
    required this.key,
    required this.title,
    required this.route,
    required this.icon,
    required this.description,
  });

  final String key;
  final String title;
  final String route;
  final IconData icon;
  final String description;
}

class QuickJumpItem {
  const QuickJumpItem({
    required this.sectionId,
    required this.label,
    this.icon,
  });

  final String sectionId;
  final String label;
  final IconData? icon;
}

class PanelMetric {
  const PanelMetric({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final Color? color;
}

class PanelInfoCard {
  const PanelInfoCard({
    required this.title,
    required this.value,
    required this.caption,
    this.highlight,
    this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final String? highlight;
  final IconData? icon;
}

class PanelListItem {
  const PanelListItem({
    required this.title,
    required this.subtitle,
    required this.meta,
    this.status,
    this.icon,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String? status;
  final IconData? icon;
}

class PanelTimelineEntry {
  const PanelTimelineEntry({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    this.location,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String? location;
}

class PanelTableColumn {
  const PanelTableColumn({
    required this.label,
    required this.key,
    this.numeric = false,
  });

  final String label;
  final String key;
  final bool numeric;
}

class PanelTableRow {
  const PanelTableRow(this.cells);

  final JsonMap cells;
}

class PanelTableData {
  const PanelTableData({
    required this.columns,
    required this.rows,
    this.stickyHeader = true,
    this.emptyLabel = 'No rows available yet.',
  });

  final List<PanelTableColumn> columns;
  final List<PanelTableRow> rows;
  final bool stickyHeader;
  final String emptyLabel;
}

class UploadDraft {
  const UploadDraft({required this.name, this.path, this.bytes, this.size});

  final String name;
  final String? path;
  final Uint8List? bytes;
  final int? size;
}

class UploadItem {
  const UploadItem({
    required this.name,
    required this.status,
    required this.sizeLabel,
  });

  final String name;
  final String status;
  final String sizeLabel;
}

enum PageSectionType { metrics, cards, list, table, timeline, uploads }

class PageSectionData {
  const PageSectionData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.metrics = const [],
    this.cards = const [],
    this.items = const [],
    this.timeline = const [],
    this.table,
    this.uploads = const [],
    this.allowUploads = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final PageSectionType type;
  final List<PanelMetric> metrics;
  final List<PanelInfoCard> cards;
  final List<PanelListItem> items;
  final List<PanelTimelineEntry> timeline;
  final PanelTableData? table;
  final List<UploadItem> uploads;
  final bool allowUploads;
}

class RolePageData {
  const RolePageData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.breadcrumbs,
    required this.quickJumps,
    required this.sections,
    required this.primaryActionLabel,
    required this.backendEndpoints,
    required this.emptyStateMessage,
  });

  final String key;
  final String title;
  final String subtitle;
  final List<String> breadcrumbs;
  final List<QuickJumpItem> quickJumps;
  final List<PageSectionData> sections;
  final String primaryActionLabel;
  final List<String> backendEndpoints;
  final String emptyStateMessage;
}
