import 'package:flutter/material.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/forms/app_dropdown_field.dart';
import '../../../../shared/forms/app_text_field.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/subject_management_models.dart';
import '../design/subjects_management_tokens.dart';

class SubjectFormSheet extends StatefulWidget {
  const SubjectFormSheet({
    super.key,
    this.subject,
    required this.departments,
    required this.academicYears,
    required this.doctors,
    required this.assistants,
    required this.statuses,
  });

  final SubjectRecord? subject;
  final List<String> departments;
  final List<String> academicYears;
  final List<String> doctors;
  final List<String> assistants;
  final List<String> statuses;

  static Future<void> open(
    BuildContext context, {
    SubjectRecord? subject,
    required List<String> departments,
    required List<String> academicYears,
    required List<String> doctors,
    required List<String> assistants,
    required List<String> statuses,
  }) async {
    final form = SubjectFormSheet(
      subject: subject,
      departments: departments,
      academicYears: academicYears,
      doctors: doctors,
      assistants: assistants,
      statuses: statuses,
    );

    if (AppBreakpoints.isDesktop(context)) {
      await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(28),
          child: SizedBox(width: 860, child: form),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: form,
      ),
    );
  }

  @override
  State<SubjectFormSheet> createState() => _SubjectFormSheetState();
}

