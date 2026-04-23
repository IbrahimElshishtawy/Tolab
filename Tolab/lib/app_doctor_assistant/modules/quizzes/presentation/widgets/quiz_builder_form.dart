import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../models/doctor_assistant_models.dart';
import '../models/quiz_builder_models.dart';
import '../models/quizzes_workspace_models.dart';
import 'quiz_question_card.dart';

class QuizBuilderForm extends StatefulWidget {
  const QuizBuilderForm({
    super.key,
    required this.subjects,
    required this.onSaveQuiz,
  });

  final List<TeachingSubject> subjects;
  final ValueChanged<Map<String, dynamic>> onSaveQuiz;

  @override
  State<QuizBuilderForm> createState() => QuizBuilderFormState();
}

class QuizBuilderFormState extends State<QuizBuilderForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _attemptsController = TextEditingController(text: '1');
  final List<String> _attachments = <String>[];

  TeachingSubject? _selectedSubject;
  String? _selectedAudience;
  DateTime? _startDate = DateTime(2026, 4, 24);
  TimeOfDay? _startTime = const TimeOfDay(hour: 10, minute: 30);
  DateTime? _endDate = DateTime(2026, 4, 24);
  TimeOfDay? _endTime = const TimeOfDay(hour: 11, minute: 0);
  int? _editingQuizId;
  List<QuizBuilderQuestionDraft> _questions = <QuizBuilderQuestionDraft>[
    _defaultQuestion(),
  ];

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
    _durationController.dispose();
    _attemptsController.dispose();
    super.dispose();
  }

  void prefillFromQuiz(QuizWorkspaceItem quiz) {
    final subject = widget.subjects.firstWhere(
      (item) => item.id == quiz.subjectId,
      orElse: () => _selectedSubject ?? widget.subjects.first,
    );
    setState(() {
      _editingQuizId = quiz.id;
      _selectedSubject = subject;
      _selectedAudience = quiz.audienceLabel;
      _titleController.text = quiz.title;
      _descriptionController.text = quiz.description;
      _durationController.text = quiz.durationMinutes.toString();
      _attemptsController.text = quiz.attemptsAllowed.toString();
      _startDate = quiz.startAt;
      _startTime = TimeOfDay.fromDateTime(quiz.startAt);
      _endDate = quiz.endAt;
      _endTime = TimeOfDay.fromDateTime(quiz.endAt);
      _attachments
        ..clear()
        ..addAll(
          quiz.attachmentName == null
              ? const <String>[]
              : [quiz.attachmentName!],
        );
      _questions = quiz.questions
          .map(
            (question) => QuizBuilderQuestionDraft(
              id: question.id,
              prompt: question.prompt,
              type: question.type,
              options: List<String>.from(question.options),
              correctAnswers: List<String>.from(question.correctAnswers),
              marks: question.marks,
              isRequired: question.isRequired,
            ),
          )
          .toList(growable: false);
    });
  }

  List<String> get _audienceOptions {
    final subject = _selectedSubject;
    if (subject == null) {
      return const <String>[];
    }
    return <String>[
      'All students in ${subject.code}',
      ...subject.sections.map((section) => 'Section ${section.groupLabel}'),
      'High-priority cohort',
      'Revision cohort',
    ];
  }

  int get _totalMarks =>
      _questions.fold<int>(0, (sum, question) => sum + max(1, question.marks));

  bool get _isPublishable =>
      _selectedSubject != null &&
      _selectedAudience != null &&
      _titleController.text.trim().isNotEmpty &&
      _questions.any((question) => question.prompt.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: _editingQuizId == null ? 'Quiz Builder' : 'Edit Quiz',
      subtitle:
          'A Microsoft Forms style builder with academic timing, structure, and publishing control built in.',
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
              scheduleLabel: _windowLabel,
              statusLabel: _isPublishable ? 'Publishable' : 'Draft',
              totalSummary:
                  '${_questions.length} questions - $_totalMarks marks',
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionHeader(
              title: 'Basic Details',
              subtitle:
                  'Define the assessment context, description, schedule, and target audience.',
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
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz title',
                hintText: 'Example: Dynamic Programming Quiz 2',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Quiz title is required';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:
                    'Explain the learning scope, attempt expectations, and anything students should prepare before starting.',
              ),
              validator: (value) {
                if (value == null || value.trim().length < 16) {
                  return 'Add a short quiz description';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _responsiveRow(
              context,
              children: [
                _PickerField(
                  label: 'Start date',
                  value: _startDate == null
                      ? 'Select date'
                      : _formatDate(_startDate!),
                  icon: Icons.calendar_month_rounded,
                  onTap: () => _pickDate(isStart: true),
                ),
                _PickerField(
                  label: 'Start time',
                  value: _startTime == null
                      ? 'Select time'
                      : _formatTime(_startTime!),
                  icon: Icons.schedule_rounded,
                  onTap: () => _pickTime(isStart: true),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _responsiveRow(
              context,
              children: [
                _PickerField(
                  label: 'End date',
                  value: _endDate == null
                      ? 'Select date'
                      : _formatDate(_endDate!),
                  icon: Icons.event_available_rounded,
                  onTap: () => _pickDate(isStart: false),
                ),
                _PickerField(
                  label: 'End time',
                  value: _endTime == null
                      ? 'Select time'
                      : _formatTime(_endTime!),
                  icon: Icons.timer_rounded,
                  onTap: () => _pickTime(isStart: false),
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
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid duration';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _attemptsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Attempts allowed',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid number of attempts';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _BuilderStatRow(
              leftLabel: 'Status',
              leftValue: _isPublishable ? 'Publishable' : 'Draft',
              rightLabel: 'Total marks',
              rightValue: '$_totalMarks',
            ),
            const SizedBox(height: AppSpacing.md),
            _AttachmentsPanel(
              attachments: _attachments,
              onAddAttachment: _pickAttachment,
              onRemoveAttachment: (item) {
                setState(() => _attachments.remove(item));
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionHeader(
              title: 'Questions Builder',
              subtitle:
                  'Build questions like a proper assessment form with reordering, duplication, and marking logic.',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: DashboardThemeTokens.of(context).surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: DashboardThemeTokens.of(context).border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_questions.length} questions - $_totalMarks total marks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add question'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              buildDefaultDragHandles: false,
              onReorder: _reorderQuestions,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return Padding(
                  key: ValueKey<String>(question.id),
                  padding: EdgeInsets.only(
                    bottom: index == _questions.length - 1 ? 0 : AppSpacing.md,
                  ),
                  child: QuizQuestionCard(
                    index: index,
                    question: question,
                    onChanged: (updated) {
                      setState(() {
                        _questions[index] = updated;
                      });
                    },
                    onDelete: () => _deleteQuestion(index),
                    onDuplicate: () => _duplicateQuestion(index),
                  ),
                );
              },
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
                  onPressed: _previewDraft,
                  icon: const Icon(Icons.preview_rounded),
                  label: const Text('Preview'),
                ),
                FilledButton.icon(
                  onPressed: () => _submit(publish: true),
                  icon: const Icon(Icons.publish_rounded),
                  label: const Text('Publish Quiz'),
                ),
                OutlinedButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime(2026, 4, 24))
        : (_endDate ?? _startDate ?? DateTime(2026, 4, 24));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isStart) {
        _startDate = picked;
        _endDate ??= picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialTime = isStart
        ? (_startTime ?? const TimeOfDay(hour: 10, minute: 30))
        : (_endTime ?? const TimeOfDay(hour: 11, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
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

  void _addQuestion() {
    setState(() {
      _questions = <QuizBuilderQuestionDraft>[
        ..._questions,
        _defaultQuestion(),
      ];
    });
  }

  void _deleteQuestion(int index) {
    if (_questions.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keep at least one question in the quiz.'),
        ),
      );
      return;
    }
    setState(() {
      _questions = List<QuizBuilderQuestionDraft>.from(_questions)
        ..removeAt(index);
    });
  }

  void _duplicateQuestion(int index) {
    setState(() {
      final duplicate = _questions[index].duplicate();
      _questions = List<QuizBuilderQuestionDraft>.from(_questions)
        ..insert(index + 1, duplicate);
    });
  }

  void _reorderQuestions(int oldIndex, int newIndex) {
    setState(() {
      final next = List<QuizBuilderQuestionDraft>.from(_questions);
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = next.removeAt(oldIndex);
      next.insert(newIndex, item);
      _questions = next;
    });
  }

  void _previewDraft() {
    if (!_isPublishable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete the basic quiz setup before previewing.'),
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ListView(
                children: [
                  Text(
                    _titleController.text.trim(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _descriptionController.text.trim(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (var index = 0; index < _questions.length; index++) ...[
                    _PreviewQuestion(index: index, question: _questions[index]),
                    if (index != _questions.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit({required bool publish}) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (_selectedSubject == null || _selectedAudience == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select the subject and audience first.')),
      );
      return;
    }
    final startAt = _buildDateTime(_startDate, _startTime);
    final endAt = _buildDateTime(_endDate, _endTime);
    if (startAt == null || endAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose valid quiz start and end times.')),
      );
      return;
    }

    widget.onSaveQuiz(<String, dynamic>{
      'existing_id': _editingQuizId,
      'subject_id': _selectedSubject?.id,
      'subject': _selectedSubject?.name,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'date': _startDate?.toIso8601String(),
      'start_time_label': _formatTime(_startTime!),
      'duration_minutes': int.tryParse(_durationController.text.trim()) ?? 30,
      'attempts_allowed': int.tryParse(_attemptsController.text.trim()) ?? 1,
      'total_marks': _totalMarks,
      'audience': _selectedAudience,
      'scope': _selectedAudience,
      'attachment_name': _attachments.isEmpty ? null : _attachments.first,
      'attachments': _attachments,
      'questions': _questions.map((question) => question.toPayload()).toList(),
      'publish_immediately': publish,
      'save_as_draft': !publish,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          publish
              ? 'Quiz published into the academic workspace.'
              : 'Quiz saved as draft.',
        ),
      ),
    );
    _resetForm(keepSubject: true);
  }

  void _resetForm({bool keepSubject = false}) {
    setState(() {
      _editingQuizId = null;
      _titleController.clear();
      _descriptionController.clear();
      _durationController.text = '30';
      _attemptsController.text = '1';
      _startDate = DateTime(2026, 4, 24);
      _startTime = const TimeOfDay(hour: 10, minute: 30);
      _endDate = DateTime(2026, 4, 24);
      _endTime = const TimeOfDay(hour: 11, minute: 0);
      _questions = <QuizBuilderQuestionDraft>[_defaultQuestion()];
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

  DateTime? _buildDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String get _windowLabel {
    final start = _buildDateTime(_startDate, _startTime);
    final end = _buildDateTime(_endDate, _endTime);
    if (start == null || end == null) {
      return 'Window not set';
    }
    return '${_formatDate(start)} ${_formatTime(TimeOfDay.fromDateTime(start))} - ${_formatTime(TimeOfDay.fromDateTime(end))}';
  }
}

class _BuilderHero extends StatelessWidget {
  const _BuilderHero({
    required this.subjectLabel,
    required this.scheduleLabel,
    required this.statusLabel,
    required this.totalSummary,
  });

  final String subjectLabel;
  final String scheduleLabel;
  final String statusLabel;
  final String totalSummary;

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
          _HeroChip(icon: Icons.schedule_rounded, label: scheduleLabel),
          _HeroChip(icon: Icons.rule_folder_rounded, label: totalSummary),
          _HeroChip(icon: Icons.verified_rounded, label: statusLabel),
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

class _BuilderStatRow extends StatelessWidget {
  const _BuilderStatRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: tokens.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: tokens.border),
            ),
            child: _StatText(label: leftLabel, value: leftValue),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: tokens.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: tokens.border),
            ),
            child: _StatText(label: rightLabel, value: rightValue),
          ),
        ),
      ],
    );
  }
}

class _StatText extends StatelessWidget {
  const _StatText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AttachmentsPanel extends StatelessWidget {
  const _AttachmentsPanel({
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
                  'Attachment',
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
            attachments.isEmpty ? 'No attachment yet.' : 'Attached file set',
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
                      label: Text(item),
                      avatar: const Icon(
                        Icons.insert_drive_file_rounded,
                        size: 18,
                      ),
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

class _PreviewQuestion extends StatelessWidget {
  const _PreviewQuestion({required this.index, required this.question});

  final int index;
  final QuizBuilderQuestionDraft question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: DashboardThemeTokens.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. ${question.prompt}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (question.options.isEmpty)
            Text(
              question.type == 'paragraph'
                  ? 'Student paragraph response area'
                  : 'Student short answer field',
            )
          else
            ...question.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      question.type == 'checkbox'
                          ? Icons.check_box_outline_blank_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(option),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

QuizBuilderQuestionDraft _defaultQuestion() {
  final seed = DateTime.now().microsecondsSinceEpoch.toString();
  return QuizBuilderQuestionDraft(
    id: 'draft-$seed',
    prompt: '',
    type: 'multiple_choice',
    options: const <String>['Option 1', 'Option 2', 'Option 3', 'Option 4'],
    correctAnswers: const <String>['Option 1'],
    marks: 1,
    isRequired: true,
  );
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
