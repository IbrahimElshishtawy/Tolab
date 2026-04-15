import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../data/repositories/mock_staff_portal_repository.dart';
import '../../domain/models/staff_portal_models.dart';
import '../providers/staff_portal_providers.dart';
import '../widgets/quiz_question_card.dart';

class QuizBuilderPage extends ConsumerStatefulWidget {
  const QuizBuilderPage({super.key, required this.subjectId, this.initialQuiz});

  final String subjectId;
  final StaffQuiz? initialQuiz;

  @override
  ConsumerState<QuizBuilderPage> createState() => _QuizBuilderPageState();
}

class _QuizBuilderPageState extends ConsumerState<QuizBuilderPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _startsAt;
  late DateTime _endsAt;
  late final TextEditingController _durationController;
  late bool _isGraded;
  late bool _isPractice;
  late List<StaffQuizQuestion> _questions;
  String _mode = 'build';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuiz;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _startsAt =
        initial?.startsAt ?? DateTime.now().add(const Duration(hours: 2));
    _endsAt =
        initial?.endsAt ??
        DateTime.now().add(const Duration(hours: 3, minutes: 30));
    _durationController = TextEditingController(
      text: '${initial?.durationMinutes ?? 30}',
    );
    _isGraded = initial?.isGraded ?? true;
    _isPractice = initial?.isPractice ?? false;
    _questions =
        initial?.questions.map((item) => item.copyWith()).toList() ??
        [_defaultQuestion(0)];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMarks = _questions.fold<int>(
      0,
      (sum, item) => sum + item.points,
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('منشئ الكويز', 'Quiz builder'))),
      body: SafeArea(
        child: AdaptivePageContainer(
          child: ListView(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('إعدادات الكويز', 'Quiz settings'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: context.tr('العنوان', 'Title'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: context.tr('الوصف', 'Description'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        _DateTile(
                          label: context.tr('وقت البداية', 'Start time'),
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
                        _DateTile(
                          label: context.tr('وقت النهاية', 'End time'),
                          value: _dateTimeLabel(_endsAt),
                          onTap: () async {
                            final value = await _pickDateTime(context, _endsAt);
                            if (value != null) {
                              setState(() => _endsAt = value);
                            }
                          },
                        ),
                        SizedBox(
                          width: 180,
                          child: TextField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: context.tr(
                                'المدة بالدقائق',
                                'Duration in minutes',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilterChip(
                          label: Text(context.tr('Quiz graded', 'Quiz graded')),
                          selected: _isGraded,
                          onSelected: (value) =>
                              setState(() => _isGraded = value),
                        ),
                        FilterChip(
                          label: Text(
                            context.tr('Practice quiz', 'Practice quiz'),
                          ),
                          selected: _isPractice,
                          onSelected: (value) =>
                              setState(() => _isPractice = value),
                        ),
                        Chip(
                          label: Text(
                            context.tr(
                              'عدد الأسئلة: ${_questions.length}',
                              'Questions: ${_questions.length}',
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            context.tr(
                              'إجمالي الدرجات: $totalMarks',
                              'Total marks: $totalMarks',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppSegmentedControl<String>(
                      groupValue: _mode,
                      onValueChanged: (value) => setState(() => _mode = value),
                      children: {
                        'build': Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Text(context.tr('التحرير', 'Build')),
                        ),
                        'preview': Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Text(context.tr('المعاينة', 'Preview')),
                        ),
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_mode == 'build') ...[
                Row(
                  children: [
                    Text(
                      context.tr('الأسئلة', 'Questions'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    AppButton(
                      label: context.tr('إضافة سؤال', 'Add question'),
                      icon: Icons.add_rounded,
                      isExpanded: false,
                      onPressed: () {
                        setState(
                          () => _questions.add(
                            _defaultQuestion(_questions.length),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ..._questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: QuizQuestionCard(
                      index: index,
                      question: question,
                      canMoveUp: index > 0,
                      canMoveDown: index < _questions.length - 1,
                      onTitleChanged: (value) => _updateQuestion(
                        index,
                        question.copyWith(title: value),
                      ),
                      onPointsChanged: (value) => _updateQuestion(
                        index,
                        question.copyWith(points: value),
                      ),
                      onRequiredChanged: (value) => _updateQuestion(
                        index,
                        question.copyWith(isRequired: value),
                      ),
                      onTypeChanged: (value) => _updateQuestion(
                        index,
                        _questionWithType(question, value),
                      ),
                      onSampleAnswerChanged: (value) => _updateQuestion(
                        index,
                        question.copyWith(sampleAnswer: value),
                      ),
                      onAddChoice: () => _updateQuestion(
                        index,
                        question.copyWith(
                          choices: [
                            ...question.choices,
                            StaffQuizChoice(
                              id: 'choice-${question.choices.length + 1}',
                              label: '',
                            ),
                          ],
                        ),
                      ),
                      onChoiceChanged: (choiceIndex, value) {
                        final choices = [...question.choices];
                        choices[choiceIndex] = choices[choiceIndex].copyWith(
                          label: value,
                        );
                        _updateQuestion(
                          index,
                          question.copyWith(choices: choices),
                        );
                      },
                      onChoiceCorrectToggled: (choiceIndex, selected) {
                        final choices = [...question.choices];
                        final singleAnswerTypes = {
                          StaffQuestionType.multipleChoice,
                          StaffQuestionType.trueFalse,
                          StaffQuestionType.dropdown,
                        };
                        for (
                          var itemIndex = 0;
                          itemIndex < choices.length;
                          itemIndex++
                        ) {
                          choices[itemIndex] = choices[itemIndex].copyWith(
                            isCorrect: singleAnswerTypes.contains(question.type)
                                ? itemIndex == choiceIndex
                                : itemIndex == choiceIndex
                                ? selected
                                : choices[itemIndex].isCorrect,
                          );
                        }
                        _updateQuestion(
                          index,
                          question.copyWith(choices: choices),
                        );
                      },
                      onRemoveChoice: (choiceIndex) {
                        final choices = [...question.choices]
                          ..removeAt(choiceIndex);
                        _updateQuestion(
                          index,
                          question.copyWith(choices: choices),
                        );
                      },
                      onDuplicate: () {
                        final nextQuestions = [..._questions];
                        nextQuestions.insert(
                          index + 1,
                          question.copyWith(
                            id: 'question-${DateTime.now().microsecondsSinceEpoch}',
                          ),
                        );
                        setState(() => _questions = nextQuestions);
                      },
                      onDelete: () {
                        if (_questions.length == 1) {
                          return;
                        }
                        final nextQuestions = [..._questions]..removeAt(index);
                        setState(() => _questions = nextQuestions);
                      },
                      onMoveUp: () => _moveQuestion(index, index - 1),
                      onMoveDown: () => _moveQuestion(index, index + 1),
                    ),
                  );
                }),
              ] else
                _QuizPreview(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  startsAt: _startsAt,
                  endsAt: _endsAt,
                  durationMinutes: int.tryParse(_durationController.text) ?? 30,
                  questions: _questions,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: context.tr('حفظ كمسودة', 'Save draft'),
                variant: AppButtonVariant.secondary,
                onPressed: _isSaving
                    ? null
                    : () => _saveQuiz(context, StaffQuizStatus.draft),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: _isSaving
                    ? context.tr('جارٍ النشر...', 'Publishing...')
                    : context.tr('نشر الكويز', 'Publish quiz'),
                onPressed: _isSaving
                    ? null
                    : () => _saveQuiz(context, StaffQuizStatus.published),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuestion(int index, StaffQuizQuestion nextQuestion) {
    final nextQuestions = [..._questions];
    nextQuestions[index] = nextQuestion;
    setState(() => _questions = nextQuestions);
  }

  void _moveQuestion(int from, int to) {
    if (to < 0 || to >= _questions.length) {
      return;
    }
    final nextQuestions = [..._questions];
    final item = nextQuestions.removeAt(from);
    nextQuestions.insert(to, item);
    setState(() => _questions = nextQuestions);
  }

  StaffQuizQuestion _defaultQuestion(int index) {
    return StaffQuizQuestion(
      id: 'question-$index',
      type: StaffQuestionType.multipleChoice,
      title: '',
      points: 1,
      isRequired: true,
      choices: const [
        StaffQuizChoice(id: 'choice-1', label: ''),
        StaffQuizChoice(id: 'choice-2', label: ''),
      ],
    );
  }

  StaffQuizQuestion _questionWithType(
    StaffQuizQuestion question,
    StaffQuestionType type,
  ) {
    if (type == StaffQuestionType.trueFalse) {
      return question.copyWith(
        type: type,
        choices: const [
          StaffQuizChoice(id: 'true', label: 'True'),
          StaffQuizChoice(id: 'false', label: 'False', isCorrect: true),
        ],
        sampleAnswer: '',
      );
    }

    if ({
      StaffQuestionType.multipleChoice,
      StaffQuestionType.checkbox,
      StaffQuestionType.dropdown,
    }.contains(type)) {
      return question.copyWith(
        type: type,
        choices: question.choices.length >= 2
            ? question.choices
            : const [
                StaffQuizChoice(id: 'choice-1', label: ''),
                StaffQuizChoice(id: 'choice-2', label: ''),
              ],
        sampleAnswer: '',
      );
    }

    return question.copyWith(type: type, choices: const []);
  }

  Future<void> _saveQuiz(BuildContext context, StaffQuizStatus status) async {
    final error = _validateQuiz(status);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isSaving = true);
    final repository = ref.read(staffPortalRepositoryProvider);
    final duration = int.tryParse(_durationController.text.trim()) ?? 30;

    await repository.saveQuiz(
      subjectId: widget.subjectId,
      quiz: StaffQuiz(
        id: widget.initialQuiz?.id ?? '',
        subjectId: widget.subjectId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startsAt: _startsAt,
        endsAt: _endsAt,
        durationMinutes: duration,
        status: status,
        isGraded: _isGraded,
        isPractice: _isPractice,
        questions: _questions,
        createdBy: 'staff',
      ),
    );

    ref.invalidate(staffSubjectWorkspaceProvider(widget.subjectId));
    ref.invalidate(staffDashboardProvider);
    ref.invalidate(staffCoursesProvider);
    if (!mounted) {
      return;
    }
    Navigator.of(this.context).pop();
  }

  String? _validateQuiz(StaffQuizStatus status) {
    if (_titleController.text.trim().isEmpty) {
      return context.tr('عنوان الكويز مطلوب', 'Quiz title is required');
    }
    if (_endsAt.isBefore(_startsAt) || _endsAt.isAtSameMomentAs(_startsAt)) {
      return context.tr(
        'وقت النهاية يجب أن يكون بعد وقت البداية',
        'End time must be after start time',
      );
    }
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    if (duration <= 0) {
      return context.tr('أدخل مدة صحيحة', 'Enter a valid duration');
    }
    if (_questions.isEmpty) {
      return context.tr(
        'أضف سؤالًا واحدًا على الأقل',
        'Add at least one question',
      );
    }

    if (status == StaffQuizStatus.draft) {
      return null;
    }

    for (final question in _questions) {
      if (question.title.trim().isEmpty) {
        return context.tr(
          'كل سؤال يحتاج إلى نص واضح',
          'Every question needs a clear prompt',
        );
      }

      final usesChoices = {
        StaffQuestionType.multipleChoice,
        StaffQuestionType.checkbox,
        StaffQuestionType.trueFalse,
        StaffQuestionType.dropdown,
      }.contains(question.type);

      if (usesChoices) {
        if (question.choices.any((choice) => choice.label.trim().isEmpty)) {
          return context.tr(
            'كل الخيارات يجب أن تحتوي على نص',
            'Every choice must have text',
          );
        }
        if (!question.choices.any((choice) => choice.isCorrect)) {
          return context.tr(
            'حدد إجابة صحيحة لكل سؤال اختياري',
            'Select a correct answer for each choice-based question',
          );
        }
      }
    }

    return null;
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

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Text(value),
        ),
      ),
    );
  }
}

class _QuizPreview extends StatelessWidget {
  const _QuizPreview({
    required this.title,
    required this.description,
    required this.startsAt,
    required this.endsAt,
    required this.durationMinutes,
    required this.questions,
  });

  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;
  final int durationMinutes;
  final List<StaffQuizQuestion> questions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isEmpty
                    ? context.tr('عنوان بدون اسم', 'Untitled quiz')
                    : title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description.isEmpty
                    ? context.tr('لا يوجد وصف بعد', 'No description yet')
                    : description,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.tr(
                  'من ${startsAt.toLocal()} إلى ${endsAt.toLocal()}',
                  'From ${startsAt.toLocal()} to ${endsAt.toLocal()}',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.tr(
                  'المدة: $durationMinutes دقيقة',
                  'Duration: $durationMinutes minutes',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...questions.asMap().entries.map((entry) {
          final question = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key + 1}. ${question.title.isEmpty ? context.tr('سؤال غير مكتمل', 'Incomplete question') : question.title}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (question.choices.isNotEmpty)
                    ...question.choices.map(
                      (choice) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text('• ${choice.label}'),
                      ),
                    )
                  else
                    Text(
                      question.sampleAnswer?.isNotEmpty == true
                          ? question.sampleAnswer!
                          : context.tr('إجابة نصية مفتوحة', 'Open text answer'),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
