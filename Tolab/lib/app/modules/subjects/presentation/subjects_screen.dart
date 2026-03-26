import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/forms/app_dropdown_field.dart';
import '../../../shared/forms/app_text_field.dart';
import '../../../shared/models/academic_models.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/filter_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/subjects_state.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String _selectedDepartment = 'Computer Science';
  String _selectedStatus = 'Active';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SubjectsState>(
      onInit: (store) => store.dispatch(LoadSubjectsAction()),
      converter: (store) => store.state.subjectsState,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Subjects',
              subtitle:
                  'Create and manage subject metadata, credits, and academic ownership using a modern CRUD-oriented layout.',
              breadcrumbs: ['Admin', 'Academic', 'Subjects'],
              actions: [
                PremiumButton(
                  label: 'Duplicate',
                  icon: Icons.copy_all_outlined,
                  isSecondary: true,
                ),
                PremiumButton(
                  label: 'Add subject',
                  icon: Icons.auto_stories_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            FilterBar(
              searchHint: 'Search subject code, name, department',
              filters: const ['All subjects', 'Core', 'Elective', 'Archived'],
              selectedFilter: 'All subjects',
              trailing: const [
                PremiumButton(
                  label: 'Credit map',
                  icon: Icons.grid_view_rounded,
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
                ).dispatch(LoadSubjectsAction()),
                isEmpty: state.items.isEmpty,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showSidePanel = constraints.maxWidth > 1100;

                    return showSidePanel
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _SubjectsTable(items: state.items),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 4,
                                child: _SubjectFormCard(
                                  selectedDepartment: _selectedDepartment,
                                  selectedStatus: _selectedStatus,
                                  onDepartmentChanged: (value) => setState(
                                    () => _selectedDepartment =
                                        value ?? _selectedDepartment,
                                  ),
                                  onStatusChanged: (value) => setState(
                                    () => _selectedStatus =
                                        value ?? _selectedStatus,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            children: [
                              SizedBox(
                                height: 500,
                                child: _SubjectsTable(items: state.items),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _SubjectFormCard(
                                selectedDepartment: _selectedDepartment,
                                selectedStatus: _selectedStatus,
                                onDepartmentChanged: (value) => setState(
                                  () => _selectedDepartment =
                                      value ?? _selectedDepartment,
                                ),
                                onStatusChanged: (value) => setState(
                                  () => _selectedStatus =
                                      value ?? _selectedStatus,
                                ),
                              ),
                            ],
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

class _SubjectsTable extends StatelessWidget {
  const _SubjectsTable({required this.items});

  final List<SubjectModel> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject catalog',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminDataTable<SubjectModel>(
              items: items,
              columns: [
                AdminTableColumn<SubjectModel>(
                  label: 'Subject',
                  cellBuilder: (item) => _SubjectCell(item: item),
                ),
                AdminTableColumn<SubjectModel>(
                  label: 'Department',
                  cellBuilder: (item) => Text(item.department),
                ),
                AdminTableColumn<SubjectModel>(
                  label: 'Credits',
                  cellBuilder: (item) => Text(
                    item.credits.toString(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                AdminTableColumn<SubjectModel>(
                  label: 'Status',
                  cellBuilder: (item) => StatusBadge(item.status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCell extends StatelessWidget {
  const _SubjectCell({required this.item});

  final SubjectModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(item.name, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 2),
        Text(item.code, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SubjectFormCard extends StatelessWidget {
  const _SubjectFormCard({
    required this.selectedDepartment,
    required this.selectedStatus,
    required this.onDepartmentChanged,
    required this.onStatusChanged,
  });

  final String selectedDepartment;
  final String selectedStatus;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject builder',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Configure subject name, code, ownership, and delivery status.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppTextField(
            label: 'Subject name',
            initialValue: 'Advanced Algorithms',
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(label: 'Subject code', initialValue: 'CS401'),
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
              const Expanded(
                child: AppTextField(label: 'Credits', initialValue: '3'),
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
            label: 'Description',
            initialValue:
                'Advanced-level subject covering graph theory, optimization, and performance analysis.',
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warningSoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule_rounded, color: AppColors.warning),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Suggested placement: Spring 2026 / Level 4'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(
                child: PremiumButton(
                  label: 'Preview',
                  icon: Icons.visibility_outlined,
                  isSecondary: true,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PremiumButton(
                  label: 'Save subject',
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
