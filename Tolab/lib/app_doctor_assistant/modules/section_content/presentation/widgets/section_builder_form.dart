import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../models/doctor_assistant_models.dart';
import '../models/sections_workspace_models.dart';

class SectionBuilderForm extends StatefulWidget {
  const SectionBuilderForm({
    super.key,
    required this.subjects,
    required this.onSaveSection,
  });

  final List<TeachingSubject> subjects;
  final ValueChanged<Map<String, dynamic>> onSaveSection;

  @override
  State<SectionBuilderForm> createState() => SectionBuilderFormState();
}

class SectionBuilderFormState extends State<SectionBuilderForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '90');
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _expectedStudentsController = TextEditingController();

  TeachingSubject? _selectedSubject;
  String? _selectedAudience;
  String _sectionType = 'In person';
  DateTime? _selectedDate = DateTime(2026, 4, 24);
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 11, minute: 30);
  bool _publishNow = false;
  bool _saveAsDraft = true;
  bool _sendNotification = true;
  bool _addToSchedule = true;
  int? _editingSectionId;
  final List<String> _attachments = <String>[];

  @override
  void initState() {
    super.initState();
    if (widget.subjects.isNotEmpty) {
      _selectedSubject = widget.subjects.first;
      final audiences = _audienceOptions;
      _selectedAudience = audiences.isEmpty ? null : audiences.first;
      _expectedStudentsController.text = _expectedStudentsFor(
        _selectedSubject!,
      ).toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _expectedStudentsController.dispose();
    super.dispose();
  }

  void prefillFromSection(SectionWorkspaceItem section) {
    final nextSubject = widget.subjects.firstWhere(
      (subject) => subject.id == section.subjectId,
      orElse: () => _selectedSubject ?? widget.subjects.first,
    );
    setState(() {
      _editingSectionId = section.id;
      _selectedSubject = nextSubject;
      _selectedAudience = section.title.contains('Section')
          ? section.title
          : _audienceForSection(nextSubject, section);
      _titleController.text = section.title;
      _descriptionController.text = section.description;
      _durationController.text = section.durationMinutes.toString();
      _locationController.text = section.meetingLink ?? section.locationLabel;
      _notesController.text = section.notes ?? '';
      _expectedStudentsController.text = section.expectedStudents.toString();
      _sectionType = section.deliveryType;
      _selectedDate = section.scheduledAt;
      _selectedTime = TimeOfDay.fromDateTime(section.scheduledAt);
      _publishNow = section.statusLabel != 'Draft';
      _saveAsDraft = section.statusLabel == 'Draft';
      _sendNotification = true;
      _addToSchedule = true;
      _attachments
        ..clear()
        ..addAll(
          section.attachmentName == null
              ? const <String>[]
              : [section.attachmentName!],
        );
    });
  }

  List<String> get _audienceOptions {
    final subject = _selectedSubject;
    if (subject == null) {
      return const <String>[];
    }
    final sectionLabels = subject.sections
        .map((section) => 'Section ${section.groupLabel}')
        .toSet()
        .toList(growable: false);
    return [
      'All section groups',
      ...sectionLabels,
      'Lab track',
      'Revision cohort',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: _editingSectionId == null
          ? 'Smart Section Builder'
          : 'Edit Section Delivery',
      subtitle:
          'Build a section as an academic operation, not just a record. Scheduling, publishing, reminders, and access details live together here.',
      isHero: true,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BuilderHero(
              subjectLabel: _selectedSubject == null
                  ? 'Select a subject'
                  : '${_selectedSubject!.code} - ${_selectedSubject!.name}',
              sectionType: _sectionType,
              scheduleLabel: _scheduleLabel,
              publishState: _publishNow ? 'Publish now' : 'Draft mode',
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionHeader(
              title: 'Section Setup',
              subtitle:
                  'Lock the teaching context, section scope, and delivery framing first.',
            ),
            const SizedBox(height: AppSpacing.md),
            _responsiveRow(
              context,
              children: [
                DropdownButtonFormField<TeachingSubject>(
                  initialValue: _selectedSubject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: widget.subjects
                      .map(
                        (subject) => DropdownMenuItem<TeachingSubject>(
                          value: subject,
                          child: Text('${subject.code} - ${subject.name}'),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                      final audiences = _audienceOptions;
                      _selectedAudience = audiences.isEmpty
                          ? null
                          : audiences.first;
                      if (value != null) {
                        _expectedStudentsController.text = _expectedStudentsFor(
                          value,
                        ).toString();
                      }
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select the subject first' : null,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _audienceOptions.contains(_selectedAudience)
                      ? _selectedAudience
                      : (_audienceOptions.isEmpty
                            ? null
                            : _audienceOptions.first),
                  decoration: const InputDecoration(
                    labelText: 'Audience / Section group',
                  ),
                  items: _audienceOptions
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) =>
                      setState(() => _selectedAudience = value),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Choose the section audience'
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Section title',
                hintText: 'Example: Sorting Lab - Week 6',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Section title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Short description',
                hintText:
                    'Summarize teaching goals, room setup, practical flow, and what students should prepare before joining.',
              ),
              validator: (value) {
                if (value == null || value.trim().length < 24) {
                  return 'Add a fuller section brief';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionHeader(
              title: 'Schedule and Access',
              subtitle:
                  'Make the session ready to run with date, time, duration, and the correct access point.',
            ),
            const SizedBox(height: AppSpacing.md),
            _responsiveRow(
              context,
              children: [
                _PickerField(
                  label: 'Date',
                  value: _selectedDate == null
                      ? 'Select date'
                      : _formatDate(_selectedDate!),
                  icon: Icons.calendar_month_rounded,
                  onTap: _pickDate,
                ),
                _PickerField(
                  label: 'Time',
                  value: _selectedTime == null
                      ? 'Select time'
                      : _formatTime(_selectedTime!),
                  icon: Icons.schedule_rounded,
                  onTap: _pickTime,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _responsiveRow(
              context,
              children: [
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    hintText: '90',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid duration';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: _sectionType,
                  decoration: const InputDecoration(labelText: 'Section type'),
                  items: const ['In person', 'Online']
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _sectionType = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _responsiveRow(
              context,
              children: [
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: _sectionType == 'Online'
                        ? 'Meeting link'
                        : 'Location / room',
                    hintText: _sectionType == 'Online'
                        ? 'https://meet.tolab.edu/algorithms-b2'
                        : 'Lab C2 / Smart Room 4',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Add the location or meeting link';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _expectedStudentsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Expected students',
                    hintText: '32',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid expected count';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionHeader(
              title: 'Notes and Attachments',
              subtitle:
                  'Keep operational notes and supporting files visible for the teaching team.',
            ),
            const SizedBox(height: AppSpacing.md),
            _AttachmentPanel(
              attachments: _attachments,
              onAddAttachment: _pickAttachment,
              onRemoveAttachment: (item) {
                setState(() => _attachments.remove(item));
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText:
                    'Optional notes for room preparation, assistant coordination, attendance handling, or follow-up after the section.',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionHeader(
              title: 'Publishing Controls',
              subtitle:
                  'Decide how the section should appear in the student experience and schedule.',
            ),
            const SizedBox(height: AppSpacing.md),
            _responsiveRow(
              context,
              children: [
                _ToggleTile(
                  title: 'Publish now',
                  subtitle: 'Make the section visible immediately when saved.',
                  value: _publishNow,
                  icon: Icons.publish_rounded,
                  onChanged: (value) {
                    setState(() {
                      _publishNow = value;
                      if (value) {
                        _saveAsDraft = false;
                      }
                    });
                  },
                ),
                _ToggleTile(
                  title: 'Save as draft',
                  subtitle: 'Keep editing before students can see it.',
                  value: _saveAsDraft,
                  icon: Icons.inventory_2_rounded,
                  onChanged: (value) {
                    setState(() {
                      _saveAsDraft = value;
                      if (value) {
                        _publishNow = false;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _responsiveRow(
              context,
              children: [
                _ToggleTile(
                  title: 'Send notification to students',
                  subtitle: 'Push a reminder to the student notification feed.',
                  value: _sendNotification,
                  icon: Icons.notifications_active_rounded,
                  onChanged: (value) =>
                      setState(() => _sendNotification = value),
                ),
                _ToggleTile(
                  title: 'Add to schedule',
                  subtitle: 'Place the section inside the academic calendar.',
                  value: _addToSchedule,
                  icon: Icons.event_available_rounded,
                  onChanged: (value) => setState(() => _addToSchedule = value),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: () => _submit(publish: false),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Draft'),
                ),
                FilledButton.icon(
                  onPressed: () => _submit(publish: true),
                  icon: const Icon(Icons.publish_rounded),
                  label: const Text('Publish Now'),
                ),
                OutlinedButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.subjects),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to subjects'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2026, 4, 24),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 11, minute: 30),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) {
      return;
    }
    setState(() {
      for (final file in result.files) {
        if (file.name.isNotEmpty) {
          _attachments.add(file.name);
        }
      }
    });
  }

  void _submit({required bool publish}) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose both date and time.')),
      );
      return;
    }

    final shouldPublish = publish || _publishNow;
    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    widget.onSaveSection(<String, dynamic>{
      'existing_id': _editingSectionId,
      'subject_id': _selectedSubject?.id,
      'subject': _selectedSubject?.name,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'scheduled_at': scheduledAt.toIso8601String(),
      'date': _selectedDate!.toIso8601String(),
      'time_label': _formatTime(_selectedTime!),
      'duration_minutes': int.tryParse(_durationController.text.trim()) ?? 90,
      'section_type': _sectionType,
      'location_or_link': _locationController.text.trim(),
      'location_label': _sectionType == 'In person'
          ? _locationController.text.trim()
          : null,
      'meeting_link': _sectionType == 'Online'
          ? _locationController.text.trim()
          : null,
      'audience': _selectedAudience,
      'scope': _selectedAudience,
      'expected_students':
          int.tryParse(_expectedStudentsController.text.trim()) ?? 0,
      'notes': _notesController.text.trim(),
      'attachment_name': _attachments.isEmpty ? null : _attachments.first,
      'attachments': _attachments,
      'send_notification': _sendNotification,
      'add_to_schedule': _addToSchedule,
      'publish_immediately': shouldPublish,
      'save_as_draft': !shouldPublish,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          shouldPublish
              ? 'Section published into the workspace.'
              : 'Section saved as draft.',
        ),
      ),
    );
    _resetForm(keepSubject: true);
  }

  void _resetForm({bool keepSubject = false}) {
    setState(() {
      _editingSectionId = null;
      _titleController.clear();
      _descriptionController.clear();
      _durationController.text = '90';
      _locationController.clear();
      _notesController.clear();
      _sectionType = 'In person';
      _selectedDate = DateTime(2026, 4, 24);
      _selectedTime = const TimeOfDay(hour: 11, minute: 30);
      _publishNow = false;
      _saveAsDraft = true;
      _sendNotification = true;
      _addToSchedule = true;
      _attachments.clear();
      if (!keepSubject) {
        _selectedSubject = widget.subjects.isEmpty
            ? null
            : widget.subjects.first;
      }
      final audiences = _audienceOptions;
      _selectedAudience = audiences.isEmpty ? null : audiences.first;
      if (_selectedSubject != null) {
        _expectedStudentsController.text = _expectedStudentsFor(
          _selectedSubject!,
        ).toString();
      } else {
        _expectedStudentsController.clear();
      }
    });
  }

  Widget _responsiveRow(
    BuildContext context, {
    required List<Widget> children,
  }) {
    if (MediaQuery.sizeOf(context).width < 920) {
      return Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          Expanded(child: children[index]),
          if (index != children.length - 1)
            const SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }

  int _expectedStudentsFor(TeachingSubject subject) {
    final sectionsCount = subject.sections.isEmpty
        ? 1
        : subject.sections.length;
    return (subject.studentCount / sectionsCount).ceil();
  }

  String _audienceForSection(
    TeachingSubject subject,
    SectionWorkspaceItem section,
  ) {
    for (final item in subject.sections) {
      final label = 'Section ${item.groupLabel}';
      if (section.title.toLowerCase().contains(label.toLowerCase()) ||
          (section.notes ?? '').toLowerCase().contains(label.toLowerCase())) {
        return label;
      }
    }
    if (subject.sections.isNotEmpty) {
      return 'Section ${subject.sections.first.groupLabel}';
    }
    return 'All section groups';
  }

  String get _scheduleLabel {
    if (_selectedDate == null || _selectedTime == null) {
      return 'Schedule not set';
    }
    return '${_formatDate(_selectedDate!)} - ${_formatTime(_selectedTime!)}';
  }
}

class _BuilderHero extends StatelessWidget {
  const _BuilderHero({
    required this.subjectLabel,
    required this.sectionType,
    required this.scheduleLabel,
    required this.publishState,
  });

  final String subjectLabel;
  final String sectionType;
  final String scheduleLabel;
  final String publishState;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          _HeroChip(icon: Icons.menu_book_rounded, label: subjectLabel),
          _HeroChip(icon: Icons.widgets_rounded, label: sectionType),
          _HeroChip(icon: Icons.schedule_rounded, label: scheduleLabel),
          _HeroChip(icon: Icons.verified_rounded, label: publishState),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: tokens.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tokens.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tokens.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon, color: tokens.primary),
        ),
        child: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: tokens.textPrimary),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: tokens.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tokens.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AttachmentPanel extends StatelessWidget {
  const _AttachmentPanel({
    required this.attachments,
    required this.onAddAttachment,
    required this.onRemoveAttachment,
  });

  final List<String> attachments;
  final VoidCallback onAddAttachment;
  final ValueChanged<String> onRemoveAttachment;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attachments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddAttachment,
                icon: const Icon(Icons.attach_file_rounded),
                label: const Text('Add file'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            attachments.isEmpty
                ? 'No attachment selected yet. Add room guides, worksheets, or instructions if needed.'
                : 'Attached files',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: attachments
                  .map(
                    (item) => InputChip(
                      avatar: const Icon(
                        Icons.insert_drive_file_rounded,
                        size: 18,
                      ),
                      label: Text(item),
                      onDeleted: () => onRemoveAttachment(item),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  return '${_weekday(value.weekday)}, ${value.day} ${_month(value.month)} ${value.year}';
}

String _formatTime(TimeOfDay value) {
  final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String _weekday(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'Mon',
    DateTime.tuesday => 'Tue',
    DateTime.wednesday => 'Wed',
    DateTime.thursday => 'Thu',
    DateTime.friday => 'Fri',
    DateTime.saturday => 'Sat',
    _ => 'Sun',
  };
}

String _month(int month) {
  return switch (month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    _ => 'Dec',
  };
}
