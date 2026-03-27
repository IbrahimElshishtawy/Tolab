import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../shared/forms/app_dropdown_field.dart';
import '../../../shared/forms/app_text_field.dart';
import '../../../shared/widgets/premium_button.dart';
import '../models/schedule_models.dart';

// Modal editor for creating, updating, and deleting schedule events.
class ScheduleEventFormDialog extends StatefulWidget {
  const ScheduleEventFormDialog({
    super.key,
    required this.lookups,
    required this.onSubmit,
    required this.onDelete,
    this.initialEvent,
    this.initialDate,
  });

  final ScheduleLookupBundle lookups;
  final ScheduleEventItem? initialEvent;
  final DateTime? initialDate;
  final ValueChanged<ScheduleEventUpsertPayload> onSubmit;
  final VoidCallback? onDelete;

  static Future<void> show(
    BuildContext context, {
    required ScheduleLookupBundle lookups,
    required ValueChanged<ScheduleEventUpsertPayload> onSubmit,
    VoidCallback? onDelete,
    ScheduleEventItem? initialEvent,
    DateTime? initialDate,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Schedule form',
      barrierColor: Colors.black.withValues(alpha: 0.18),
      transitionDuration: AppMotion.slow,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScheduleEventFormDialog(
            lookups: lookups,
            initialEvent: initialEvent,
            initialDate: initialDate,
            onSubmit: onSubmit,
            onDelete: onDelete,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.entrance,
          reverseCurve: AppMotion.emphasized,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ScheduleEventFormDialog> createState() =>
      _ScheduleEventFormDialogState();
}

class _ScheduleEventFormDialogState extends State<ScheduleEventFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _noteController;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late ScheduleEventType _type;
  late ScheduleEventStatus _status;
  late ScheduleRepeatRule _repeatRule;
  String? _departmentId;
  String? _yearId;
  String? _subjectId;
  String? _instructorId;
  String? _sectionId;
  String? _offeringId;
  late Set<String> _assignedStaffIds;

  bool get _isEditing => widget.initialEvent != null;

  @override
  void initState() {
    super.initState();
    final event = widget.initialEvent;
    final initialDate = widget.initialDate ?? event?.startAt ?? DateTime.now();
    _titleController = TextEditingController(text: event?.title ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    _noteController = TextEditingController(text: event?.note ?? '');
    _date = DateTime(initialDate.year, initialDate.month, initialDate.day);
    _startTime = TimeOfDay.fromDateTime(
      event?.startAt ?? initialDate.copyWith(hour: 9, minute: 0),
    );
    _endTime = TimeOfDay.fromDateTime(
      event?.endAt ?? initialDate.copyWith(hour: 11, minute: 0),
    );
    _type = event?.type ?? ScheduleEventType.lecture;
    _status = event?.status ?? ScheduleEventStatus.planned;
    _repeatRule = event?.repeatRule ?? ScheduleRepeatRule.none;
    _departmentId = event?.department;
    _yearId = event?.yearLabel;
    _subjectId = event?.subjectId;
    _instructorId = event?.instructorId;
    _sectionId = event?.sectionId;
    _offeringId = event?.courseOfferingId;
    _assignedStaffIds = {...event?.assignedStaffIds ?? const <String>[]};
    if (_instructorId != null) {
      _assignedStaffIds.add(_instructorId!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Material(
                color: Theme.of(context).cardColor.withValues(alpha: 0.94),
                child: Padding(
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
                                  _isEditing
                                      ? 'Edit schedule event'
                                      : 'Create schedule event',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Configure academic event details, participants, status, and repeat behavior.',
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                      const SizedBox(height: AppSpacing.xl),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopFields(context),
                              const SizedBox(height: AppSpacing.lg),
                              _buildDateTimeRow(context),
                              const SizedBox(height: AppSpacing.lg),
                              _buildLookupRow(context),
                              const SizedBox(height: AppSpacing.lg),
                              _buildStaffAssignment(context),
                              const SizedBox(height: AppSpacing.lg),
                              AppTextField(
                                controller: _noteController,
                                label: 'Notes',
                                hint:
                                    'Add invigilation notes, room setup, or delivery instructions.',
                                maxLines: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          if (_isEditing && widget.onDelete != null)
                            PremiumButton(
                              label: 'Delete',
                              icon: Icons.delete_outline_rounded,
                              isDestructive: true,
                              onPressed: _handleDelete,
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              PremiumButton(
                                label: _isEditing
                                    ? 'Save changes'
                                    : 'Create event',
                                icon: _isEditing
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.add_rounded,
                                onPressed: _handleSubmit,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopFields(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        SizedBox(
          width: 340,
          child: AppTextField(
            controller: _titleController,
            label: 'Title',
            hint: 'Lecture 08, Quiz Window, Midterm Review',
          ),
        ),
        SizedBox(
          width: 260,
          child: AppTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'Hall A3, Lab C2, Online room',
          ),
        ),
        SizedBox(
          width: 220,
          child: AppDropdownField<ScheduleEventType>(
            label: 'Event type',
            value: _type,
            onChanged: (value) => setState(() => _type = value ?? _type),
            items: ScheduleEventType.values
                .map(
                  (type) => AppDropdownItem<ScheduleEventType>(
                    value: type,
                    label: type.label,
                    icon: type.icon,
                  ),
                )
                .toList(growable: false),
          ),
        ),
        SizedBox(
          width: 220,
          child: AppDropdownField<ScheduleEventStatus>(
            label: 'Status',
            value: _status,
            onChanged: (value) => setState(() => _status = value ?? _status),
            items: ScheduleEventStatus.values
                .map(
                  (status) => AppDropdownItem<ScheduleEventStatus>(
                    value: status,
                    label: status.label,
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _PickerTile(
          label: 'Date',
          value: DateFormat('EEEE, d MMM yyyy').format(_date),
          icon: Icons.calendar_today_rounded,
          onPressed: _pickDate,
        ),
        _PickerTile(
          label: 'Start time',
          value: _startTime.format(context),
          icon: Icons.schedule_rounded,
          onPressed: () => _pickTime(isStart: true),
        ),
        _PickerTile(
          label: 'End time',
          value: _endTime.format(context),
          icon: Icons.schedule_send_rounded,
          onPressed: () => _pickTime(isStart: false),
        ),
        SizedBox(
          width: 220,
          child: AppDropdownField<ScheduleRepeatRule>(
            label: 'Repeat',
            value: _repeatRule,
            onChanged: (value) =>
                setState(() => _repeatRule = value ?? _repeatRule),
            items: ScheduleRepeatRule.values
                .map(
                  (rule) => AppDropdownItem<ScheduleRepeatRule>(
                    value: rule,
                    label: rule.shortLabel,
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _buildLookupRow(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _LookupDropdown(
          width: 220,
          label: 'Department',
          value: _departmentId,
          items: widget.lookups.departments,
          onChanged: (value) => setState(() => _departmentId = value),
        ),
        _LookupDropdown(
          width: 220,
          label: 'Year',
          value: _yearId,
          items: widget.lookups.years,
          onChanged: (value) => setState(() => _yearId = value),
        ),
        _LookupDropdown(
          width: 280,
          label: 'Subject',
          value: _subjectId,
          items: widget.lookups.subjects,
          onChanged: (value) => setState(() => _subjectId = value),
        ),
        _LookupDropdown(
          width: 280,
          label: 'Instructor',
          value: _instructorId,
          items: widget.lookups.instructors,
          onChanged: (value) => setState(() {
            _instructorId = value;
            if (value != null) _assignedStaffIds.add(value);
          }),
        ),
        _LookupDropdown(
          width: 240,
          label: 'Section',
          value: _sectionId,
          items: widget.lookups.sections,
          onChanged: (value) => setState(() => _sectionId = value),
        ),
        _LookupDropdown(
          width: 300,
          label: 'Course offering',
          value: _offeringId,
          items: widget.lookups.offerings,
          onChanged: (value) => setState(() => _offeringId = value),
        ),
      ],
    );
  }

  Widget _buildStaffAssignment(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Assigned staff', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Choose the instructor and any additional staff supporting the event.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: widget.lookups.staff
              .map((member) {
                final selected = _assignedStaffIds.contains(member.id);
                return FilterChip(
                  selected: selected,
                  showCheckmark: false,
                  label: Text(member.label),
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _assignedStaffIds.remove(member.id);
                      } else {
                        _assignedStaffIds.add(member.id);
                      }
                    });
                  },
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final next = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (next == null) return;
    setState(() => _date = next);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final next = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (next == null) return;
    setState(() {
      if (isStart) {
        _startTime = next;
      } else {
        _endTime = next;
      }
    });
  }

  Future<void> _handleDelete() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete event',
      message: 'This schedule event will be removed from the calendar.',
    );
    if (!confirmed) return;
    widget.onDelete?.call();
    if (mounted) Navigator.of(context).pop();
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    if (title.isEmpty) {
      _showError('Event title is required.');
      return;
    }
    if (location.isEmpty) {
      _showError('Location is required.');
      return;
    }

    final startAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _endTime.hour,
      _endTime.minute,
    );
    if (!endAt.isAfter(startAt)) {
      _showError('End time must be later than start time.');
      return;
    }

    final sectionLabel = _labelOf(
      widget.lookups.sections,
      _sectionId,
      fallback: 'Section',
    );
    final subjectLabel = _labelOf(
      widget.lookups.subjects,
      _subjectId,
      fallback: 'Subject',
    );
    final instructorLabel = _labelOf(
      widget.lookups.instructors,
      _instructorId,
      fallback: 'Instructor',
    );
    final payload = ScheduleEventUpsertPayload(
      title: title,
      section: sectionLabel,
      subject: subjectLabel,
      instructor: instructorLabel,
      location: location,
      status: _status,
      type: _type,
      startAt: startAt,
      endAt: endAt,
      department:
          _departmentId ?? widget.initialEvent?.department ?? 'Department',
      yearLabel: _yearId ?? widget.initialEvent?.yearLabel ?? 'Year',
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      courseOfferingId: _offeringId,
      sectionId: _sectionId,
      subjectId: _subjectId,
      instructorId: _instructorId,
      studentScopeLabel: '$sectionLabel cohort',
      repeatRule: _repeatRule,
      assignedStaffIds: _assignedStaffIds.toList(growable: false),
    );
    widget.onSubmit(payload);
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _labelOf(
    List<ScheduleOption> items,
    String? id, {
    required String fallback,
  }) {
    if (id == null) return fallback;
    for (final item in items) {
      if (item.id == id) return item.label;
    }
    return fallback;
  }
}

class _LookupDropdown extends StatelessWidget {
  const _LookupDropdown({
    required this.width,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final double width;
  final String label;
  final String? value;
  final List<ScheduleOption> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppDropdownField<String>(
        label: label,
        value: value,
        onChanged: onChanged,
        items: items
            .map(
              (item) => AppDropdownItem<String>(
                value: item.id,
                label: item.subtitle == null
                    ? item.label
                    : '${item.label} • ${item.subtitle}',
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.smallRadius),
      onTap: onPressed,
      child: Ink(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(value, style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
