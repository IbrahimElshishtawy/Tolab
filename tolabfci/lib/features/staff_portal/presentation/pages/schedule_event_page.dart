import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/repositories/mock_staff_portal_repository.dart';
import '../../domain/models/staff_portal_models.dart';
import '../providers/staff_portal_providers.dart';

class ScheduleEventPage extends ConsumerStatefulWidget {
  const ScheduleEventPage({
    super.key,
    required this.subjectId,
    this.initialEvent,
  });

  final String subjectId;
  final StaffScheduleEvent? initialEvent;

  @override
  ConsumerState<ScheduleEventPage> createState() => _ScheduleEventPageState();
}

class _ScheduleEventPageState extends ConsumerState<ScheduleEventPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late StaffScheduleEventType _type;
  late DateTime _startsAt;
  late DateTime _endsAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialEvent?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialEvent?.description ?? '',
    );
    _type = widget.initialEvent?.type ?? StaffScheduleEventType.deadline;
    _startsAt =
        widget.initialEvent?.startsAt ??
        DateTime.now().add(const Duration(days: 1));
    _endsAt =
        widget.initialEvent?.endsAt ??
        DateTime.now().add(const Duration(days: 1, hours: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('إضافة موعد مهم', 'Add important date')),
      ),
      body: SafeArea(
        child: AdaptivePageContainer(
          child: ListView(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: context.tr('العنوان', 'Title'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: context.tr('الوصف', 'Description'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<StaffScheduleEventType>(
                      initialValue: _type,
                      decoration: InputDecoration(
                        labelText: context.tr('نوع الحدث', 'Event type'),
                      ),
                      items: StaffScheduleEventType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(_typeLabel(context, type)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _type = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            label: context.tr('البداية', 'Start'),
                            value: _dateTimeLabel(_startsAt),
                            onTap: () async {
                              final value = await _pickDateTime(
                                context,
                                _startsAt,
                              );
                              if (value != null) {
                                setState(() => _startsAt = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _DateField(
                            label: context.tr('النهاية', 'End'),
                            value: _dateTimeLabel(_endsAt),
                            onTap: () async {
                              final value = await _pickDateTime(
                                context,
                                _endsAt,
                              );
                              if (value != null) {
                                setState(() => _endsAt = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            if (widget.initialEvent != null) ...[
              Expanded(
                child: AppButton(
                  label: context.tr('حذف', 'Delete'),
                  variant: AppButtonVariant.secondary,
                  onPressed: _isSaving ? null : () => _delete(context),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: AppButton(
                label: _isSaving
                    ? context.tr('جارٍ الحفظ...', 'Saving...')
                    : context.tr('حفظ الموعد', 'Save event'),
                onPressed: _isSaving ? null : () => _save(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('العنوان مطلوب', 'Title is required')),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    await ref
        .read(staffPortalRepositoryProvider)
        .saveScheduleEvent(
          subjectId: widget.subjectId,
          event: StaffScheduleEvent(
            id: widget.initialEvent?.id ?? '',
            subjectId: widget.subjectId,
            type: _type,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            startsAt: _startsAt,
            endsAt: _endsAt,
            colorHex: _colorHex(_type),
          ),
        );
    ref.invalidate(staffSubjectWorkspaceProvider(widget.subjectId));
    ref.invalidate(staffScheduleProvider);
    ref.invalidate(staffDashboardProvider);
    if (!mounted) {
      return;
    }
    Navigator.of(this.context).pop();
  }

  Future<void> _delete(BuildContext context) async {
    await ref
        .read(staffPortalRepositoryProvider)
        .deleteScheduleEvent(
          subjectId: widget.subjectId,
          eventId: widget.initialEvent!.id,
        );
    ref.invalidate(staffSubjectWorkspaceProvider(widget.subjectId));
    ref.invalidate(staffScheduleProvider);
    if (!mounted) {
      return;
    }
    Navigator.of(this.context).pop();
  }

  String _typeLabel(BuildContext context, StaffScheduleEventType type) {
    return switch (type) {
      StaffScheduleEventType.quiz => context.tr('كويز', 'Quiz'),
      StaffScheduleEventType.lecture => context.tr('محاضرة', 'Lecture'),
      StaffScheduleEventType.section => context.tr('سكشن', 'Section'),
      StaffScheduleEventType.deadline => context.tr('Deadline', 'Deadline'),
      StaffScheduleEventType.exam => context.tr('امتحان', 'Exam'),
      StaffScheduleEventType.reminder => context.tr('تذكير', 'Reminder'),
    };
  }

  String _colorHex(StaffScheduleEventType type) {
    return switch (type) {
      StaffScheduleEventType.quiz => '#3DB6B0',
      StaffScheduleEventType.lecture => '#4E7CF5',
      StaffScheduleEventType.section => '#6D73F8',
      StaffScheduleEventType.deadline => '#F1B95D',
      StaffScheduleEventType.exam => '#E17878',
      StaffScheduleEventType.reminder => '#7A8AA0',
    };
  }

  String _dateTimeLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}/${value.month}/${value.day}  $hour:$minute';
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context,
    DateTime initial,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) {
      return null;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value),
      ),
    );
  }
}