class _SubjectFormSheetState extends State<SubjectFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _hoursController;
  late final TextEditingController _creditsController;
  late final TextEditingController _maxStudentsController;
  late final TextEditingController _accessCodeController;
  late final TextEditingController _accessLinkController;
  late String _department;
  late String _academicYear;
  late String _doctor;
  late String _assistant;
  late String _status;
  bool _createGroup = true;
  bool _allowPostOpening = false;
  bool _allowSummaries = true;

  @override
  void initState() {
    super.initState();
    final subject = widget.subject;
    _nameController = TextEditingController(text: subject?.name ?? '');
    _codeController = TextEditingController(text: subject?.code ?? '');
    _hoursController = TextEditingController(
      text: '${subject?.contactHours ?? 4}',
    );
    _creditsController = TextEditingController(
      text: '${subject?.creditHours ?? 3}',
    );
    _maxStudentsController = TextEditingController(
      text: '${subject?.eligibleStudents ?? 120}',
    );
    _accessCodeController = TextEditingController(
      text: subject?.access.code ?? 'SUB-NEW-01',
    );
    _accessLinkController = TextEditingController(
      text: subject?.access.link ?? 'tolab.edu/join/new-subject',
    );
    _department = subject?.department ?? widget.departments.first;
    _academicYear = subject?.academicYear ?? widget.academicYears.first;
    _doctor = subject?.doctor.name ?? widget.doctors.first;
    _assistant = subject?.assistant.name ?? widget.assistants.first;
    _status = subject?.status ?? widget.statuses.first;
    _createGroup = subject?.group.enabled ?? true;
    _allowPostOpening =
        subject?.permissions
            .expand((category) => category.permissions)
            .any(
              (permission) =>
                  permission.id == 'student_posts' && permission.enabled,
            ) ??
        false;
    _allowSummaries =
        subject?.permissions
            .expand((category) => category.permissions)
            .any(
              (permission) =>
                  permission.id == 'students_view_summaries' &&
                  permission.enabled,
            ) ??
        true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _hoursController.dispose();
    _creditsController.dispose();
    _maxStudentsController.dispose();
    _accessCodeController.dispose();
    _accessLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final panelHeight =
        MediaQuery.sizeOf(context).height * (isDesktop ? 0.84 : 0.92);
    final child = SafeArea(
      top: false,
      child: SizedBox(
        height: panelHeight,
        child: AppCard(
          borderRadius: 30,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subject == null
                              ? 'Create subject'
                              : 'Edit subject',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Compact setup for staff assignment, student privacy, access entry, and subject activity controls.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormSection(
                        title: 'Basic subject info',
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 720;
                            return Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.58,
                                  child: AppTextField(
                                    controller: _nameController,
                                    label: 'Subject name',
                                    hint: 'Distributed Systems',
                                    prefixIcon: Icons.auto_stories_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.34,
                                  child: AppTextField(
                                    controller: _codeController,
                                    label: 'Subject code',
                                    hint: 'CS420',
                                  ),
                                ),
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.31,
                                  child: AppDropdownField<String>(
                                    label: 'Department',
                                    value: _department,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _department = value);
                                      }
                                    },
                                    items: [
                                      for (final item in widget.departments)
                                        AppDropdownItem(
                                          value: item,
                                          label: item,
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.31,
                                  child: AppDropdownField<String>(
                                    label: 'Academic year',
                                    value: _academicYear,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _academicYear = value);
                                      }
                                    },
                                    items: [
                                      for (final item in widget.academicYears)
                                        AppDropdownItem(
                                          value: item,
                                          label: item,
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.16,
                                  child: AppTextField(
                                    controller: _creditsController,
                                    label: 'Credit hours',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.16,
                                  child: AppTextField(
                                    controller: _hoursController,
                                    label: 'Subject hours',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _FormSection(
                        title: 'Staff and enrollment',
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 720;
                            return Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.48,
                                  child: AppDropdownField<String>(
                                    label: 'Assigned doctor',
                                    value: _doctor,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _doctor = value);
                                      }
                                    },
                                    items: [
                                      for (final item in widget.doctors)
                                        AppDropdownItem(
                                          value: item,
                                          label: item,
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.48,
                                  child: AppDropdownField<String>(
                                    label: 'Assigned assistant',
                                    value: _assistant,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _assistant = value);
                                      }
                                    },
                                    items: [
                                      for (final item in widget.assistants)
                                        AppDropdownItem(
                                          value: item,
                                          label: item,
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.48,
                                  child: AppTextField(
                                    controller: _maxStudentsController,
                                    label: 'Eligible students / max visible',
                                    keyboardType: TextInputType.number,
                                    helperText:
                                        'Staff-only list. Students never see each other.',
                                  ),
                                ),
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.48,
                                  child: AppDropdownField<String>(
                                    label: 'Subject status',
                                    value: _status,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _status = value);
                                      }
                                    },
                                    items: [
                                      for (final item in widget.statuses)
                                        AppDropdownItem(
                                          value: item,
                                          label: item,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _FormSection(
                        title: 'Community and content controls',
                        child: Column(
                          children: [
                            _SwitchTile(
                              value: _createGroup,
                              title: 'Create subject group / community',
                              subtitle:
                                  'Organize students and posts in a dedicated subject space.',
                              onChanged: (value) {
                                setState(() => _createGroup = value);
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _SwitchTile(
                              value: _allowPostOpening,
                              title: 'Students can open posts',
                              subtitle:
                                  'If disabled, staff opens posts while students only reply where allowed.',
                              onChanged: (value) {
                                setState(() => _allowPostOpening = value);
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _SwitchTile(
                              value: _allowSummaries,
                              title: 'Students can access summaries',
                              subtitle:
                                  'Keep revision material readable without exposing peer accounts.',
                              onChanged: (value) {
                                setState(() => _allowSummaries = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _FormSection(
                        title: 'Access code and link',
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 720;
                            return Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.32,
                                  child: AppTextField(
                                    controller: _accessCodeController,
                                    label: 'Access code',
                                    helperText:
                                        'Used for fast entry and late registration.',
                                  ),
                                ),
                                SizedBox(
                                  width: stacked
                                      ? constraints.maxWidth
                                      : constraints.maxWidth * 0.64,
                                  child: AppTextField(
                                    controller: _accessLinkController,
                                    label: 'Access link',
                                    helperText:
                                        'Keep secure and easy to regenerate.',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  PremiumButton(
                    label: 'Save Subject',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  PremiumButton(
                    label: 'Preview Control Center',
                    icon: Icons.visibility_outlined,
                    isSecondary: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isDesktop) {
      return child;
    }

    return FractionallySizedBox(heightFactor: 0.96, child: child);
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: SubjectsManagementDecorations.tintedPanel(
        context,
        tint: SubjectsManagementPalette.accent,
        opacity: 0.05,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final bool value;
  final String title;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SubjectsManagementPalette.muted(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SubjectsManagementPalette.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
