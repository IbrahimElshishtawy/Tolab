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
import '../state/departments_state.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  String _selectedStatus = 'Active';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DepartmentsState>(
      onInit: (store) => store.dispatch(LoadDepartmentsAction()),
      converter: (store) => store.state.departmentsState,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Departments',
              subtitle:
                  'Manage academic structure, department heads, and lifecycle status with a clean CRUD-focused admin surface.',
              breadcrumbs: ['Admin', 'Academic', 'Departments'],
              actions: [
                PremiumButton(
                  label: 'Archive',
                  icon: Icons.inventory_2_outlined,
                  isSecondary: true,
                ),
                PremiumButton(
                  label: 'New department',
                  icon: Icons.apartment_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            FilterBar(
              searchHint: 'Search department name, code, head',
              trailing: const [
                PremiumButton(
                  label: 'Sort',
                  icon: Icons.swap_vert_rounded,
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
                ).dispatch(LoadDepartmentsAction()),
                isEmpty: state.items.isEmpty,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showSidePanel = constraints.maxWidth > 1080;

                    return showSidePanel
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _DepartmentsTable(items: state.items),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 4,
                                child: _DepartmentFormCard(
                                  selectedStatus: _selectedStatus,
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
                                child: _DepartmentsTable(items: state.items),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _DepartmentFormCard(
                                selectedStatus: _selectedStatus,
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

class _DepartmentsTable extends StatelessWidget {
  const _DepartmentsTable({required this.items});

  final List<DepartmentModel> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Department index',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminDataTable<DepartmentModel>(
              items: items,
              columns: [
                AdminTableColumn<DepartmentModel>(
                  label: 'Department',
                  cellBuilder: (item) => _DepartmentCell(item: item),
                ),
                AdminTableColumn<DepartmentModel>(
                  label: 'Leadership',
                  cellBuilder: (item) => _TwoLineText(
                    primary: item.head,
                    secondary: 'Head of department',
                  ),
                ),
                AdminTableColumn<DepartmentModel>(
                  label: 'Students',
                  cellBuilder: (item) => Text(
                    item.studentsCount.toString(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                AdminTableColumn<DepartmentModel>(
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

class _DepartmentCell extends StatelessWidget {
  const _DepartmentCell({required this.item});

  final DepartmentModel item;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.apartment_rounded, color: AppColors.info),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 2),
            Text(item.code, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _DepartmentFormCard extends StatelessWidget {
  const _DepartmentFormCard({
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final String selectedStatus;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department editor',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Simple CRUD panel for structure, ownership, and visibility.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            const AppTextField(
              label: 'Department name',
              initialValue: 'Computer Science',
            ),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(label: 'Department code', initialValue: 'CS'),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'Department head',
              initialValue: 'Dr. Eman Adel',
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdownField<String>(
              label: 'Status',
              value: selectedStatus,
              onChanged: onStatusChanged,
              items: const [
                AppDropdownItem(value: 'Active', label: 'Active'),
                AppDropdownItem(value: 'Pending', label: 'Pending'),
                AppDropdownItem(value: 'Inactive', label: 'Inactive'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'Internal description',
              initialValue:
                  'Research-led department focused on advanced software systems and applied computing.',
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              child: const Row(
                children: [
                  Icon(Icons.groups_rounded, color: AppColors.primary),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('3 sections and 42 staff assignments linked'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Row(
              children: [
                Expanded(
                  child: PremiumButton(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    isSecondary: true,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PremiumButton(
                    label: 'Save department',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TwoLineText extends StatelessWidget {
  const _TwoLineText({required this.primary, required this.secondary});

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
