import '../../../../state/app_state.dart';
import '../../models/moderation_models.dart';
import '../models/moderation_state_models.dart';

ModerationState selectModerationState(AppState state) => state.moderationState;

ModerationMetrics selectModerationMetrics(AppState state) {
  final moderationState = state.moderationState;
  final openReports = moderationState.reports
      .where(
        (report) =>
            report.status == ModerationStatus.pending ||
            report.status == ModerationStatus.flagged,
      )
      .length;
  final flaggedMessages = moderationState.messages
      .where(
        (message) =>
            message.status == ModerationStatus.flagged || message.riskScore > 0.8,
      )
      .length;
  final restrictedGroups = moderationState.groups
      .where((group) => group.status == ModerationStatus.restricted)
      .length;
  final pendingActions = moderationState.posts
          .where((post) => post.status == ModerationStatus.pending)
          .length +
      moderationState.comments
          .where((comment) => comment.status == ModerationStatus.pending)
          .length +
      moderationState.reports
          .where((report) => report.status == ModerationStatus.pending)
          .length;

  return ModerationMetrics(
    openReports: openReports,
    flaggedMessages: flaggedMessages,
    restrictedGroups: restrictedGroups,
    pendingActions: pendingActions,
  );
}

List<ModerationNotificationItem> selectUnreadNotifications(AppState state) {
  return state.moderationState.notifications
      .where((notification) => notification.isUnread)
      .toList(growable: false);
}

ModerationPageSlice<ModerationGroup> selectGroupsPage(AppState state) {
  final moderationState = state.moderationState;
  final filtered = moderationState.groups.where((group) {
    return _matchesSearch(
          moderationState.groupsQuery.searchQuery,
          [
            group.name,
            group.description,
            group.category,
            group.status.label,
          ],
        ) &&
        _matchesStatus(moderationState.groupsQuery.statusFilter, group.status) &&
        _matchesSecondary(
          moderationState.groupsQuery.secondaryFilter,
          group.category,
        ) &&
        _matchesDate(
          moderationState.groupsQuery.dateFilter,
          group.lastActivityAt,
        );
  }).toList(growable: false)
    ..sort((left, right) {
      final compare = switch (moderationState.groupsQuery.sortKey) {
        'members' => left.memberCount.compareTo(right.memberCount),
        'reports' => left.flaggedPostsCount.compareTo(right.flaggedPostsCount),
        'name' => left.name.compareTo(right.name),
        _ => left.lastActivityAt.compareTo(right.lastActivityAt),
      };
      return moderationState.groupsQuery.ascending ? compare : -compare;
    });
  return _slice(
    items: filtered,
    query: moderationState.groupsQuery,
    idOf: (group) => group.id,
  );
}

ModerationPageSlice<ModerationPost> selectPostsPage(AppState state) {
  final moderationState = state.moderationState;
  final filtered = moderationState.posts.where((post) {
    return _matchesSearch(
          moderationState.postsQuery.searchQuery,
          [post.title, post.bodyPreview, post.authorName, post.groupName],
        ) &&
        _matchesStatus(moderationState.postsQuery.statusFilter, post.status) &&
        _matchesSecondary(
          moderationState.postsQuery.secondaryFilter,
          post.groupName,
        ) &&
        _matchesDate(moderationState.postsQuery.dateFilter, post.createdAt);
  }).toList(growable: false)
    ..sort((left, right) {
      final compare = switch (moderationState.postsQuery.sortKey) {
        'reports' => left.reportsCount.compareTo(right.reportsCount),
        'title' => left.title.compareTo(right.title),
        'author' => left.authorName.compareTo(right.authorName),
        _ => left.createdAt.compareTo(right.createdAt),
      };
      return moderationState.postsQuery.ascending ? compare : -compare;
    });
  return _slice(
    items: filtered,
    query: moderationState.postsQuery,
    idOf: (post) => post.id,
  );
}

ModerationPageSlice<ModerationComment> selectCommentsPage(AppState state) {
  final moderationState = state.moderationState;
  final filtered = moderationState.comments.where((comment) {
    return _matchesSearch(
          moderationState.commentsQuery.searchQuery,
          [comment.content, comment.authorName, comment.postTitle],
        ) &&
        _matchesStatus(
          moderationState.commentsQuery.statusFilter,
          comment.status,
        ) &&
        _matchesSecondary(
          moderationState.commentsQuery.secondaryFilter,
          comment.postTitle,
        ) &&
        _matchesDate(moderationState.commentsQuery.dateFilter, comment.createdAt);
  }).toList(growable: false)
    ..sort((left, right) {
      final compare = switch (moderationState.commentsQuery.sortKey) {
        'reports' => left.reportsCount.compareTo(right.reportsCount),
        'author' => left.authorName.compareTo(right.authorName),
        _ => left.createdAt.compareTo(right.createdAt),
      };
      return moderationState.commentsQuery.ascending ? compare : -compare;
    });
  return _slice(
    items: filtered,
    query: moderationState.commentsQuery,
    idOf: (comment) => comment.id,
  );
}

