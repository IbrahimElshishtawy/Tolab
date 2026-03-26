import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/forms/app_dropdown_field.dart';
import '../../../shared/forms/app_text_field.dart';
import '../../../shared/models/staff_member.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/filter_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/staff_state.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  String _selectedFilter = 'All roles';
  String _selectedRole = 'Doctor';
  String _selectedDepartment = 'Computer Science';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, StaffState>(
      onInit: (store) => store.dispatch(LoadStaffAction()),
      converter: (store) => store.state.staffState,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Staff',
              subtitle:
                  'Manage doctors, assistants, teaching load, and internal role distribution with a polished staffing workspace.',
              breadcrumbs: ['Admin', 'People', 'Staff'],
              actions: [
                PremiumButton(
                  label: 'Bulk assign',
                  icon: Icons.layers_outlined,
                  isSecondary: true,
                ),
                PremiumButton(
                  label: 'Invite staff',
                  icon: Icons.person_add_alt_1_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            FilterBar(
              searchHint: 'Search doctor, assistant, email, department',
              filters: const ['All roles', 'Doctors', 'Assistants', 'Blocked'],
              selectedFilter: _selectedFilter,
              onFilterSelected: (value) =>
                  setState(() => _selectedFilter = value),
              trailing: const [
                PremiumButton(
                  label: 'Departments',
                  icon: Icons.apartment_outlined,
                  isSecondary: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AsyncStateView(
                status: state.status,
                errorMessage: state.errorMessage,
                onRetry: () => StoreProvider.of<AppState>(
                  context,
                ).dispatch(LoadStaffAction()),
                isEmpty: state.items.isEmpty,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showSidePanel = constraints.maxWidth > 1180;

                    return showSidePanel
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _StaffGrid(items: state.items),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 4,
                                child: SingleChildScrollView(
                                  child: _StaffDetailsPanel(
                                    selectedRole: _selectedRole,
                                    selectedDepartment: _selectedDepartment,
                                    onRoleChanged: (value) => setState(
                                      () =>
                                          _selectedRole = value ?? _selectedRole,
                                    ),
                                    onDepartmentChanged: (value) => setState(
                                      () => _selectedDepartment =
                                          value ?? _selectedDepartment,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StaffGrid(
                                  items: state.items,
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _StaffDetailsPanel(
                                  selectedRole: _selectedRole,
                                  selectedDepartment: _selectedDepartment,
                                  onRoleChanged: (value) => setState(
                                    () =>
                                        _selectedRole = value ?? _selectedRole,
                                  ),
                                  onDepartmentChanged: (value) => setState(
                                    () => _selectedDepartment =
                                        value ?? _selectedDepartment,
                                  ),
                                ),
                              ],
                            ),
                          );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StaffGrid extends StatelessWidget {
  const _StaffGrid({
    required this.items,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<StaffMember> items;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 980
            ? 3
            : constraints.maxWidth > 640
            ? 2
            : 1;

        return AnimationLimiter(
          child: GridView.builder(
            shrinkWrap: shrinkWrap,
            primary: physics == null,
            physics: physics,
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.12,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                columnCount: crossAxisCount,
                duration: const Duration(milliseconds: 340),
                child: ScaleAnimation(child: _StaffCard(item: item)),
              );
            },
          ),
        );
      },
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.item});

  final StaffMember item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      interactive: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  item.name.characters.first.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                ),
              ),
              const Spacer(),
              StatusBadge(item.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(item.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(item.email, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              StatusBadge(item.title),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.department,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.infoSoft.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_stories_rounded, color: AppColors.info),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${item.subjects} assigned subjects',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(
                child: PremiumButton(
                  label: 'Message',
                  icon: Icons.chat_bubble_outline_rounded,
                  isSecondary: true,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PremiumButton(label: 'Edit', icon: Icons.edit_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffDetailsPanel extends StatelessWidget {
  const _StaffDetailsPanel({
    required this.selectedRole,
    required this.selectedDepartment,
    required this.onRoleChanged,
    required this.onDepartmentChanged,
  });

  final String selectedRole;
  final String selectedDepartment;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onDepartmentChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Staff action panel',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Create or update internal staff assignments with clear role and subject ownership.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppTextField(
            label: 'Full name',
            initialValue: 'Dr. Hadeer Salah',
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Email',
            initialValue: 'hadeer.salah@tolab.edu',
            prefixIcon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdownField<String>(
            label: 'Role',
            value: selectedRole,
            onChanged: onRoleChanged,
            items: const [
              AppDropdownItem(value: 'Doctor', label: 'Doctor'),
              AppDropdownItem(value: 'Assistant', label: 'Assistant'),
              AppDropdownItem(value: 'Moderator', label: 'Moderator'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdownField<String>(
            label: 'Department',
            value: selectedDepartment,
            onChanged: onDepartmentChanged,
            items: const [
              AppDropdownItem(
                value: 'Computer Science',
                label: 'Computer Science',
              ),
              AppDropdownItem(
                value: 'Information Systems',
                label: 'Information Systems',
              ),
              AppDropdownItem(value: 'Engineering', label: 'Engineering'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Assigned subjects',
            initialValue: 'Advanced Algorithms, Data Structures',
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondarySoft.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InlineKpi(label: 'Avg load', value: '3.6'),
                SizedBox(height: AppSpacing.sm),
                _InlineKpi(label: 'Active sections', value: '12'),
                SizedBox(height: AppSpacing.sm),
                _InlineKpi(label: 'Pending reviews', value: '4'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(
                child: PremiumButton(
                  label: 'Suspend',
                  icon: Icons.pause_circle_outline_rounded,
                  isSecondary: true,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PremiumButton(
                  label: 'Save staff',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineKpi extends StatelessWidget {
  const _InlineKpi({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
