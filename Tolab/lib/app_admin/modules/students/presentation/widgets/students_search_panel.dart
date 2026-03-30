import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../design/students_admin_tokens.dart';
import 'students_segmented_control.dart';
import 'students_section_card.dart';

class StudentsSearchPanel extends StatelessWidget {
  const StudentsSearchPanel({
    super.key,
    required this.searchController,
    required this.query,
    required this.department,
    required this.batch,
    required this.status,
    required this.segment,
    required this.advancedOpen,
    required this.onQueryChanged,
    required this.onDepartmentChanged,
    required this.onBatchChanged,
    required this.onStatusChanged,
    required this.onSegmentChanged,
    required this.onToggleAdvanced,
    required this.onClear,
  });

  final TextEditingController searchController;
  final String query;
  final String department;
  final String batch;
  final String status;
  final String segment;
  final bool advancedOpen;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onBatchChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSegmentChanged;
  final VoidCallback onToggleAdvanced;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return StudentsSectionCard(
      title: 'Search, filters, and actions',
      subtitle:
          'Find students fast, bulk-manage registration, and control the list from one compact workspace.',
      trailing: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          const PremiumButton(
            label: 'Add student',
            icon: Icons.person_add_alt_1_rounded,
          ),
          const PremiumButton(
            label: 'Import file',
            icon: Icons.upload_file_rounded,
            isSecondary: true,
          ),
          const PremiumButton(
            label: 'Export',
            icon: Icons.download_rounded,
            isSecondary: true,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 980;
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    width: compact
                        ? constraints.maxWidth
                        : constraints.maxWidth * 0.38,
                    child: TextField(
                      controller: searchController,
                      onChanged: onQueryChanged,
                      decoration: const InputDecoration(
                        hintText:
                            'Search by student name, national ID, student ID',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: compact ? constraints.maxWidth : 180,
                    child: _FilterDropdown(
                      label: 'Department',
                      value: department,
                      items: const [
                        'All departments',
                        'Computer Science',
                        'Information Systems',
                        'Engineering',
                      ],
                      onChanged: onDepartmentChanged,
                    ),
                  ),
                  SizedBox(
                    width: compact ? constraints.maxWidth : 160,
                    child: _FilterDropdown(
                      label: 'Batch',
                      value: batch,
                      items: const ['All batches', '2022', '2023', '2024'],
                      onChanged: onBatchChanged,
                    ),
                  ),
                  SizedBox(
                    width: compact ? constraints.maxWidth : 160,
                    child: _FilterDropdown(
                      label: 'Status',
                      value: status,
                      items: const [
                        'All statuses',
                        'Active',
                        'Watchlist',
                        'Probation',
                      ],
                      onChanged: onStatusChanged,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StudentsSegmentedControl(
                options: const ['All students', 'At risk', 'Graduation ready'],
                value: segment,
                onChanged: onSegmentChanged,
              ),
              OutlinedButton.icon(
                onPressed: onToggleAdvanced,
                style: StudentsAdminButtons.subtle(
                  context,
                  tint: AppColors.info,
                ),
                icon: Icon(
                  advancedOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.tune_rounded,
                  size: 18,
                ),
                label: Text(advancedOpen ? 'Hide advanced' : 'Advanced filter'),
              ),
              OutlinedButton.icon(
                onPressed: onClear,
                style: StudentsAdminButtons.subtle(
                  context,
                  tint: StudentsAdminPalette.neutral,
                ),
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Clear filters'),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: advancedOpen
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: StudentsAdminPalette.muted(context),
                        borderRadius: BorderRadius.circular(
                          AppConstants.mediumRadius,
                        ),
                        border: Border.all(
                          color: StudentsAdminPalette.border(context),
                        ),
                      ),
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: const [
                          _AdvancedChip(label: 'Attendance < 75%'),
                          _AdvancedChip(label: 'Registration not sent'),
                          _AdvancedChip(label: 'Low doctor engagement'),
                          _AdvancedChip(label: 'Remaining credits < 30'),
                          _AdvancedChip(label: 'High GPA'),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

class _AdvancedChip extends StatelessWidget {
  const _AdvancedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