ModerationPageSlice<ModerationMessage> selectMessagesPage(AppState state) {
  final moderationState = state.moderationState;
  final filtered = moderationState.messages.where((message) {
    return _matchesSearch(
          moderationState.messagesQuery.searchQuery,
          [message.senderName, message.receiverName, message.content],
        ) &&
        _matchesStatus(
          moderationState.messagesQuery.statusFilter,
          message.status,
        ) &&
        _matchesSecondary(
          moderationState.messagesQuery.secondaryFilter,
          message.riskScore >= 0.8 ? 'High risk' : 'Review',
        ) &&
        _matchesDate(moderationState.messagesQuery.dateFilter, message.createdAt);
  }).toList(growable: false)
    ..sort((left, right) {
      final compare = switch (moderationState.messagesQuery.sortKey) {
        'sender' => left.senderName.compareTo(right.senderName),
        'receiver' => left.receiverName.compareTo(right.receiverName),
        'createdAt' => left.createdAt.compareTo(right.createdAt),
        _ => left.riskScore.compareTo(right.riskScore),
      };
      return moderationState.messagesQuery.ascending ? compare : -compare;
    });
  return _slice(
    items: filtered,
    query: moderationState.messagesQuery,
    idOf: (message) => message.id,
  );
}

ModerationPageSlice<ModerationReport> selectReportsPage(AppState state) {
  final moderationState = state.moderationState;
  final filtered = moderationState.reports.where((report) {
    return _matchesSearch(
          moderationState.reportsQuery.searchQuery,
          [
            report.subjectTitle,
            report.contentPreview,
            report.reason,
            report.reporterName,
            report.groupName,
          ],
        ) &&
        _matchesStatus(
          moderationState.reportsQuery.statusFilter,
          report.status,
        ) &&
        _matchesSecondary(
          moderationState.reportsQuery.secondaryFilter,
          report.contentType,
        ) &&
        _matchesDate(moderationState.reportsQuery.dateFilter, report.createdAt);
  }).toList(growable: false)
    ..sort((left, right) {
      final compare = switch (moderationState.reportsQuery.sortKey) {
        'type' => left.contentType.compareTo(right.contentType),
        'reporter' => left.reporterName.compareTo(right.reporterName),
        _ => left.createdAt.compareTo(right.createdAt),
      };
      return moderationState.reportsQuery.ascending ? compare : -compare;
    });
  return _slice(
    items: filtered,
    query: moderationState.reportsQuery,
    idOf: (report) => report.id,
  );
}

ModerationPageSlice<T> _slice<T>({
  required List<T> items,
  required ModerationTableQuery query,
  required String Function(T item) idOf,
}) {
  final totalItems = items.length;
  final totalPages = totalItems == 0 ? 1 : (totalItems / query.pageSize).ceil();
  final currentPage = query.page.clamp(1, totalPages).toInt();
  final start = ((currentPage - 1) * query.pageSize).clamp(0, totalItems).toInt();
  final end = (start + query.pageSize).clamp(0, totalItems).toInt();
  final pageItems = totalItems == 0 ? <T>[] : items.sublist(start, end);
  return ModerationPageSlice<T>(
    items: pageItems,
    totalItems: totalItems,
    page: currentPage,
    totalPages: totalPages,
    visibleIds: pageItems.map(idOf).toList(growable: false),
  );
}

bool _matchesSearch(String query, List<String> haystack) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return true;
  return haystack.any((value) => value.toLowerCase().contains(normalized));
}

bool _matchesStatus(String filter, ModerationStatus status) {
  if (filter == 'All') return true;
  return status.label.toLowerCase() == filter.toLowerCase();
}

bool _matchesSecondary(String filter, String value) {
  if (filter == 'All') return true;
  return value.toLowerCase() == filter.toLowerCase();
}

bool _matchesDate(String filter, DateTime value) {
  if (filter == 'Any time') return true;
  final now = DateTime.now();
  return switch (filter) {
    'Today' => now.difference(value).inDays < 1,
    'Last 7 days' => now.difference(value).inDays < 7,
    'Last 30 days' => now.difference(value).inDays < 30,
    _ => true,
  };
}
