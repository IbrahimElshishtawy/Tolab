import 'package:flutter/material.dart';

enum ModerationWorkspaceTab {
  groups,
  posts,
  comments,
  messages,
  reports,
  analytics,
  permissions,
}

extension ModerationWorkspaceTabX on ModerationWorkspaceTab {
  String get label => switch (this) {
    ModerationWorkspaceTab.groups => 'Groups',
    ModerationWorkspaceTab.posts => 'Posts',
    ModerationWorkspaceTab.comments => 'Comments',
    ModerationWorkspaceTab.messages => 'Messages',
    ModerationWorkspaceTab.reports => 'Reports',
    ModerationWorkspaceTab.analytics => 'Analytics',
    ModerationWorkspaceTab.permissions => 'Permissions',
  };

  IconData get icon => switch (this) {
    ModerationWorkspaceTab.groups => Icons.groups_rounded,
    ModerationWorkspaceTab.posts => Icons.article_outlined,
    ModerationWorkspaceTab.comments => Icons.mode_comment_outlined,
    ModerationWorkspaceTab.messages => Icons.mark_chat_unread_outlined,
    ModerationWorkspaceTab.reports => Icons.flag_outlined,
    ModerationWorkspaceTab.analytics => Icons.analytics_outlined,
    ModerationWorkspaceTab.permissions =>
      Icons.admin_panel_settings_outlined,
  };
}

enum ModerationSectionKey { groups, posts, comments, messages, reports }

enum ModerationActionType {
  approve,
  warn,
  remove,
  deleteContent,
  banUser,
  suspendUser,
  ignoreReport,
  assignModerators,
  updatePermission,
}

extension ModerationActionTypeX on ModerationActionType {
  String get apiValue => switch (this) {
    ModerationActionType.approve => 'approve',
    ModerationActionType.warn => 'warn',
    ModerationActionType.remove => 'remove',
    ModerationActionType.deleteContent => 'delete',
    ModerationActionType.banUser => 'ban',
    ModerationActionType.suspendUser => 'suspend',
    ModerationActionType.ignoreReport => 'ignore',
    ModerationActionType.assignModerators => 'assign_moderators',
    ModerationActionType.updatePermission => 'update_permission',
  };

  String get label => switch (this) {
    ModerationActionType.approve => 'Approve',
    ModerationActionType.warn => 'Warn',
    ModerationActionType.remove => 'Remove',
    ModerationActionType.deleteContent => 'Delete',
    ModerationActionType.banUser => 'Ban user',
    ModerationActionType.suspendUser => 'Suspend user',
    ModerationActionType.ignoreReport => 'Ignore',
    ModerationActionType.assignModerators => 'Assign moderators',
    ModerationActionType.updatePermission => 'Update permission',
  };

  IconData get icon => switch (this) {
    ModerationActionType.approve => Icons.check_circle_outline_rounded,
    ModerationActionType.warn => Icons.warning_amber_rounded,
    ModerationActionType.remove => Icons.visibility_off_outlined,
    ModerationActionType.deleteContent => Icons.delete_outline_rounded,
    ModerationActionType.banUser => Icons.gpp_bad_outlined,
    ModerationActionType.suspendUser => Icons.pause_circle_outline_rounded,
    ModerationActionType.ignoreReport => Icons.do_disturb_alt_outlined,
    ModerationActionType.assignModerators =>
      Icons.admin_panel_settings_outlined,
    ModerationActionType.updatePermission => Icons.tune_rounded,
  };

  bool get isDestructive => switch (this) {
    ModerationActionType.deleteContent ||
    ModerationActionType.banUser ||
    ModerationActionType.suspendUser => true,
    _ => false,
  };
}

enum ModerationStatus {
  active,
  restricted,
  pending,
  approved,
  flagged,
  removed,
  ignored,
  suspended,
}

extension ModerationStatusX on ModerationStatus {
  String get label => switch (this) {
    ModerationStatus.active => 'Active',
    ModerationStatus.restricted => 'Restricted',
    ModerationStatus.pending => 'Pending',
    ModerationStatus.approved => 'Approved',
    ModerationStatus.flagged => 'Flagged',
    ModerationStatus.removed => 'Removed',
    ModerationStatus.ignored => 'Ignored',
    ModerationStatus.suspended => 'Suspended',
  };
}

ModerationStatus moderationStatusFromJson(String? value) {
  return switch ((value ?? '').trim().toLowerCase()) {
    'active' => ModerationStatus.active,
    'restricted' => ModerationStatus.restricted,
    'approved' => ModerationStatus.approved,
    'flagged' => ModerationStatus.flagged,
    'removed' => ModerationStatus.removed,
    'ignored' => ModerationStatus.ignored,
    'suspended' => ModerationStatus.suspended,
    _ => ModerationStatus.pending,
  };
}

class ModerationModeratorAccount {
  const ModerationModeratorAccount({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.speciality,
  });

