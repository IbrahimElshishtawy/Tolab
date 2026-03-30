import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../models/moderation_models.dart';

class ModerationSeedService {
  const ModerationSeedService();

  ModerationDashboardBundle createBundle() {
    final now = DateTime.now();

    final moderators = const [
      ModerationModeratorAccount(
        id: 'mod-1',
        name: 'Nadine Soliman',
        role: 'Lead Moderator',
        status: 'Active',
        speciality: 'Student communities',
      ),
      ModerationModeratorAccount(
        id: 'mod-2',
        name: 'Omar Hany',
        role: 'Safety Analyst',
        status: 'Active',
        speciality: 'Escalations',
      ),
      ModerationModeratorAccount(
        id: 'mod-3',
        name: 'Maya Adel',
        role: 'Community Manager',
        status: 'Reviewing',
        speciality: 'Messaging abuse',
      ),
    ];

    final groups = [
      ModerationGroup(
        id: 'group-1',
        name: 'Computer Vision Lab',
        description: 'Research group for image processing and model reviews.',
        category: 'Research',
        memberCount: 124,
        moderatorsCount: 2,
        flaggedPostsCount: 4,
        status: ModerationStatus.active,
        lastActivityAt: now.subtract(const Duration(minutes: 18)),
        memberPreview: const ['Sara M.', 'Youssef H.', 'Lina F.'],
        moderatorIds: const ['mod-1', 'mod-2'],
      ),
      ModerationGroup(
        id: 'group-2',
        name: 'Freshman Marketplace',
        description: 'Peer-to-peer resale and onboarding coordination.',
        category: 'Community',
        memberCount: 582,
        moderatorsCount: 1,
        flaggedPostsCount: 11,
        status: ModerationStatus.restricted,
        lastActivityAt: now.subtract(const Duration(hours: 2)),
        memberPreview: const ['Ali R.', 'Mariam S.', 'Hana A.'],
        moderatorIds: const ['mod-3'],
      ),
      ModerationGroup(
        id: 'group-3',
        name: 'Internship Exchange',
        description: 'Verified opportunities, portfolio feedback, and referrals.',
        category: 'Career',
        memberCount: 260,
        moderatorsCount: 2,
        flaggedPostsCount: 3,
        status: ModerationStatus.active,
        lastActivityAt: now.subtract(const Duration(hours: 5)),
        memberPreview: const ['Khaled A.', 'Mennat S.', 'Tarek N.'],
        moderatorIds: const ['mod-1', 'mod-3'],
      ),
      ModerationGroup(
        id: 'group-4',
        name: 'Course Notes Exchange',
        description: 'Shared summaries and study material requests.',
        category: 'Academic',
        memberCount: 904,
        moderatorsCount: 2,
        flaggedPostsCount: 9,
        status: ModerationStatus.pending,
        lastActivityAt: now.subtract(const Duration(days: 1)),
        memberPreview: const ['Rama B.', 'Nour T.', 'Ahmed K.'],
        moderatorIds: const ['mod-1', 'mod-2'],
      ),
    ];

    final posts = [
      ModerationPost(
        id: 'post-1',
        title: 'Dataset drive link with off-platform payment request',
        bodyPreview:
            'Sharing “exclusive” lecture recordings if classmates transfer outside the platform.',
        authorId: 'user-1',
        authorName: 'Mahmoud Adel',
        groupId: 'group-2',
        groupName: 'Freshman Marketplace',
        status: ModerationStatus.flagged,
        reportsCount: 8,
        commentsCount: 14,
        createdAt: now.subtract(const Duration(hours: 3)),
        tags: const ['payments', 'external-link'],
      ),
      ModerationPost(
        id: 'post-2',
        title: 'Internship referral spreadsheet',
        bodyPreview:
            'Open spreadsheet for students seeking verified internship referrals.',
        authorId: 'user-2',
        authorName: 'Mona Ashraf',
        groupId: 'group-3',
        groupName: 'Internship Exchange',
        status: ModerationStatus.approved,
        reportsCount: 1,
        commentsCount: 9,
        createdAt: now.subtract(const Duration(hours: 8)),
        tags: const ['careers', 'verified'],
      ),
      ModerationPost(
        id: 'post-3',
        title: 'Selling project solution package',
        bodyPreview:
            'Complete submission package offered for direct purchase before deadline.',
        authorId: 'user-3',
        authorName: 'Yara Tarek',
        groupId: 'group-4',
        groupName: 'Course Notes Exchange',
        status: ModerationStatus.pending,
        reportsCount: 6,
        commentsCount: 3,
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
        tags: const ['cheating', 'sales'],
      ),
      ModerationPost(
        id: 'post-4',
        title: 'Weekly seminar highlights',
        bodyPreview: 'Photo recap and takeaways from the lab seminar series.',
        authorId: 'user-4',
        authorName: 'Salma Nabil',
        groupId: 'group-1',
        groupName: 'Computer Vision Lab',
        status: ModerationStatus.active,
        reportsCount: 0,
        commentsCount: 11,
        createdAt: now.subtract(const Duration(days: 2)),
        tags: const ['lab', 'events'],
      ),
    ];

    final comments = [
      ModerationComment(
        id: 'comment-1',
        postId: 'post-1',
        postTitle: 'Dataset drive link with off-platform payment request',
        authorId: 'user-5',
        authorName: 'Alaa Samir',
        content: 'DM me if you want another private copy and a direct seller.',
        status: ModerationStatus.flagged,
        reportsCount: 4,
        createdAt: now.subtract(const Duration(hours: 2, minutes: 20)),
      ),
      ModerationComment(
        id: 'comment-2',
        postId: 'post-3',
        postTitle: 'Selling project solution package',
        authorId: 'user-6',
        authorName: 'Rana Omar',
        content: 'This clearly violates the honor code and should be removed.',
        status: ModerationStatus.approved,
        reportsCount: 0,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      ModerationComment(
        id: 'comment-3',
        postId: 'post-2',
        postTitle: 'Internship referral spreadsheet',
        authorId: 'user-7',
        authorName: 'Nourhan Ali',
        content: 'Can we add cybersecurity roles too?',
        status: ModerationStatus.active,
        reportsCount: 0,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      ModerationComment(
        id: 'comment-4',
        postId: 'post-4',
        postTitle: 'Weekly seminar highlights',
        authorId: 'user-8',
        authorName: 'Youssef Karim',
        content: 'Stop reposting the same links every week.',
        status: ModerationStatus.pending,
        reportsCount: 1,
        createdAt: now.subtract(const Duration(days: 2, hours: 3)),
      ),
    ];

    final messages = [
      ModerationMessage(
        id: 'message-1',
        senderId: 'user-10',
        senderName: 'Unknown Seller',
        receiverId: 'user-11',
        receiverName: 'Amir Hassan',
        content:
            'Send your number and I will forward the solved assignment pack tonight.',
        status: ModerationStatus.flagged,
        riskScore: 0.93,
        createdAt: now.subtract(const Duration(minutes: 35)),
      ),
      ModerationMessage(
        id: 'message-2',
        senderId: 'user-12',
        senderName: 'Mina Atef',
        receiverId: 'user-13',
        receiverName: 'Laila Fares',
        content:
            'Please keep the discussion in-app so moderators can verify job details.',
        status: ModerationStatus.approved,
        riskScore: 0.21,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      ModerationMessage(
        id: 'message-3',
        senderId: 'user-14',
        senderName: 'Vendor Bot',
        receiverId: 'user-15',
        receiverName: 'Karim Salah',
        content:
            'We can unlock premium notes after a quick transfer, no questions asked.',
        status: ModerationStatus.pending,
        riskScore: 0.88,
        createdAt: now.subtract(const Duration(hours: 9)),
      ),
    ];

    final reports = [
      ModerationReport(
        id: 'report-1',
        contentId: 'post-1',
        contentType: 'Post',
        subjectTitle: 'Dataset drive link with off-platform payment request',
        contentPreview:
            'Sharing “exclusive” lecture recordings if classmates transfer outside the platform.',
        groupName: 'Freshman Marketplace',
        reporterName: 'Heba Nader',
        reason: 'Off-platform payment solicitation',
        status: ModerationStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 28)),
      ),
      ModerationReport(
        id: 'report-2',
        contentId: 'comment-1',
        contentType: 'Comment',
        subjectTitle: 'Comment on dataset drive link',
        contentPreview: 'DM me if you want another private copy and a direct seller.',
        groupName: 'Freshman Marketplace',
        reporterName: 'Marina Samy',
        reason: 'Repeat spam',
        status: ModerationStatus.flagged,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
      ),
      ModerationReport(
        id: 'report-3',
        contentId: 'message-1',
        contentType: 'Message',
        subjectTitle: 'Suspicious direct message',
        contentPreview:
            'Send your number and I will forward the solved assignment pack tonight.',
        groupName: 'Direct messages',
        reporterName: 'Amir Hassan',
        reason: 'Academic misconduct',
        status: ModerationStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      ModerationReport(
        id: 'report-4',
        contentId: 'post-3',
        contentType: 'Post',
        subjectTitle: 'Selling project solution package',
        contentPreview:
            'Complete submission package offered for direct purchase before deadline.',
        groupName: 'Course Notes Exchange',
        reporterName: 'Mostafa Samir',
        reason: 'Cheating services',
        status: ModerationStatus.pending,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      ModerationReport(
        id: 'report-5',
        contentId: 'group-2',
        contentType: 'Group',
        subjectTitle: 'Freshman Marketplace',
        contentPreview:
            'Spike in flagged sales and payment-bait threads during onboarding week.',
        groupName: 'Freshman Marketplace',
        reporterName: 'System',
        reason: 'Automated escalation',
        status: ModerationStatus.flagged,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    final permissionScopes = const [
      ModerationPermissionScope(
        key: 'view_reports',
        label: 'View reports',
        description: 'Open queues, inspect report metadata, and preview evidence.',
      ),
      ModerationPermissionScope(
        key: 'warn_users',
        label: 'Warn users',
        description: 'Issue policy warnings without deleting content.',
      ),
      ModerationPermissionScope(
        key: 'remove_content',
        label: 'Remove content',
        description: 'Hide or permanently delete posts, comments, and messages.',
      ),
      ModerationPermissionScope(
        key: 'suspend_users',
        label: 'Suspend users',
        description: 'Temporarily suspend or ban accounts after escalation.',
      ),
      ModerationPermissionScope(
        key: 'assign_moderators',
        label: 'Assign moderators',
        description: 'Grant moderator coverage to groups and communities.',
      ),
    ];

    final roleProfiles = const [
      ModerationRoleProfile(
        id: 'role-1',
        roleName: 'Community Moderator',
        memberCount: 12,
        permissions: {
          'view_reports': true,
          'warn_users': true,
          'remove_content': true,
          'suspend_users': false,
          'assign_moderators': false,
        },
        membersPreview: ['Nadine', 'Maya', 'Layla'],
      ),
      ModerationRoleProfile(
        id: 'role-2',
        roleName: 'Safety Lead',
        memberCount: 4,
        permissions: {
          'view_reports': true,
          'warn_users': true,
          'remove_content': true,
          'suspend_users': true,
          'assign_moderators': true,
        },
        membersPreview: ['Omar', 'Samah', 'Mina'],
      ),
      ModerationRoleProfile(
        id: 'role-3',
        roleName: 'Analyst',
        memberCount: 6,
        permissions: {
          'view_reports': true,
          'warn_users': false,
          'remove_content': false,
          'suspend_users': false,
          'assign_moderators': false,
        },
        membersPreview: ['Kareem', 'Hana', 'Rita'],
      ),
    ];

    return _rebuildBundle(
      groups: groups,
      posts: posts,
      comments: comments,
      messages: messages,
      reports: reports,
      moderators: moderators,
      permissionScopes: permissionScopes,
      roleProfiles: roleProfiles,
      isFallback: true,
      notice:
          'Showing local moderation data because the admin moderation API is not reachable yet.',
    );
  }

  ModerationDashboardBundle composeBundle({
    required List<ModerationGroup> groups,
    required List<ModerationPost> posts,
    required List<ModerationComment> comments,
    required List<ModerationMessage> messages,
    required List<ModerationReport> reports,
    required List<ModerationModeratorAccount> moderators,
    required List<ModerationPermissionScope> permissionScopes,
    required List<ModerationRoleProfile> roleProfiles,
    bool isFallback = false,
    String? notice,
  }) {
    return _rebuildBundle(
      groups: groups,
      posts: posts,
      comments: comments,
      messages: messages,
      reports: reports,
      moderators: moderators,
      permissionScopes: permissionScopes,
      roleProfiles: roleProfiles,
      isFallback: isFallback,
      notice: notice,
    );
  }

  ModerationDashboardBundle applyCommand(
    ModerationDashboardBundle bundle,
    ModerationActionCommand command,
  ) {
    var groups = List<ModerationGroup>.from(bundle.groups);
    var posts = List<ModerationPost>.from(bundle.posts);
    var comments = List<ModerationComment>.from(bundle.comments);
    var messages = List<ModerationMessage>.from(bundle.messages);
    var reports = List<ModerationReport>.from(bundle.reports);
    var roleProfiles = List<ModerationRoleProfile>.from(bundle.roleProfiles);

    switch (command.actionType) {
      case ModerationActionType.assignModerators:
        groups = groups
            .map((group) => command.targetIds.contains(group.id)
                ? group.copyWith(
                    moderatorIds: command.userIds,
                    moderatorsCount: command.userIds.length,
                    status: group.status == ModerationStatus.pending
                        ? ModerationStatus.active
                        : group.status,
                  )
                : group)
            .toList(growable: false);
        break;
      case ModerationActionType.updatePermission:
        roleProfiles = roleProfiles
            .map((role) => command.targetIds.contains(role.id)
                ? role.copyWith(
                    permissions: {
                      ...role.permissions,
                      if (command.permissionKey != null)
                        command.permissionKey!: command.permissionEnabled ?? false,
                    },
                  )
                : role)
            .toList(growable: false);
        break;
      case ModerationActionType.ignoreReport:
        reports = reports
            .map((report) => command.targetIds.contains(report.id)
                ? report.copyWith(status: ModerationStatus.ignored)
                : report)
            .toList(growable: false);
        break;
      default:
        posts = _applyPostAction(posts, command);
        comments = _applyCommentAction(comments, command);
        messages = _applyMessageAction(messages, command);
        groups = _applyGroupAction(groups, command);
        reports = _applyReportAction(reports, command);
        break;
    }

    reports = _syncReportsWithContent(
      reports: reports,
      command: command,
      posts: posts,
      comments: comments,
      messages: messages,
      groups: groups,
    );

    return _rebuildBundle(
      groups: groups,
      posts: posts,
      comments: comments,
      messages: messages,
      reports: reports,
      moderators: bundle.moderators,
      permissionScopes: bundle.permissionScopes,
      roleProfiles: roleProfiles,
      isFallback: true,
      notice: 'Local moderation data updated after ${command.actionType.label.toLowerCase()}.',
    );
  }

  ModerationDashboardBundle _rebuildBundle({
    required List<ModerationGroup> groups,
    required List<ModerationPost> posts,
    required List<ModerationComment> comments,
    required List<ModerationMessage> messages,
    required List<ModerationReport> reports,
    required List<ModerationModeratorAccount> moderators,
    required List<ModerationPermissionScope> permissionScopes,
    required List<ModerationRoleProfile> roleProfiles,
    required bool isFallback,
    String? notice,
  }) {
    return ModerationDashboardBundle(
      groups: groups,
      posts: posts,
      comments: comments,
      messages: messages,
      reports: reports,
      moderators: moderators,
      permissionScopes: permissionScopes,
      roleProfiles: roleProfiles,
      notifications: _buildNotifications(reports),
      analytics: _buildAnalytics(groups, posts, comments, messages, reports),
      isFallback: isFallback,
      notice: notice,
    );
  }

  List<ModerationNotificationItem> _buildNotifications(
    List<ModerationReport> reports,
  ) {
    final sortedReports = [...reports]
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    return sortedReports.take(4).map((report) {
      return ModerationNotificationItem(
        id: 'notif-${report.id}',
        title: '${report.contentType} report in ${report.groupName}',
        subtitle: report.reason,
        createdAt: report.createdAt,
        severity: report.status.label,
        isUnread: report.status == ModerationStatus.pending ||
            report.status == ModerationStatus.flagged,
      );
    }).toList(growable: false);
  }

  ModerationAnalytics _buildAnalytics(
    List<ModerationGroup> groups,
    List<ModerationPost> posts,
    List<ModerationComment> comments,
    List<ModerationMessage> messages,
    List<ModerationReport> reports,
  ) {
    final activityTrend = [
      const ModerationTrendPoint(label: 'Mon', value: 12, secondaryValue: 8),
      const ModerationTrendPoint(label: 'Tue', value: 16, secondaryValue: 10),
      const ModerationTrendPoint(label: 'Wed', value: 13, secondaryValue: 9),
      const ModerationTrendPoint(label: 'Thu', value: 18, secondaryValue: 12),
      const ModerationTrendPoint(label: 'Fri', value: 23, secondaryValue: 17),
      ModerationTrendPoint(
        label: 'Sat',
        value: reports.where((report) => report.status != ModerationStatus.ignored).length.toDouble(),
        secondaryValue: posts.where((post) => post.status == ModerationStatus.flagged).length.toDouble(),
      ),
      ModerationTrendPoint(
        label: 'Sun',
        value: comments.where((comment) => comment.status == ModerationStatus.pending).length.toDouble() + 6,
        secondaryValue: messages.where((message) => message.riskScore > 0.7).length.toDouble() + 4,
      ),
    ];

    final reportsByType = <String, double>{};
    for (final report in reports) {
      reportsByType.update(report.contentType, (value) => value + 1, ifAbsent: () => 1);
    }

    final reportsByGroup = <String, double>{};
    for (final report in reports) {
      reportsByGroup.update(report.groupName, (value) => value + 1, ifAbsent: () => 1);
    }

    final reportsByPeriod = <String, double>{
      'Last 24h': reports.where((report) => DateTime.now().difference(report.createdAt).inHours <= 24).length.toDouble(),
      'This week': reports.where((report) => DateTime.now().difference(report.createdAt).inDays <= 7).length.toDouble(),
      'This month': reports.length.toDouble() +
          groups.where((group) => group.flaggedPostsCount > 5).length.toDouble(),
    };

    return ModerationAnalytics(
      activityTrend: activityTrend,
      reportsByType: _buildEntries(reportsByType, const [
        AppColors.primary,
        AppColors.info,
        AppColors.warning,
        AppColors.danger,
      ]),
      reportsByGroup: _buildEntries(reportsByGroup, const [
        AppColors.info,
        AppColors.primary,
        AppColors.secondary,
        AppColors.warning,
      ]),
      reportsByPeriod: _buildEntries(reportsByPeriod, const [
        AppColors.secondary,
        AppColors.primary,
        AppColors.warning,
      ]),
    );
  }

  List<ModerationBreakdownEntry> _buildEntries(
    Map<String, double> map,
    List<Color> colors,
  ) {
    final entries = map.entries.toList(growable: false);
    return List<ModerationBreakdownEntry>.generate(entries.length, (index) {
      final entry = entries[index];
      return ModerationBreakdownEntry(
        label: entry.key,
        value: entry.value,
        color: colors[index % colors.length],
      );
    });
  }

  List<ModerationPost> _applyPostAction(
    List<ModerationPost> posts,
    ModerationActionCommand command,
  ) {
    if (command.targetType != 'post') return posts;
    return posts
        .map((post) => command.targetIds.contains(post.id)
            ? post.copyWith(status: _statusForAction(command.actionType))
            : post)
        .toList(growable: false);
  }

  List<ModerationComment> _applyCommentAction(
    List<ModerationComment> comments,
    ModerationActionCommand command,
  ) {
    if (command.targetType != 'comment') return comments;
    return comments
        .map((comment) => command.targetIds.contains(comment.id)
            ? comment.copyWith(status: _statusForAction(command.actionType))
            : comment)
        .toList(growable: false);
  }

  List<ModerationMessage> _applyMessageAction(
    List<ModerationMessage> messages,
    ModerationActionCommand command,
  ) {
    if (command.targetType != 'message') return messages;
    return messages
        .map((message) => command.targetIds.contains(message.id)
            ? message.copyWith(status: _statusForAction(command.actionType))
            : message)
        .toList(growable: false);
  }

  List<ModerationGroup> _applyGroupAction(
    List<ModerationGroup> groups,
    ModerationActionCommand command,
  ) {
    if (command.targetType != 'group') return groups;
    return groups
        .map((group) => command.targetIds.contains(group.id)
            ? group.copyWith(status: _statusForAction(command.actionType))
            : group)
        .toList(growable: false);
  }

  List<ModerationReport> _applyReportAction(
    List<ModerationReport> reports,
    ModerationActionCommand command,
  ) {
    if (command.targetType != 'report') return reports;
    return reports
        .map((report) => command.targetIds.contains(report.id)
            ? report.copyWith(status: _statusForAction(command.actionType))
            : report)
        .toList(growable: false);
  }

  List<ModerationReport> _syncReportsWithContent({
    required List<ModerationReport> reports,
    required ModerationActionCommand command,
    required List<ModerationPost> posts,
    required List<ModerationComment> comments,
    required List<ModerationMessage> messages,
    required List<ModerationGroup> groups,
  }) {
    if (!const {'post', 'comment', 'message', 'group'}.contains(command.targetType)) {
      return reports;
    }

    final status = switch (command.actionType) {
      ModerationActionType.approve => ModerationStatus.ignored,
      ModerationActionType.warn => ModerationStatus.flagged,
      ModerationActionType.remove || ModerationActionType.deleteContent => ModerationStatus.removed,
      ModerationActionType.banUser || ModerationActionType.suspendUser => ModerationStatus.suspended,
      _ => ModerationStatus.pending,
    };

    return reports
        .map((report) {
          final isLinked = command.targetIds.contains(report.contentId);
          return isLinked ? report.copyWith(status: status) : report;
        })
        .toList(growable: false);
  }

  ModerationStatus _statusForAction(ModerationActionType actionType) {
    return switch (actionType) {
      ModerationActionType.approve => ModerationStatus.approved,
      ModerationActionType.warn => ModerationStatus.flagged,
      ModerationActionType.remove || ModerationActionType.deleteContent =>
        ModerationStatus.removed,
      ModerationActionType.banUser || ModerationActionType.suspendUser =>
        ModerationStatus.suspended,
      ModerationActionType.ignoreReport => ModerationStatus.ignored,
      ModerationActionType.assignModerators => ModerationStatus.active,
      ModerationActionType.updatePermission => ModerationStatus.active,
    };
  }
}
