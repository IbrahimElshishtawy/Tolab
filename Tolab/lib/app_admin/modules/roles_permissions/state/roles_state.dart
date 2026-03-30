import '../../../shared/enums/load_status.dart';
import '../models/permission_model.dart';
import '../models/role_model.dart';

enum RolesDashboardView { roles, matrix }

enum RolesSortOption {
  alphabetical,
  mostMembers,
  mostPermissions,
  recentlyUpdated,
}

extension RolesSortOptionX on RolesSortOption {
  String get label => switch (this) {
    RolesSortOption.alphabetical => 'Alphabetical',
    RolesSortOption.mostMembers => 'Most members',
    RolesSortOption.mostPermissions => 'Most permissions',
    RolesSortOption.recentlyUpdated => 'Recently updated',
  };
}

class RolesFilters {
  const RolesFilters({
    this.searchQuery = '',
    this.moduleFilter,
    this.sortOption = RolesSortOption.mostMembers,
    this.showSystemRoles = true,
  });

  final String searchQuery;
  final String? moduleFilter;
  final RolesSortOption sortOption;
  final bool showSystemRoles;

  RolesFilters copyWith({
    String? searchQuery,
    String? moduleFilter,
    bool clearModuleFilter = false,
    RolesSortOption? sortOption,
    bool? showSystemRoles,
  }) {
    return RolesFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      moduleFilter: clearModuleFilter
          ? null
          : moduleFilter ?? this.moduleFilter,
      sortOption: sortOption ?? this.sortOption,
      showSystemRoles: showSystemRoles ?? this.showSystemRoles,
    );
  }
}

class RolesState {
  const RolesState({
    this.status = LoadStatus.initial,
    this.mutationStatus = LoadStatus.initial,
    this.roleEntities = const <String, RoleModel>{},
    this.orderedRoleIds = const <String>[],
    this.permissionEntities = const <String, PermissionModel>{},
    this.orderedPermissionIds = const <String>[],
    this.assignableUsers = const <RoleUserAssignment>[],
    this.filters = const RolesFilters(),
    this.view = RolesDashboardView.roles,
    this.pendingPermissionKeys = const <String>{},
    this.pendingUserKeys = const <String>{},
    this.isUsingFallbackData = false,
    this.selectedRoleId,
    this.errorMessage,
    this.feedbackMessage,
    this.lastSyncedAt,
  });

  final LoadStatus status;
  final LoadStatus mutationStatus;
  final Map<String, RoleModel> roleEntities;
  final List<String> orderedRoleIds;
  final Map<String, PermissionModel> permissionEntities;
  final List<String> orderedPermissionIds;
  final List<RoleUserAssignment> assignableUsers;
  final RolesFilters filters;
  final RolesDashboardView view;
  final Set<String> pendingPermissionKeys;
  final Set<String> pendingUserKeys;
  final bool isUsingFallbackData;
  final String? selectedRoleId;
  final String? errorMessage;
  final String? feedbackMessage;
  final DateTime? lastSyncedAt;

  RolesState copyWith({
    LoadStatus? status,
    LoadStatus? mutationStatus,
    Map<String, RoleModel>? roleEntities,
    List<String>? orderedRoleIds,
    Map<String, PermissionModel>? permissionEntities,
    List<String>? orderedPermissionIds,
    List<RoleUserAssignment>? assignableUsers,
    RolesFilters? filters,
    RolesDashboardView? view,
    Set<String>? pendingPermissionKeys,
    Set<String>? pendingUserKeys,
    bool? isUsingFallbackData,
    String? selectedRoleId,
    bool clearSelectedRoleId = false,
    String? errorMessage,
    bool clearError = false,
    String? feedbackMessage,
    bool clearFeedback = false,
    DateTime? lastSyncedAt,
    bool clearBusyPermissionKeys = false,
    bool clearBusyUserKeys = false,
  }) {
    return RolesState(
      status: status ?? this.status,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      roleEntities: Map<String, RoleModel>.unmodifiable(
        roleEntities ?? this.roleEntities,
      ),
      orderedRoleIds: List<String>.unmodifiable(
        orderedRoleIds ?? this.orderedRoleIds,
      ),
      permissionEntities: Map<String, PermissionModel>.unmodifiable(
        permissionEntities ?? this.permissionEntities,
      ),
      orderedPermissionIds: List<String>.unmodifiable(
        orderedPermissionIds ?? this.orderedPermissionIds,
      ),
      assignableUsers: List<RoleUserAssignment>.unmodifiable(
        assignableUsers ?? this.assignableUsers,
      ),
      filters: filters ?? this.filters,
      view: view ?? this.view,
      pendingPermissionKeys: Set<String>.unmodifiable(
        clearBusyPermissionKeys
            ? const <String>{}
            : pendingPermissionKeys ?? this.pendingPermissionKeys,
      ),
      pendingUserKeys: Set<String>.unmodifiable(
        clearBusyUserKeys
            ? const <String>{}
            : pendingUserKeys ?? this.pendingUserKeys,
      ),
      isUsingFallbackData: isUsingFallbackData ?? this.isUsingFallbackData,
      selectedRoleId: clearSelectedRoleId
          ? null
          : selectedRoleId ?? this.selectedRoleId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      feedbackMessage: clearFeedback
          ? null
          : feedbackMessage ?? this.feedbackMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

const initialRolesState = RolesState();
