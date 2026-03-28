import '../../../../shared/enums/load_status.dart';
import '../../models/moderation_models.dart';

class ModerationTableQuery {
  const ModerationTableQuery({
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.secondaryFilter = 'All',
    this.dateFilter = 'Any time',
    this.sortKey = 'createdAt',
    this.ascending = false,
    this.page = 1,
    this.pageSize = 8,
  });

  final String searchQuery;
  final String statusFilter;
  final String secondaryFilter;
  final String dateFilter;
  final String sortKey;
  final bool ascending;
  final int page;
  final int pageSize;

  ModerationTableQuery copyWith({
    String? searchQuery,
    String? statusFilter,
    String? secondaryFilter,
    String? dateFilter,
    String? sortKey,
    bool? ascending,
    int? page,
    int? pageSize,
    bool resetPage = false,
  }) {
    return ModerationTableQuery(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      secondaryFilter: secondaryFilter ?? this.secondaryFilter,
      dateFilter: dateFilter ?? this.dateFilter,
      sortKey: sortKey ?? this.sortKey,
      ascending: ascending ?? this.ascending,
      page: resetPage ? 1 : page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class ModerationPageSlice<T> {
  const ModerationPageSlice({
    required this.items,
    required this.totalItems,
    required this.page,
    required this.totalPages,
    required this.visibleIds,
  });

  final List<T> items;
  final int totalItems;
  final int page;
  final int totalPages;
  final List<String> visibleIds;
}

class ModerationMetrics {
  const ModerationMetrics({
    required this.openReports,
    required this.flaggedMessages,
    required this.restrictedGroups,
    required this.pendingActions,
  });

  final int openReports;
  final int flaggedMessages;
  final int restrictedGroups;
  final int pendingActions;
}

class ModerationState {
  const ModerationState({
    this.status = LoadStatus.initial,
    this.mutationStatus = LoadStatus.initial,
    this.notificationsStatus = LoadStatus.initial,
    this.activeTab = ModerationWorkspaceTab.groups,
    this.groups = const <ModerationGroup>[],
    this.posts = const <ModerationPost>[],
    this.comments = const <ModerationComment>[],
    this.messages = const <ModerationMessage>[],
    this.reports = const <ModerationReport>[],
    this.moderators = const <ModerationModeratorAccount>[],
    this.permissionScopes = const <ModerationPermissionScope>[],
    this.roleProfiles = const <ModerationRoleProfile>[],
    this.notifications = const <ModerationNotificationItem>[],
    this.analytics = const ModerationAnalytics(
      activityTrend: <ModerationTrendPoint>[],
      reportsByType: <ModerationBreakdownEntry>[],
      reportsByGroup: <ModerationBreakdownEntry>[],
      reportsByPeriod: <ModerationBreakdownEntry>[],
    ),
    this.groupsQuery = const ModerationTableQuery(sortKey: 'lastActivityAt'),
    this.postsQuery = const ModerationTableQuery(sortKey: 'createdAt'),
    this.commentsQuery = const ModerationTableQuery(sortKey: 'createdAt'),
    this.messagesQuery = const ModerationTableQuery(sortKey: 'riskScore'),
    this.reportsQuery = const ModerationTableQuery(sortKey: 'createdAt'),
    this.selectedGroupIds = const <String>{},
    this.selectedPostIds = const <String>{},
    this.selectedCommentIds = const <String>{},
    this.selectedMessageIds = const <String>{},
    this.selectedReportIds = const <String>{},
    this.isUsingFallbackData = false,
    this.isPollingNotifications = false,
    this.errorMessage,
    this.feedbackMessage,
    this.lastSyncedAt,
  });

  final LoadStatus status;
  final LoadStatus mutationStatus;
  final LoadStatus notificationsStatus;
  final ModerationWorkspaceTab activeTab;
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
  final ModerationTableQuery groupsQuery;
  final ModerationTableQuery postsQuery;
  final ModerationTableQuery commentsQuery;
  final ModerationTableQuery messagesQuery;
  final ModerationTableQuery reportsQuery;
  final Set<String> selectedGroupIds;
  final Set<String> selectedPostIds;
  final Set<String> selectedCommentIds;
  final Set<String> selectedMessageIds;
  final Set<String> selectedReportIds;
  final bool isUsingFallbackData;
  final bool isPollingNotifications;
  final String? errorMessage;
  final String? feedbackMessage;
  final DateTime? lastSyncedAt;

  ModerationState copyWith({
    LoadStatus? status,
    LoadStatus? mutationStatus,
    LoadStatus? notificationsStatus,
    ModerationWorkspaceTab? activeTab,
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
    ModerationTableQuery? groupsQuery,
    ModerationTableQuery? postsQuery,
    ModerationTableQuery? commentsQuery,
    ModerationTableQuery? messagesQuery,
    ModerationTableQuery? reportsQuery,
    Set<String>? selectedGroupIds,
    Set<String>? selectedPostIds,
    Set<String>? selectedCommentIds,
    Set<String>? selectedMessageIds,
    Set<String>? selectedReportIds,
    bool? isUsingFallbackData,
    bool? isPollingNotifications,
    String? errorMessage,
    bool clearError = false,
    String? feedbackMessage,
    bool clearFeedback = false,
    DateTime? lastSyncedAt,
    bool clearSelection = false,
  }) {
    return ModerationState(
      status: status ?? this.status,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      notificationsStatus: notificationsStatus ?? this.notificationsStatus,
      activeTab: activeTab ?? this.activeTab,
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
      groupsQuery: groupsQuery ?? this.groupsQuery,
      postsQuery: postsQuery ?? this.postsQuery,
      commentsQuery: commentsQuery ?? this.commentsQuery,
      messagesQuery: messagesQuery ?? this.messagesQuery,
      reportsQuery: reportsQuery ?? this.reportsQuery,
      selectedGroupIds: Set<String>.unmodifiable(
        clearSelection ? const <String>{} : selectedGroupIds ?? this.selectedGroupIds,
      ),
      selectedPostIds: Set<String>.unmodifiable(
        clearSelection ? const <String>{} : selectedPostIds ?? this.selectedPostIds,
      ),
      selectedCommentIds: Set<String>.unmodifiable(
        clearSelection ? const <String>{} : selectedCommentIds ?? this.selectedCommentIds,
      ),
      selectedMessageIds: Set<String>.unmodifiable(
        clearSelection ? const <String>{} : selectedMessageIds ?? this.selectedMessageIds,
      ),
      selectedReportIds: Set<String>.unmodifiable(
        clearSelection ? const <String>{} : selectedReportIds ?? this.selectedReportIds,
      ),
      isUsingFallbackData: isUsingFallbackData ?? this.isUsingFallbackData,
      isPollingNotifications: isPollingNotifications ?? this.isPollingNotifications,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      feedbackMessage: clearFeedback
          ? null
          : feedbackMessage ?? this.feedbackMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  ModerationTableQuery queryFor(ModerationSectionKey section) {
    return switch (section) {
      ModerationSectionKey.groups => groupsQuery,
      ModerationSectionKey.posts => postsQuery,
      ModerationSectionKey.comments => commentsQuery,
      ModerationSectionKey.messages => messagesQuery,
      ModerationSectionKey.reports => reportsQuery,
    };
  }

  Set<String> selectedIdsFor(ModerationSectionKey section) {
    return switch (section) {
      ModerationSectionKey.groups => selectedGroupIds,
      ModerationSectionKey.posts => selectedPostIds,
      ModerationSectionKey.comments => selectedCommentIds,
      ModerationSectionKey.messages => selectedMessageIds,
      ModerationSectionKey.reports => selectedReportIds,
    };
  }
}

const initialModerationState = ModerationState();
