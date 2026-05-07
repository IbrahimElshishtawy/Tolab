import 'package:flutter/material.dart';
import 'package:tolab_fci/core/theme/app_theme.dart';
import 'package:tolab_fci/core/utils/responsive_helper.dart';
import 'package:tolab_fci/core/widgets/responsive_widgets.dart';
import 'package:tolab_fci/domain/entities/user_entity.dart';
import 'package:tolab_fci/mock/fixtures/mock_users.dart';
import 'package:tolab_fci/mock/fixtures/mock_students.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late List<UserEntity> users;
  late List<UserEntity> filteredUsers;
  String _searchQuery = '';
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    users = MockUsers.getAllUsers();
    _applyFilters();
  }

  void _applyFilters() {
    filteredUsers = users.where((user) {
      final matchesSearch = user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRole == null || user.role == _selectedRole;
      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: 'Users',
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add User'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchAndFilters(context),
            const SizedBox(height: AppSpacing.xl),
            _buildUsersList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Users',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        ResponsiveLayout(
          mobile: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: AppSpacing.md),
              _buildRoleFilter(),
            ],
          ),
          tablet: Row(
            children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildRoleFilter()),
            ],
          ),
          desktop: Row(
            children: [
              Expanded(flex: 2, child: _buildSearchField()),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildRoleFilter()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _applyFilters();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search by name or email...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _applyFilters();
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildRoleFilter() {
    return DropdownButtonFormField<UserRole?>(
      value: _selectedRole,
      decoration: const InputDecoration(labelText: 'Filter by Role'),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Roles')),
        ...UserRole.values.map(
          (role) => DropdownMenuItem(
            value: role,
            child: Text(role.toString().split('.').last),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRole = value;
          _applyFilters();
        });
      },
    );
  }

  Widget _buildUsersList(BuildContext context) {
    if (filteredUsers.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: 'No users found',
        subtitle: 'Try adjusting your search or filters',
      );
    }

    return ResponsiveLayout(
      mobile: _buildMobileList(),
      tablet: _buildTabletList(context),
      desktop: _buildDesktopTable(context),
    );
  }

  Widget _buildMobileList() {
    return Column(
      children: filteredUsers.map((user) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ResponsiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      initials: '${user.firstName[0]}${user.lastName[0]}',
                      imageUrl: user.profileImageUrl,
                      size: 48,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRoleBadge(user.role),
                    _buildStatusBadge(user.isActive),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabletList(BuildContext context) {
    return Column(
      children: filteredUsers.map((user) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ResponsiveCard(
            child: Row(
              children: [
                UserAvatar(
                  initials: '${user.firstName[0]}${user.lastName[0]}',
                  imageUrl: user.profileImageUrl,
                  size: 48,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildRoleBadge(user.role),
                const SizedBox(width: AppSpacing.md),
                _buildStatusBadge(user.isActive),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    return ResponsiveCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Joined')),
            DataColumn(label: Text('Actions')),
          ],
          rows: filteredUsers.map((user) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      UserAvatar(
                        initials: '${user.firstName[0]}${user.lastName[0]}',
                        imageUrl: user.profileImageUrl,
                        size: 32,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(user.fullName),
                    ],
                  ),
                ),
                DataCell(Text(user.email)),
                DataCell(_buildRoleBadge(user.role)),
                DataCell(_buildStatusBadge(user.isActive)),
                DataCell(
                  Text(
                    '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final roleString = role.toString().split('.').last;
    final colors = {
      'superAdmin': (AppColors.error, AppColors.error.withOpacity(0.1)),
      'admin': (AppColors.accent, AppColors.accentLight),
      'doctor': (AppColors.primary, AppColors.primaryLight),
      'staff': (AppColors.secondary, AppColors.secondaryLight),
      'student': (AppColors.info, const Color(0xFFDEF7FF)),
    };

    final (color, bgColor) = colors[roleString] ?? (AppColors.textSecondary, AppColors.surfaceVariant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        roleString,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondaryLight : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.secondary : AppColors.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActive ? AppColors.secondary : AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