  final String id;
  final String name;
  final String role;
  final String status;
  final String speciality;
}

class ModerationGroup {
  const ModerationGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.memberCount,
    required this.moderatorsCount,
    required this.flaggedPostsCount,
    required this.status,
    required this.lastActivityAt,
    required this.memberPreview,
    required this.moderatorIds,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final int memberCount;
  final int moderatorsCount;
  final int flaggedPostsCount;
  final ModerationStatus status;
  final DateTime lastActivityAt;
  final List<String> memberPreview;
  final List<String> moderatorIds;

  ModerationGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? memberCount,
    int? moderatorsCount,
    int? flaggedPostsCount,
    ModerationStatus? status,
    DateTime? lastActivityAt,
    List<String>? memberPreview,
    List<String>? moderatorIds,
  }) {
    return ModerationGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      memberCount: memberCount ?? this.memberCount,
      moderatorsCount: moderatorsCount ?? this.moderatorsCount,
      flaggedPostsCount: flaggedPostsCount ?? this.flaggedPostsCount,
      status: status ?? this.status,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      memberPreview: List<String>.unmodifiable(memberPreview ?? this.memberPreview),
      moderatorIds: List<String>.unmodifiable(moderatorIds ?? this.moderatorIds),
    );
  }
}

class ModerationPost {
  const ModerationPost({
    required this.id,
    required this.title,
    required this.bodyPreview,
    required this.authorId,
    required this.authorName,
    required this.groupId,
    required this.groupName,
    required this.status,
    required this.reportsCount,
    required this.commentsCount,
    required this.createdAt,
    required this.tags,
  });

  final String id;
  final String title;
  final String bodyPreview;
  final String authorId;
  final String authorName;
  final String groupId;
  final String groupName;
  final ModerationStatus status;
  final int reportsCount;
  final int commentsCount;
  final DateTime createdAt;
  final List<String> tags;

