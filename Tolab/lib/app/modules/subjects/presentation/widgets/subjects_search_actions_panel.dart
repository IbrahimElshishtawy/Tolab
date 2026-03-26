import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../design/subjects_management_tokens.dart';
import '../responsive/subjects_layout.dart';
import 'subject_primitives.dart';

class SubjectsSearchActionsPanel extends StatelessWidget {
  const SubjectsSearchActionsPanel({
    super.key,
    required this.searchQuery,
    required this.department,
    required this.academicYear,
    required this.status,
    required this.doctor,
    required this.assistant,
    required this.departments,
    required this.academicYears,
    required this.statuses,
    required this.doctors,
    required this.assistants,
    required this.viewMode,
    required this.onSearchChanged,
    required this.onDepartmentChanged,
    required this.onAcademicYearChanged,
    required this.onStatusChanged,
    required this.onDoctorChanged,
    required this.onAssistantChanged,
    required this.onViewModeChanged,
    required this.onAddSubject,
    required this.onEditSubject,
    required this.onCreateGroup,
    required this.onManagePosts,
    required this.onManageSummaries,
    required this.onGenerateCode,
    required this.onGenerateLink,
    required this.onClearFilters,
  });

  final String searchQuery;
  final String? department;
  final String? academicYear;
  final String? status;
  final String? doctor;
  final String? assistant;
  final List<String> departments;
  final List<String> academicYears;
  final List<String> statuses;
  final List<String> doctors;
  final List<String> assistants;
  final SubjectsViewMode viewMode;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onAcademicYearChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onDoctorChanged;
  final ValueChanged<String?> onAssistantChanged;
  final ValueChanged<SubjectsViewMode> onViewModeChanged;
  final VoidCallback onAddSubject;
  final VoidCallback onEditSubject;
  final VoidCallback onCreateGroup;
  final VoidCallback onManagePosts;
  final VoidCallback onManageSummaries;
  final VoidCallback onGenerateCode;
  final VoidCallback onGenerateLink;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return SubjectSectionFrame(
      title: 'Search, filters, and actions',
      subtitle:
          'Search by subject, doctor, or assistant. Filter by department, academic year, staff assignment, and status.',
      trailing: SubjectsSegmentedControl<SubjectsViewMode>(
        currentValue: viewMode,
        values: SubjectsViewMode.values,
        labelBuilder: (value) => value.label,
        onChanged: onViewModeChanged,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 880;
              final inputWidth = wide
                  ? (constraints.maxWidth - AppSpacing.lg * 2) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    width: inputWidth,
                    child: _SearchField(
                      initialValue: searchQuery,
                      onChanged: onSearchChanged,
                    ),
                  ),
                  SizedBox(
                    width: inputWidth,
                    child: _SelectField(
                      label: 'Department',
                      value: department,
                      hint: 'All departments',
                      items: departments,
                      onChanged: onDepartmentChanged,
                    ),
                  ),
                  SizedBox(
                    width: inputWidth,
                    child: _SelectField(
                      label: 'Academic year',
                      value: academicYear,
                      hint: 'All years',
                      items: academicYears,
                      onChanged: onAcademicYearChanged,
                    ),
                  ),
                  SizedBox(
                    width: inputWidth,
                    child: _SelectField(
                      label: 'Subject status',
                      value: status,
                      hint: 'Any status',
                      items: statuses,
                      onChanged: onStatusChanged,
                    ),
                  ),
                  SizedBox(
                    width: inputWidth,
                    child: _SelectField(
                      label: 'Assigned doctor',
                      value: doctor,
                      hint: 'Any doctor',
                      items: doctors,
                      onChanged: onDoctorChanged,
                    ),
                  ),
                  SizedBox(
                    width: inputWidth,
                    child: _SelectField(
                      label: 'Assigned assistant',
                      value: assistant,
                      hint: 'Any assistant',
                      items: assistants,
                      onChanged: onAssistantChanged,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PremiumButton(
                label: 'Add Subject',
                icon: Icons.add_rounded,
                onPressed: onAddSubject,
              ),
              PremiumButton(
                label: 'Edit Subject',
                icon: Icons.edit_outlined,
                isSecondary: true,
                onPressed: onEditSubject,
              ),
              PremiumButton(
                label: 'Create Group',
                icon: Icons.forum_outlined,
                isSecondary: true,
                onPressed: onCreateGroup,
              ),
              PremiumButton(
                label: 'Manage Posts',
                icon: Icons.post_add_rounded,
                isSecondary: true,
                onPressed: onManagePosts,
              ),
              PremiumButton(
                label: 'Manage Summaries',
                icon: Icons.summarize_outlined,
                isSecondary: true,
                onPressed: onManageSummaries,
              ),
              PremiumButton(
                label: 'Generate Code',
                icon: Icons.password_rounded,
                isSecondary: true,
                onPressed: onGenerateCode,
              ),
              PremiumButton(
                label: 'Generate Link',
                icon: Icons.link_rounded,
                isSecondary: true,
                onPressed: onGenerateLink,
              ),
              PremiumButton(
                label: 'Clear Filters',
                icon: Icons.filter_alt_off_rounded,
                isSecondary: true,
                onPressed: onClearFilters,
              ),
              FilledButton.icon(
                onPressed: () {},
                style: SubjectsManagementButtons.subtle(
                  context,
                  tint: SubjectsManagementPalette.coral,
                ),
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('Export'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Search subjects',
        hintText:
            'Subject name, code, doctor, assistant, department, academic year',
        prefixIcon: Icon(Icons.search_rounded),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, hintText: hint),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(hint, style: Theme.of(context).textTheme.bodySmall),
        ),
        for (final item in items)
          DropdownMenuItem<String?>(
            value: item,
            child: Text(item, overflow: TextOverflow.ellipsis),
          ),
      ],
    );
  }
}
