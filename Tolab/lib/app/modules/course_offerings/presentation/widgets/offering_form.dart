import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../state/app_state.dart';
import '../../models/course_offering_model.dart';
import '../../state/course_offerings_actions.dart';

class OfferingForm {
  static Future<void> show(
    BuildContext context, {
    CourseOfferingModel? initialOffering,
  }) async {
    if (AppBreakpoints.isDesktop(context)) {
      await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _OfferingFormBody(initialOffering: initialOffering),
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _OfferingFormBody(initialOffering: initialOffering),
      ),
    );
  }
}

class _OfferingFormBody extends StatefulWidget {
  const _OfferingFormBody({this.initialOffering});

  final CourseOfferingModel? initialOffering;

  @override
  State<_OfferingFormBody> createState() => _OfferingFormBodyState();
}

class _OfferingFormBodyState extends State<_OfferingFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _capacityController;
  late final TextEditingController _yearController;
  late String? _subjectId;
  late String? _departmentId;
  late String? _sectionId;
  late String? _doctorId;
  late final Set<String> _assistantIds;
  late String _semester;
  late CourseOfferingStatus _status;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialOffering;
    _capacityController = TextEditingController(
      text: (initial?.capacity ?? 120).toString(),
    );
    _yearController = TextEditingController(
      text: initial?.academicYear ?? '2025/2026',
    );
    _subjectId = initial?.subjectId;
    _departmentId = initial?.departmentId;
    _sectionId = initial?.sectionId;
    _doctorId = initial?.doctor.id;
    _assistantIds = {...?initial?.assistants.map((item) => item.id)};
    _semester = initial?.semester ?? 'Spring';
    _status = initial?.status ?? CourseOfferingStatus.draft;
    _startDate = initial?.startDate ?? DateTime(2026, 2, 1);
    _endDate = initial?.endDate ?? DateTime(2026, 5, 20);
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _OfferingFormViewModel>(
      converter: (store) => _OfferingFormViewModel.fromStore(store),
      distinct: true,
      builder: (context, vm) {
        final assistantOptions = vm.assistants
            .where(
              (item) => _departmentId == null || item.group == _departmentId,
            )
            .toList(growable: false);
        final sectionOptions = vm.sections
            .where(
              (item) => _departmentId == null || item.group == _departmentId,
            )
            .toList(growable: false);
        final doctorOptions = vm.doctors
            .where(
              (item) => _departmentId == null || item.group == _departmentId,
            )
            .toList(growable: false);

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.initialOffering == null
                                  ? 'Create offering'
                                  : 'Edit offering',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Assign the subject, staff, capacity, and semester details.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _LookupField(
                    label: 'Subject',
                    value: _subjectId,
                    items: vm.subjects,
                    itemLabel: (item) =>
                        '${item.subtitle ?? ''} - ${item.label}',
                    onChanged: (value) {
                      setState(() {
                        _subjectId = value;
                        final selected = vm.subjects.where(
                          (item) => item.id == value,
                        );
                        if (selected.isNotEmpty) {
                          _departmentId = selected.first.group;
                          _sectionId = null;
                          _doctorId = null;
                          _assistantIds.clear();
                        }
                      });
                    },
                    validator: _requiredSelection,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _LookupField(
                          label: 'Department',
                          value: _departmentId,
                          items: vm.departments,
                          itemLabel: (item) => item.label,
                          onChanged: (value) {
                            setState(() {
                              _departmentId = value;
                              _sectionId = null;
                              _doctorId = null;
                              _assistantIds.clear();
                            });
                          },
                          validator: _requiredSelection,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _LookupField(
                          label: 'Section',
                          value: _sectionId,
                          items: sectionOptions,
                          itemLabel: (item) => item.label,
                          onChanged: (value) =>
                              setState(() => _sectionId = value),
                          validator: _requiredSelection,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _LookupField(
                          label: 'Doctor',
                          value: _doctorId,
                          items: doctorOptions,
                          itemLabel: (item) => item.label,
                          onChanged: (value) =>
                              setState(() => _doctorId = value),
                          validator: _requiredSelection,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _capacityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Capacity',
                            prefixIcon: Icon(Icons.event_seat_outlined),
                          ),
                          validator: (value) {
                            final parsed = int.tryParse(value ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid capacity';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _semester,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Semester',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Spring',
                              child: Text('Spring'),
                            ),
                            DropdownMenuItem(
                              value: 'Summer',
                              child: Text('Summer'),
                            ),
                            DropdownMenuItem(
                              value: 'Fall',
                              child: Text('Fall'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _semester = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(
                            labelText: 'Academic year',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Academic year is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Assistants',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final assistant in assistantOptions)
                        FilterChip(
                          label: Text(assistant.label),
                          selected: _assistantIds.contains(assistant.id),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _assistantIds.add(assistant.id);
                              } else {
                                _assistantIds.remove(assistant.id);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Status', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  CupertinoSlidingSegmentedControl<CourseOfferingStatus>(
                    groupValue: _status,
                    children: {
                      for (final status in CourseOfferingStatus.values)
                        status: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Text(status.label),
                        ),
                    },
                    onValueChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Start date',
                          value: _startDate,
                          onTap: () async {
                            final picked = await _pickDate(context, _startDate);
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _DateField(
                          label: 'End date',
                          value: _endDate,
                          onTap: () async {
                            final picked = await _pickDate(context, _endDate);
                            if (picked != null) {
                              setState(() => _endDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: PremiumButton(
                          label: 'Cancel',
                          icon: Icons.close_rounded,
                          isSecondary: true,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PremiumButton(
                          label: vm.isSubmitting
                              ? 'Saving...'
                              : widget.initialOffering == null
                              ? 'Create offering'
                              : 'Save changes',
                          icon: Icons.check_rounded,
                          onPressed: vm.isSubmitting
                              ? null
                              : () => _submit(context, vm.store),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit(BuildContext context, Store<AppState> store) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_startDate.isAfter(_endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date.')),
      );
      return;
    }

    final payload = CourseOfferingUpsertPayload(
      subjectId: _subjectId!,
      departmentId: _departmentId!,
      sectionId: _sectionId!,
      doctorId: _doctorId!,
      assistantIds: _assistantIds.toList(growable: false),
      semester: _semester,
      academicYear: _yearController.text.trim(),
      capacity: int.parse(_capacityController.text),
      enrolledCount: widget.initialOffering?.enrolledCount ?? 0,
      status: _status,
      startDate: _startDate,
      endDate: _endDate,
    );

    void onError(String message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    void onSuccess() {
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    }

    if (widget.initialOffering == null) {
      store.dispatch(
        CreateCourseOfferingAction(
          payload: payload,
          onSuccess: onSuccess,
          onError: onError,
        ),
      );
      return;
    }

    store.dispatch(
      UpdateCourseOfferingAction(
        offeringId: widget.initialOffering!.id,
        payload: payload,
        onSuccess: onSuccess,
        onError: onError,
      ),
    );
  }

  String? _requiredSelection(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
  }
}

class _OfferingFormViewModel {
  const _OfferingFormViewModel({
    required this.store,
    required this.isSubmitting,
    required this.subjects,
    required this.departments,
    required this.sections,
    required this.doctors,
    required this.assistants,
  });

  final Store<AppState> store;
  final bool isSubmitting;
  final List<CourseOfferingLookupOption> subjects;
  final List<CourseOfferingLookupOption> departments;
  final List<CourseOfferingLookupOption> sections;
  final List<CourseOfferingLookupOption> doctors;
  final List<CourseOfferingLookupOption> assistants;

  factory _OfferingFormViewModel.fromStore(Store<AppState> store) {
    final state = store.state.courseOfferingsState;
    return _OfferingFormViewModel(
      store: store,
      isSubmitting: state.mutationStatus == LoadStatus.loading,
      subjects: state.subjects,
      departments: state.departments,
      sections: state.sections,
      doctors: state.doctors,
      assistants: state.assistants,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _OfferingFormViewModel &&
        other.isSubmitting == isSubmitting &&
        other.subjects.length == subjects.length &&
        other.departments.length == departments.length &&
        other.sections.length == sections.length &&
        other.doctors.length == doctors.length &&
        other.assistants.length == assistants.length;
  }

  @override
  int get hashCode => Object.hash(
    isSubmitting,
    subjects.length,
    departments.length,
    sections.length,
    doctors.length,
    assistants.length,
  );
}

class _LookupField extends StatelessWidget {
  const _LookupField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String? value;
  final List<CourseOfferingLookupOption> items;
  final String Function(CourseOfferingLookupOption item) itemLabel;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      validator: validator,
      onChanged: onChanged,
      items: [
        for (final item in items)
          DropdownMenuItem<String>(
            value: item.id,
            child: Text(itemLabel(item)),
          ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      initialValue: DateFormat('d MMM yyyy').format(value),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today_outlined),
      ),
    );
  }
}
