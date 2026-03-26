import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/forms/app_dropdown_field.dart';
import '../../../shared/forms/app_text_field.dart';
import '../../../shared/models/student.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/filter_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/students_state.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _selectedFilter = 'All students';
  String _selectedDepartment = 'Computer Science';
  String _selectedStatus = 'Active';
  String _selectedLevel = 'Level 4';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, StudentsState>(
      onInit: (store) => store.dispatch(LoadStudentsAction()),
      converter: (store) => store.state.studentsState,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, viewportConstraints) {
            final showSidePanel = viewportConstraints.maxWidth > 1120;
            final content = AsyncStateView(
              status: state.status,
              errorMessage: state.errorMessage,
              onRetry: () => StoreProvider.of<AppState>(
                context,
              ).dispatch(LoadStudentsAction()),
              isEmpty: state.items.isEmpty,
              child: showSidePanel
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _StudentsTableCard(
                            items: state.items,
                            expandTable: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 4,
                          child: SingleChildScrollView(
                            child: _StudentFormCard(
                              selectedDepartment: _selectedDepartment,
                              selectedLevel: _selectedLevel,
                              selectedStatus: _selectedStatus,
                              onDepartmentChanged: (value) => setState(
                                () => _selectedDepartment =
                                    value ?? _selectedDepartment,
                              ),
                              onLevelChanged: (value) => setState(
                                () => _selectedLevel =
                                    value ?? _selectedLevel,
                              ),
                              onStatusChanged: (value) => setState(
                                () => _selectedStatus =
                                    value ?? _selectedStatus,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StudentsTableCard(
                          items: state.items,
                          expandTable: false,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _StudentFormCard(
                          selectedDepartment: _selectedDepartment,
                          selectedLevel: _selectedLevel,
                          selectedStatus: _selectedStatus,
                          onDepartmentChanged: (value) => setState(
                            () =>
                                _selectedDepartment = value ?? _selectedDepartment,
                          ),
                          onLevelChanged: (value) => setState(
                            () => _selectedLevel = value ?? _selectedLevel,
                          ),
                          onStatusChanged: (value) => setState(
                            () => _selectedStatus = value ?? _selectedStatus,
                          ),
                        ),
                      ],
                    ),
            );

            final pageContent = [
              const PageHeader(
                title: 'Students',
                subtitle:
                    'Review enrollment, academic standing, and lifecycle status with a premium management workspace.',
                breadcrumbs: ['Admin', 'Registry', 'Students'],
                actions: [
                  PremiumButton(
                    label: 'Import CSV',
                    icon: Icons.file_upload_outlined,
                    isSecondary: true,
                  ),
                  PremiumButton(
                    label: 'Add student',
                    icon: Icons.person_add_alt_rounded,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: const [
                  _StudentSummaryCard(
                    label: 'Active',
                    value: '12,480',
                    detail: '+312 this week',
                    color: AppColors.primary,
                  ),
                  _StudentSummaryCard(
                    label: 'At risk',
                    value: '184',
                    detail: 'Needs advisor review',
                    color: AppColors.warning,
                  ),
                  _StudentSummaryCard(
                    label: 'Deferred',
                    value: '38',
                    detail: 'Pending documents',
                    color: AppColors.info,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FilterBar(
                searchHint: 'Search student name, email, ID, section',
                filters: const [
                  'All students',
                  'Top performers',
                  'At risk',
                  'New intake',
                ],
                selectedFilter: _selectedFilter,
                onFilterSelected: (value) =>
                    setState(() => _selectedFilter = value),
                trailing: const [
                  PremiumButton(
                    label: 'Filters',
                    icon: Icons.filter_alt_outlined,
                    isSecondary: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ];

            if (showSidePanel) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...pageContent,
                  Expanded(child: content),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...pageContent,
                  content,
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StudentsTableCard extends StatelessWidget {
  const _StudentsTableCard({
    required this.items,
    this.expandTable = true,
  });

  final List<Student> items;
  final bool expandTable;

  @override
  Widget build(BuildContext context) {
    final table = AdminDataTable<Student>(
      items: items,
      shrinkWrap: !expandTable,
      physics: expandTable ? null : const NeverScrollableScrollPhysics(),
      columns: [
        AdminTableColumn<Student>(
          label: 'Student',
          cellBuilder: (item) => _IdentityCell(
            title: item.name,
            subtitle: item.id,
            icon: Icons.person_outline_rounded,
          ),
        ),
        AdminTableColumn<Student>(
          label: 'Contact',
          cellBuilder: (item) => _StackedCell(
            primary: item.email,
            secondary: '${item.enrolledSubjects} active subjects',
          ),
        ),
        AdminTableColumn<Student>(
          label: 'Academic',
          cellBuilder: (item) => _StackedCell(
            primary: '${item.department}  ${item.level}',
            secondary: item.section,
          ),
        ),
        AdminTableColumn<Student>(
          label: 'Performance',
          cellBuilder: (item) => _PerformanceCell(student: item),
        ),
        AdminTableColumn<Student>(
          label: 'Actions',
          cellBuilder: (item) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusBadge(item.status),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
        ),
      ],
    );

    return AppCard(
      child: Column(
        mainAxisSize: expandTable ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student registry',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Compact academic records, engagement, and status control.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const StatusBadge('Synced', icon: Icons.cloud_done_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (expandTable) Expanded(child: table) else table,
        ],
      ),
    );
  }
}

class _StudentFormCard extends StatelessWidget {
  const _StudentFormCard({
    required this.selectedDepartment,
    required this.selectedLevel,
    required this.selectedStatus,
    required this.onDepartmentChanged,
    required this.onLevelChanged,
    required this.onStatusChanged,
  });

  final String selectedDepartment;
  final String selectedLevel;
  final String selectedStatus;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onLevelChanged;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add / Edit student',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Premium form layout for quick registry updates and clean profile setup.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppTextField(
            label: 'Full name',
            initialValue: 'Mariam Tarek',
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Email',
            initialValue: 'mariam.tarek@tolab.edu',
            prefixIcon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Student ID',
            initialValue: 'ST-1028',
            prefixIcon: Icons.badge_outlined,
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
          Row(
            children: [
              Expanded(
                child: AppDropdownField<String>(
                  label: 'Level',
                  value: selectedLevel,
                  onChanged: onLevelChanged,
                  items: const [
                    AppDropdownItem(value: 'Level 1', label: 'Level 1'),
                    AppDropdownItem(value: 'Level 2', label: 'Level 2'),
                    AppDropdownItem(value: 'Level 3', label: 'Level 3'),
                    AppDropdownItem(value: 'Level 4', label: 'Level 4'),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppDropdownField<String>(
                  label: 'Status',
                  value: selectedStatus,
                  onChanged: onStatusChanged,
                  items: const [
                    AppDropdownItem(value: 'Active', label: 'Active'),
                    AppDropdownItem(value: 'Pending', label: 'Pending'),
                    AppDropdownItem(value: 'Inactive', label: 'Inactive'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Advisor notes',
            initialValue:
                'High-performing student with strong attendance and clean moderation history.',
            maxLines: 4,
            hint: 'Optional notes',
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondarySoft.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Suggested section placement: CS-4A based on current seat availability.',
                    style: Theme.of(context).textTheme.bodySmall,
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
                  label: 'Save draft',
                  icon: Icons.save_outlined,
                  isSecondary: true,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PremiumButton(
                  label: 'Publish profile',
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

class _StudentSummaryCard extends StatelessWidget {
  const _StudentSummaryCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            detail,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _IdentityCell extends StatelessWidget {
  const _IdentityCell({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _StackedCell extends StatelessWidget {
  const _StackedCell({required this.primary, required this.secondary});

  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(primary, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 2),
        Text(secondary, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PerformanceCell extends StatelessWidget {
  const _PerformanceCell({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final fill = (student.gpa / 4).clamp(0, 1).toDouble();

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'GPA ${student.gpa.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: fill,
              backgroundColor: AppColors.slateSoft.withValues(alpha: 0.6),
              valueColor: AlwaysStoppedAnimation<Color>(
                fill > 0.8 ? AppColors.secondary : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
