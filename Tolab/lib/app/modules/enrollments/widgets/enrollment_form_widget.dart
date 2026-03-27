import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../shared/widgets/premium_button.dart';
import '../models/enrollment_models.dart';

class EnrollmentFormWidget extends StatefulWidget {
  const EnrollmentFormWidget({
    super.key,
    required this.lookups,
    required this.onSubmit,
    this.initialRecord,
    this.onCancel,
    this.submitLabel = 'Save enrollment',
  });

  final EnrollmentLookupBundle lookups;
  final EnrollmentRecord? initialRecord;
  final ValueChanged<EnrollmentUpsertPayload> onSubmit;
  final VoidCallback? onCancel;
  final String submitLabel;

  @override
  State<EnrollmentFormWidget> createState() => _EnrollmentFormWidgetState();
}

class _EnrollmentFormWidgetState extends State<EnrollmentFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String? _studentId;
  late String? _courseId;
  late String? _sectionId;
  late String? _semester;
  late String? _academicYear;
  late EnrollmentStatus _status;
  late String? _doctorId;
  late String? _assistantId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRecord;
    _studentId = initial?.studentId;
    _courseId = initial?.courseId;
    _sectionId = initial?.sectionId;
    _semester = initial?.semester;
    _academicYear = initial?.academicYear;
    _status = initial?.status ?? EnrollmentStatus.pending;
    _doctorId = initial?.doctorId;
    _assistantId = initial?.assistantId;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final courseOptions = <String, String>{
      for (final offering in widget.lookups.offerings)
        offering.courseId: offering.courseLabel,
    };
    final availableOfferings = widget.lookups.offerings
        .where((offering) {
          final matchesCourse =
              _courseId == null || offering.courseId == _courseId;
          final matchesSection =
              _sectionId == null || offering.sectionId == _sectionId;
          final matchesSemester =
              _semester == null || offering.semester == _semester;
          final matchesYear =
              _academicYear == null || offering.academicYear == _academicYear;
          return matchesCourse &&
              matchesSection &&
              matchesSemester &&
              matchesYear;
        })
        .toList(growable: false);
    final selectedOffering = _resolveOffering(availableOfferings);
    final sectionOptions = <String, String>{
      for (final offering in widget.lookups.offerings)
        if (_courseId == null || offering.courseId == _courseId)
          offering.sectionId: offering.sectionName,
    };
    final semesters =
        widget.lookups.offerings
            .where((item) => _courseId == null || item.courseId == _courseId)
            .map((item) => item.semester)
            .toSet()
            .toList()
          ..sort();
    final years =
        widget.lookups.offerings
            .where((item) => _courseId == null || item.courseId == _courseId)
            .map((item) => item.academicYear)
            .toSet()
            .toList()
          ..sort();

    if (selectedOffering != null) {
      _doctorId ??= selectedOffering.doctorId;
      _assistantId ??= selectedOffering.assistantId;
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialRecord == null
                  ? 'New enrollment'
                  : 'Edit enrollment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Link a student to a course offering, section, academic term, and responsible teaching staff.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final useSingleColumn = isMobile || constraints.maxWidth < 720;
                final children = [
                  _field(
                    width: useSingleColumn ? double.infinity : 320,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey<Object?>(_studentId),
                      initialValue: _studentId,
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: widget.lookups.students
                          .map(
                            (student) => DropdownMenuItem<String>(
                              value: student.id,
                              child: Text('${student.name} • ${student.id}'),
                            ),
                          )
                          .toList(growable: false),
                      validator: (value) =>
                          value == null ? 'Please select a student.' : null,
                      onChanged: (value) => setState(() => _studentId = value),
                    ),
                  ),
                  _field(
                    width: useSingleColumn ? double.infinity : 320,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey<Object?>(_courseId),
                      initialValue: _courseId,
                      decoration: const InputDecoration(labelText: 'Course'),
                      items: courseOptions.entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(growable: false),
                      validator: (value) =>
                          value == null ? 'Please select a course.' : null,
                      onChanged: (value) {
                        setState(() {
                          _courseId = value;
                          _sectionId = null;
                          _semester = null;
                          _academicYear = null;
                        });
                      },
                    ),
                  ),
                  _field(
                    width: useSingleColumn ? double.infinity : 220,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey<Object?>(_sectionId),
                      initialValue: _sectionId,
                      decoration: const InputDecoration(labelText: 'Section'),
                      items: sectionOptions.entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(growable: false),
                      validator: (value) =>
                          value == null ? 'Please select a section.' : null,
                      onChanged: (value) => setState(() => _sectionId = value),
                    ),
                  ),
                  _field(
                    width: useSingleColumn ? double.infinity : 220,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey<Object?>(_semester),
                      initialValue: _semester,
                      decoration: const InputDecoration(labelText: 'Semester'),
                      items: semesters
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(growable: false),
                      validator: (value) =>
                          value == null ? 'Please select a semester.' : null,
                      onChanged: (value) => setState(() => _semester = value),
                    ),
                  ),
                  _field(
                    width: useSingleColumn ? double.infinity : 220,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey<Object?>(_academicYear),
                      initialValue: _academicYear,
                      decoration: const InputDecoration(
                        labelText: 'Academic year',
                      ),
                      items: years
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(growable: false),
                      validator: (value) =>
                          value == null ? 'Please select a year.' : null,
                      onChanged: (value) =>
                          setState(() => _academicYear = value),
                    ),
                  ),
                  _field(
                    width: useSingleColumn ? double.infinity : 220,
                    child: DropdownButtonFormField<EnrollmentStatus>(
                      key: ValueKey<Object?>(_status),
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: EnrollmentStatus.values
                          .map(
                            (value) => DropdownMenuItem<EnrollmentStatus>(
                              value: value,
                              child: Text(value.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                  ),
                  _field(
                    width: useSingleColumn ? double.infinity : 320,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey<Object?>(_doctorId),
                      initialValue: _doctorId,
                      decoration: const InputDecoration(labelText: 'Doctor'),
                      items: widget.lookups.doctors
                          .map(
                            (staff) => DropdownMenuItem<String>(
                              value: staff.id,
                              child: Text(staff.name),
                            ),
                          )
                          .toList(growable: false),
                      validator: (value) =>
                          value == null ? 'Please assign a doctor.' : null,
                      onChanged: (value) => setState(() => _doctorId = value),
                    ),
                  ),
                  _field(
                    width: useSingleColumn ? double.infinity : 320,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey<Object?>(_assistantId),
                      initialValue: _assistantId,
                      decoration: const InputDecoration(labelText: 'Assistant'),
                      items: widget.lookups.assistants
                          .map(
                            (staff) => DropdownMenuItem<String>(
                              value: staff.id,
                              child: Text(staff.name),
                            ),
                          )
                          .toList(growable: false),
                      validator: (value) =>
                          value == null ? 'Please assign an assistant.' : null,
                      onChanged: (value) =>
                          setState(() => _assistantId = value),
                    ),
                  ),
                ];

                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: children,
                );
              },
            ),
            if (selectedOffering != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: selectedOffering.occupancyRate < 0.75
                      ? Colors.green.withValues(alpha: 0.08)
                      : Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  'Offering capacity: ${selectedOffering.occupancy}/${selectedOffering.capacity} seats occupied in ${selectedOffering.sectionName}.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.onCancel != null)
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                const SizedBox(width: AppSpacing.sm),
                PremiumButton(
                  label: widget.submitLabel,
                  icon: Icons.check_rounded,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({required double width, required Widget child}) {
    return SizedBox(width: width, child: child);
  }

  EnrollmentOfferingOption? _resolveOffering(
    List<EnrollmentOfferingOption> offerings,
  ) {
    if (_courseId == null ||
        _sectionId == null ||
        _semester == null ||
        _academicYear == null) {
      return null;
    }
    for (final offering in offerings) {
      if (offering.courseId == _courseId &&
          offering.sectionId == _sectionId &&
          offering.semester == _semester &&
          offering.academicYear == _academicYear) {
        return offering;
      }
    }
    return null;
  }

  void _handleSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final selectedOffering = _resolveOffering(widget.lookups.offerings);
    if (selectedOffering == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please choose a valid course, section, semester, and year combination.',
          ),
        ),
      );
      return;
    }

    widget.onSubmit(
      EnrollmentUpsertPayload(
        studentId: _studentId!,
        courseOfferingId: selectedOffering.id,
        courseId: _courseId!,
        sectionId: _sectionId!,
        semester: _semester!,
        academicYear: _academicYear!,
        status: _status,
        doctorId: _doctorId ?? selectedOffering.doctorId,
        assistantId: _assistantId ?? selectedOffering.assistantId,
      ),
    );
  }
}
