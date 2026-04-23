import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/app_spacing.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../models/doctor_assistant_models.dart';
import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../models/tasks_workspace_models.dart';

class TaskBuilderForm extends StatefulWidget {
  const TaskBuilderForm({
    super.key,
    required this.subjects,
    required this.onSaveTask,
  });

  final List<TeachingSubject> subjects;
  final ValueChanged<Map<String, dynamic>> onSaveTask;

  @override
  State<TaskBuilderForm> createState() => TaskBuilderFormState();
}

class TaskBuilderFormState extends State<TaskBuilderForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxScoreController = TextEditingController(text: '20');
  final _notesController = TextEditingController();

  TeachingSubject? _selectedSubject;
  String? _selectedTaskType = 'Assignment';
  String? _selectedAudience;
  DateTime? _selectedDate = DateTime(2026, 4, 24);
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 23, minute: 59);
  bool _sendNotification = true;
  bool _addToSchedule = true;
  bool _publishImmediately = false;
  bool _saveAsDraft = true;
  final List<_AttachmentDraft> _attachments = [];

  @override
  void initState() {
    super.initState();
    if (widget.subjects.isNotEmpty) {
      _selectedSubject = widget.subjects.first;
      final audiences = _audienceOptions;
      _selectedAudience = audiences.isEmpty ? null : audiences.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxScoreController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void prefillFromTask(TaskWorkspaceTask task) {
    final subjectMatches = widget.subjects
        .where((subject) => subject.id == task.subjectId)
        .toList(growable: false);
    final nextSubject = subjectMatches.isEmpty
        ? _selectedSubject
        : subjectMatches.first;
    setState(() {
      _selectedSubject = nextSubject;
      _selectedAudience = task.scopeLabel;
      _selectedTaskType = 'Assignment';
      _titleController.text = task.title;
      _descriptionController.text = task.quickInsight;
      _notesController.text =
          'Editing existing task from the operations board.';
      _selectedDate = task.dueAt ?? _selectedDate;
      _selectedTime = task.dueAt == null
          ? _selectedTime
          : TimeOfDay.fromDateTime(task.dueAt!);
      _publishImmediately = task.isPublished;
      _saveAsDraft = !task.isPublished;
    });
  }

  List<String> get _audienceOptions {
    final subject = _selectedSubject;
    if (subject == null) {
      return const <String>[];
    }
    return [
      'All students in ${subject.code}',
      ...subject.sections.map((section) => 'Section ${section.groupLabel}'),
      if (subject.name.toLowerCase().contains('software')) 'Project teams',
      if (subject.name.toLowerCase().contains('ai')) 'Research mini-groups',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Create Assignment / Task',
      subtitle:
          'A premium builder for structured task creation, publishing control, and delivery readiness.',
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
              taskType: _selectedTaskType ?? 'Assignment',
              deadlineLabel: _deadlineLabel,
              publishState: _publishImmediately
                  ? 'Publish ready'
                  : 'Draft mode',
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle(
              title: 'Task Setup',
              subtitle:
                  'Define the teaching context and student-facing instructions.',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildResponsiveRow(
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
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select the subject first' : null,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTaskType,
                  decoration: const InputDecoration(labelText: 'Task Type'),
                  items: const ['Assignment', 'Quiz', 'Project', 'Sheet']
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) =>
                      setState(() => _selectedTaskType = value),
                  validator: (value) =>
                      value == null ? 'Select the task type' : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Example: Graph Traversal Assignment',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length < 6) {
                  return 'Use a clearer academic title';
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
                labelText: 'Description',
                hintText:
                    'Add instructions, expected deliverables, rubric highlights, and submission guidance.',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                if (value.trim().length < 20) {
                  return 'Add a fuller task brief for students';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle(
              title: 'Schedule and Scope',
              subtitle:
                  'Control the release window, target audience, and grading envelope.',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildResponsiveRow(
              context,
              children: [
                _PickerField(
                  label: 'Deadline Date',
                  value: _selectedDate == null
                      ? 'Select date'
                      : _formatDate(_selectedDate!),
                  icon: Icons.calendar_month_rounded,
                  onTap: _pickDate,
                ),
                _PickerField(
                  label: 'Deadline Time',
                  value: _selectedTime == null
                      ? 'Select time'
                      : _formatTime(_selectedTime!),
                  icon: Icons.schedule_rounded,
                  onTap: _pickTime,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildResponsiveRow(
              context,
              children: [
                TextFormField(
                  controller: _maxScoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max Score',
                    hintText: '20',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid score';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: _audienceOptions.contains(_selectedAudience)
                      ? _selectedAudience
                      : (_audienceOptions.isEmpty
                            ? null
                            : _audienceOptions.first),
                  decoration: const InputDecoration(
                    labelText: 'Audience / Scope',
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
                      ? 'Choose the audience'
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle(
              title: 'Attachments and Notes',
              subtitle:
                  'Keep the task pack complete before releasing it to students.',
            ),
            const SizedBox(height: AppSpacing.md),
            _AttachmentsComposer(
              attachments: _attachments,
              onAddAttachment: _addAttachment,
              onRemoveAttachment: (attachment) {
                setState(() => _attachments.remove(attachment));
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText:
                    'Optional internal notes for assistant coordination, schedule context, or review instructions.',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle(
              title: 'Publishing Controls',
              subtitle:
                  'Decide how the task should reach students and the academic calendar.',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildResponsiveRow(
              context,
              children: [
                _ToggleTile(
                  title: 'Send notification to students',
                  subtitle: 'Push the task alert to the notification feed.',
                  value: _sendNotification,
                  icon: Icons.notifications_rounded,
                  onChanged: (value) =>
                      setState(() => _sendNotification = value),
                ),
                _ToggleTile(
                  title: 'Add to schedule',
                  subtitle:
                      'Place the deadline in the academic schedule timeline.',
                  value: _addToSchedule,
                  icon: Icons.event_available_rounded,
                  onChanged: (value) => setState(() => _addToSchedule = value),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildResponsiveRow(
              context,
              children: [
                _ToggleTile(
                  title: 'Publish immediately',
                  subtitle: 'Make the task visible as soon as it is saved.',
                  value: _publishImmediately,
                  icon: Icons.publish_rounded,
                  onChanged: (value) {
                    setState(() {
                      _publishImmediately = value;
                      if (value) {
                        _saveAsDraft = false;
                      }
                    });
                  },
                ),
                _ToggleTile(
                  title: 'Save as draft',
                  subtitle: 'Keep the task private until the pack is ready.',
                  value: _saveAsDraft,
                  icon: Icons.inventory_2_rounded,
                  onChanged: (value) {
                    setState(() {
                      _saveAsDraft = value;
                      if (value) {
                        _publishImmediately = false;
                      }
                    });
                  },
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
                  label: const Text('Publish Task'),
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
      initialTime: _selectedTime ?? const TimeOfDay(hour: 23, minute: 59),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _addAttachment() async {
    final fileNameController = TextEditingController();
    String selectedType = 'PDF';
    final added = await showDialog<_AttachmentDraft>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Upload Attachment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fileNameController,
                    decoration: const InputDecoration(
                      labelText: 'Attachment name',
                      hintText: 'TaskBrief.pdf',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Format'),
                    items: const ['PDF', 'DOCX', 'XLSX', 'ZIP']
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final fileName = fileNameController.text.trim();
                    if (fileName.isEmpty) {
                      return;
                    }
                    Navigator.of(context).pop(
                      _AttachmentDraft(
                        fileName: fileName,
                        fileType: selectedType,
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
    fileNameController.dispose();
    if (added != null) {
      setState(() => _attachments.add(added));
    }
  }

  String get _deadlineLabel {
    if (_selectedDate == null || _selectedTime == null) {
      return 'Deadline not set';
    }
    final weekday = _weekday(_selectedDate!.weekday);
    final month = _month(_selectedDate!.month);
    return 'Due $weekday ${_selectedDate!.day} $month - ${_formatTime(_selectedTime!)}';
  }

  void _submit({required bool publish}) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose both deadline date and time.')),
      );
      return;
    }

    final shouldPublish = publish || _publishImmediately;
    final payload = <String, dynamic>{
      'subject_id': _selectedSubject?.id,
      'subject': _selectedSubject?.name,
      'task_type': _selectedTaskType,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'schedule': _deadlineLabel,
      'deadline_label': _deadlineLabel,
      'deadline_date': _selectedDate?.toIso8601String(),
      'deadline_time': _formatTime(_selectedTime!),
      'max_score': int.tryParse(_maxScoreController.text.trim()) ?? 20,
      'audience': _selectedAudience,
      'scope': _selectedAudience,
      'attachments': _attachments
          .map((attachment) => attachment.toJson())
          .toList(growable: false),
      'notes': _notesController.text.trim(),
      'send_notification': _sendNotification,
      'add_to_schedule': _addToSchedule,
      'publish_immediately': shouldPublish,
      'save_as_draft': !shouldPublish,
    };

    widget.onSaveTask(payload);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          shouldPublish
              ? 'Task published to the local academic workspace.'
              : 'Task saved as draft and added to the workspace queue.',
        ),
      ),
    );
    _resetForm(keepSubject: true);
  }

  void _resetForm({bool keepSubject = false}) {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _maxScoreController.text = '20';
      _notesController.clear();
      _selectedTaskType = 'Assignment';
      _selectedDate = DateTime(2026, 4, 24);
      _selectedTime = const TimeOfDay(hour: 23, minute: 59);
      _sendNotification = true;
      _addToSchedule = true;
      _publishImmediately = false;
      _saveAsDraft = true;
      _attachments.clear();
      if (!keepSubject) {
        _selectedSubject = widget.subjects.isEmpty
            ? null
            : widget.subjects.first;
      }
      final audiences = _audienceOptions;
      _selectedAudience = audiences.isEmpty ? null : audiences.first;
    });
  }

  Widget _buildResponsiveRow(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 920) {
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
}

class _BuilderHero extends StatelessWidget {
  const _BuilderHero({
    required this.subjectLabel,
    required this.taskType,
    required this.deadlineLabel,
    required this.publishState,
  });

  final String subjectLabel;
  final String taskType;
  final String deadlineLabel;
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
          _HeroChip(icon: Icons.category_rounded, label: taskType),
          _HeroChip(icon: Icons.schedule_rounded, label: deadlineLabel),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

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

class _AttachmentsComposer extends StatelessWidget {
  const _AttachmentsComposer({
    required this.attachments,
    required this.onAddAttachment,
    required this.onRemoveAttachment,
  });

  final List<_AttachmentDraft> attachments;
  final VoidCallback onAddAttachment;
  final ValueChanged<_AttachmentDraft> onRemoveAttachment;

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
                  'Attachments upload',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddAttachment,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload attachment'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            attachments.isEmpty
                ? 'No files attached yet. Add task briefs, rubrics, templates, or datasets.'
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
                  .map((attachment) {
                    return InputChip(
                      avatar: const Icon(Icons.attach_file_rounded, size: 18),
                      label: Text(
                        '${attachment.fileName} - ${attachment.fileType}',
                      ),
                      onDeleted: () => onRemoveAttachment(attachment),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttachmentDraft {
  const _AttachmentDraft({required this.fileName, required this.fileType});

  final String fileName;
  final String fileType;

  Map<String, dynamic> toJson() => {
    'file_name': fileName,
    'file_type': fileType,
  };
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
