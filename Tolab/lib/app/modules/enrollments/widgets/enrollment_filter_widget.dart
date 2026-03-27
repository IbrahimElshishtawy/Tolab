import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/widgets/premium_button.dart';
import '../models/enrollment_models.dart';

class EnrollmentFilterWidget extends StatelessWidget {
  const EnrollmentFilterWidget({
    super.key,
    required this.searchController,
    required this.filters,
    required this.sort,
    required this.lookups,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onCourseChanged,
    required this.onSectionChanged,
    required this.onSemesterChanged,
    required this.onYearChanged,
    required this.onStaffChanged,
    required this.onSortFieldChanged,
    required this.onSortDirectionChanged,
    required this.onClearFilters,
    required this.onCreateEnrollment,
    required this.onBulkUpload,
  });

  final TextEditingController searchController;
  final EnrollmentsFilters filters;
  final EnrollmentsSort sort;
  final EnrollmentLookupBundle lookups;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<EnrollmentStatus?> onStatusChanged;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String?> onSectionChanged;
  final ValueChanged<String?> onSemesterChanged;
  final ValueChanged<String?> onYearChanged;
  final ValueChanged<String?> onStaffChanged;
  final ValueChanged<EnrollmentSortField> onSortFieldChanged;
  final ValueChanged<bool> onSortDirectionChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateEnrollment;
  final VoidCallback onBulkUpload;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final courseOptions = <String, String>{
      for (final offering in lookups.offerings)
        offering.courseId: offering.courseLabel,
    };
    final sectionOptions = <String, String>{
      for (final offering in lookups.offerings)
        if (filters.courseId == null || offering.courseId == filters.courseId)
          offering.sectionId: offering.sectionName,
    };
    final staffOptions = <String, String>{
      for (final doctor in lookups.doctors) doctor.id: doctor.name,
      for (final assistant in lookups.assistants) assistant.id: assistant.name,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Search, refine, and act on enrollments without leaving the roster.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    PremiumButton(
                      label: 'Bulk upload',
                      icon: Icons.upload_file_rounded,
                      isSecondary: true,
                      onPressed: onBulkUpload,
                    ),
                    PremiumButton(
                      label: 'Add enrollment',
                      icon: Icons.add_rounded,
                      onPressed: onCreateEnrollment,
                    ),
                  ],
                ),
              ],
            ),
          if (!isMobile) const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 280,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    hintText: 'Student, ID, course, section, staff',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              _DropdownField<EnrollmentStatus?>(
                width: 180,
                value: filters.status,
                label: 'Status',
                items: const [
                  DropdownMenuItem<EnrollmentStatus?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  DropdownMenuItem(
                    value: EnrollmentStatus.enrolled,
                    child: Text('Enrolled'),
                  ),
                  DropdownMenuItem(
                    value: EnrollmentStatus.pending,
                    child: Text('Pending'),
                  ),
                  DropdownMenuItem(
                    value: EnrollmentStatus.rejected,
                    child: Text('Rejected'),
                  ),
                ],
                onChanged: onStatusChanged,
              ),
              _DropdownField<String?>(
                width: 220,
                value: filters.courseId,
                label: 'Course',
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All courses'),
                  ),
                  ...courseOptions.entries.map(
                    (entry) => DropdownMenuItem<String?>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  ),
                ],
                onChanged: onCourseChanged,
              ),
              _DropdownField<String?>(
                width: 170,
                value: filters.sectionId,
                label: 'Section',
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All sections'),
                  ),
                  ...sectionOptions.entries.map(
                    (entry) => DropdownMenuItem<String?>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  ),
                ],
                onChanged: onSectionChanged,
              ),
              _DropdownField<String?>(
                width: 160,
                value: filters.semester,
                label: 'Semester',
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All semesters'),
                  ),
                  ...lookups.semesters.map(
                    (value) => DropdownMenuItem<String?>(
                      value: value,
                      child: Text(value),
                    ),
                  ),
                ],
                onChanged: onSemesterChanged,
              ),
              _DropdownField<String?>(
                width: 160,
                value: filters.academicYear,
                label: 'Year',
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All years'),
                  ),
                  ...lookups.academicYears.map(
                    (value) => DropdownMenuItem<String?>(
                      value: value,
                      child: Text(value),
                    ),
                  ),
                ],
                onChanged: onYearChanged,
              ),
              _DropdownField<String?>(
                width: 190,
                value: filters.staffId,
                label: 'Staff',
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All staff'),
                  ),
                  ...staffOptions.entries.map(
                    (entry) => DropdownMenuItem<String?>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  ),
                ],
                onChanged: onStaffChanged,
              ),
              _DropdownField<EnrollmentSortField>(
                width: 190,
                value: sort.field,
                label: 'Sort by',
                items: EnrollmentSortField.values
                    .map(
                      (field) => DropdownMenuItem<EnrollmentSortField>(
                        value: field,
                        child: Text(field.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) onSortFieldChanged(value);
                },
              ),
              _DropdownField<bool>(
                width: 150,
                value: sort.ascending,
                label: 'Direction',
                items: const [
                  DropdownMenuItem<bool>(value: false, child: Text('Newest')),
                  DropdownMenuItem<bool>(value: true, child: Text('Oldest')),
                ],
                onChanged: (value) {
                  if (value != null) onSortDirectionChanged(value);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (isMobile)
                Expanded(
                  child: PremiumButton(
                    label: 'Add enrollment',
                    icon: Icons.add_rounded,
                    onPressed: onCreateEnrollment,
                  ),
                ),
              if (isMobile) const SizedBox(width: AppSpacing.sm),
              if (isMobile)
                Expanded(
                  child: PremiumButton(
                    label: 'Bulk upload',
                    icon: Icons.upload_file_rounded,
                    isSecondary: true,
                    onPressed: onBulkUpload,
                  ),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.width,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final double width;
  final T value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T>(
        key: ValueKey<Object?>(value),
        initialValue: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