  ModerationPost copyWith({
    String? id,
    String? title,
    String? bodyPreview,
    String? authorId,
    String? authorName,
    String? groupId,
    String? groupName,
    ModerationStatus? status,
    int? reportsCount,
    int? commentsCount,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return ModerationPost(
      id: id ?? this.id,
      title: title ?? this.title,
      bodyPreview: bodyPreview ?? this.bodyPreview,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      status: status ?? this.status,
      reportsCount: reportsCount ?? this.reportsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      tags: List<String>.unmodifiable(tags ?? this.tags),
    );
  }
}

class ModerationComment {
  const ModerationComment({
    required this.id,
    required this.postId,
    required this.postTitle,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.status,
    required this.reportsCount,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String postTitle;
  final String authorId;
  final String authorName;
  final String content;
  final ModerationStatus status;
  final int reportsCount;
  final DateTime createdAt;

  ModerationComment copyWith({
    String? id,
    String? postId,
    String? postTitle,
    String? authorId,
    String? authorName,
    String? content,
    ModerationStatus? status,
    int? reportsCount,
    DateTime? createdAt,
  }) {
    return ModerationComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      postTitle: postTitle ?? this.postTitle,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      status: status ?? this.status,
      reportsCount: reportsCount ?? this.reportsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ModerationMessage {
  const ModerationMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.status,
    required this.riskScore,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String content;
  final ModerationStatus status;
  final double riskScore;
  final DateTime createdAt;

  ModerationMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? content,
    ModerationStatus? status,
    double? riskScore,
    DateTime? createdAt,
  }) {
    return ModerationMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      content: content ?? this.content,
      status: status ?? this.status,
      riskScore: riskScore ?? this.riskScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ModerationReport {
  const ModerationReport({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.subjectTitle,
    required this.contentPreview,
    required this.groupName,
    required this.reporterName,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String contentId;
  final String contentType;
  final String subjectTitle;
  final String contentPreview;
  final String groupName;
  final String reporterName;
  final String reason;
  final ModerationStatus status;
  final DateTime createdAt;

  ModerationReport copyWith({
    String? id,
    String? contentId,
    String? contentType,
    String? subjectTitle,
    String? contentPreview,
    String? groupName,
    String? reporterName,
    String? reason,
    ModerationStatus? status,
    DateTime? createdAt,
  }) {
    return ModerationReport(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      subjectTitle: subjectTitle ?? this.subjectTitle,
      contentPreview: contentPreview ?? this.contentPreview,
      groupName: groupName ?? this.groupName,
      reporterName: reporterName ?? this.reporterName,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ModerationPermissionScope {
  const ModerationPermissionScope({
    required this.key,
    required this.label,
    required this.description,
  });

  final String key;
  final String label;
  final String description;
}

class ModerationRoleProfile {
  const ModerationRoleProfile({
    required this.id,
    required this.roleName,
    required this.memberCount,
    required this.permissions,
    required this.membersPreview,
  });

  final String id;
  final String roleName;
  final int memberCount;
  final Map<String, bool> permissions;
  final List<String> membersPreview;

  ModerationRoleProfile copyWith({
    String? id,
    String? roleName,
    int? memberCount,
    Map<String, bool>? permissions,
    List<String>? membersPreview,
  }) {
    return ModerationRoleProfile(
      id: id ?? this.id,
      roleName: roleName ?? this.roleName,
      memberCount: memberCount ?? this.memberCount,
      permissions: Map<String, bool>.unmodifiable(
        permissions ?? this.permissions,
      ),
      membersPreview: List<String>.unmodifiable(
        membersPreview ?? this.membersPreview,
      ),
    );
  }
}

class ModerationTrendPoint {
  const ModerationTrendPoint({
    required this.label,
    required this.value,
    required this.secondaryValue,
  });

  final String label;
  final double value;
  final double secondaryValue;
}

class ModerationBreakdownEntry {
  const ModerationBreakdownEntry({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class ModerationAnalytics {
  const ModerationAnalytics({
    required this.activityTrend,
    required this.reportsByType,
    required this.reportsByGroup,
    required this.reportsByPeriod,
  });

  final List<ModerationTrendPoint> activityTrend;
  final List<ModerationBreakdownEntry> reportsByType;
  final List<ModerationBreakdownEntry> reportsByGroup;
  final List<ModerationBreakdownEntry> reportsByPeriod;
}

class ModerationNotificationItem {
  const ModerationNotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.severity,
    required this.isUnread,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final String severity;
  final bool isUnread;
}

class ModerationDashboardBundle {
  const ModerationDashboardBundle({
    required this.groups,
    required this.posts,
    required this.comments,
    required this.messages,
    required this.reports,
    required this.moderators,
    required this.permissionScopes,
    required this.roleProfiles,
    required this.notifications,
    required this.analytics,
    this.isFallback = false,
    this.notice,
  });

  final List<ModerationGroup> groups;
  final List<ModerationPost> posts;
  final List<ModerationComment> comments;
  final List<ModerationMessage> messages;
  final List<ModerationReport> reports;
  final List<ModerationModeratorAccount> moderators;
  final List<ModerationPermissionScope> permissionScopes;
  final List<ModerationRoleProfile> roleProfiles;
  final List<ModerationNotificationItem> notifications;
  final ModerationAnalytics analytics;
  final bool isFallback;
  final String? notice;

  ModerationDashboardBundle copyWith({
    List<ModerationGroup>? groups,
    List<ModerationPost>? posts,
    List<ModerationComment>? comments,
    List<ModerationMessage>? messages,
    List<ModerationReport>? reports,
    List<ModerationModeratorAccount>? moderators,
    List<ModerationPermissionScope>? permissionScopes,
    List<ModerationRoleProfile>? roleProfiles,
    List<ModerationNotificationItem>? notifications,
    ModerationAnalytics? analytics,
    bool? isFallback,
    String? notice,
    bool clearNotice = false,
  }) {
    return ModerationDashboardBundle(
      groups: List<ModerationGroup>.unmodifiable(groups ?? this.groups),
      posts: List<ModerationPost>.unmodifiable(posts ?? this.posts),
      comments: List<ModerationComment>.unmodifiable(comments ?? this.comments),
      messages: List<ModerationMessage>.unmodifiable(messages ?? this.messages),
      reports: List<ModerationReport>.unmodifiable(reports ?? this.reports),
      moderators: List<ModerationModeratorAccount>.unmodifiable(
        moderators ?? this.moderators,
      ),
      permissionScopes: List<ModerationPermissionScope>.unmodifiable(
        permissionScopes ?? this.permissionScopes,
      ),
      roleProfiles: List<ModerationRoleProfile>.unmodifiable(
        roleProfiles ?? this.roleProfiles,
      ),
      notifications: List<ModerationNotificationItem>.unmodifiable(
        notifications ?? this.notifications,
      ),
      analytics: analytics ?? this.analytics,
      isFallback: isFallback ?? this.isFallback,
      notice: clearNotice ? null : notice ?? this.notice,
    );
  }
}

class ModerationActionCommand {
  const ModerationActionCommand({
    required this.actionType,
    required this.targetType,
    required this.targetIds,
    this.userIds = const <String>[],
    this.reason,
    this.permissionKey,
    this.permissionEnabled,
  });

  final ModerationActionType actionType;
  final String targetType;
  final List<String> targetIds;
  final List<String> userIds;
  final String? reason;
  final String? permissionKey;
  final bool? permissionEnabled;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'action': actionType.apiValue,
      'target_type': targetType,
      'target_ids': targetIds,
      if (userIds.isNotEmpty) 'user_ids': userIds,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
      if (permissionKey != null) 'permission_key': permissionKey,
      if (permissionEnabled != null) 'permission_enabled': permissionEnabled,
    };
  }
}

class ModerationMutationResult {
  const ModerationMutationResult({
    required this.bundle,
    required this.message,
  });

  final ModerationDashboardBundle bundle;
  final String message;
}
