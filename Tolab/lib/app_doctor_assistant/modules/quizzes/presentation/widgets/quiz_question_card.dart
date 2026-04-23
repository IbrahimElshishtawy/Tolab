import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../../../core/design/app_spacing.dart';
import '../models/quiz_builder_models.dart';

class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.onChanged,
    required this.onDelete,
    required this.onDuplicate,
  });

  final int index;
  final QuizBuilderQuestionDraft question;
  final ValueChanged<QuizBuilderQuestionDraft> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      key: ValueKey<String>(question.id),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    DashboardToneBadge(
                      label: 'Question ${index + 1}',
                      tone: 'primary',
                    ),
                    DashboardToneBadge(
                      label: quizQuestionTypeLabel(question.type),
                      tone: question.type == 'paragraph'
                          ? 'warning'
                          : 'success',
                    ),
                    DashboardToneBadge(
                      label: question.isRequired ? 'Required' : 'Optional',
                      tone: question.isRequired ? 'danger' : 'warning',
                    ),
                  ],
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: question.prompt,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Question',
              hintText:
                  'Write the question exactly as the student should see it.',
            ),
            onChanged: (value) => onChanged(question.copyWith(prompt: value)),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: question.type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: quizQuestionTypes
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(quizQuestionTypeLabel(type)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    onChanged(
                      question.copyWith(
                        type: value,
                        options: _normalizeOptionsForType(
                          value,
                          currentOptions: question.options,
                        ),
                        correctAnswers: _normalizeCorrectAnswersForType(
                          value,
                          currentAnswers: question.correctAnswers,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextFormField(
                  initialValue: question.marks.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Marks'),
                  onChanged: (value) => onChanged(
                    question.copyWith(
                      marks: int.tryParse(value) ?? question.marks,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile.adaptive(
            value: question.isRequired,
            contentPadding: EdgeInsets.zero,
            title: const Text('Required question'),
            subtitle: const Text(
              'Students must answer this before submission.',
            ),
            onChanged: (value) =>
                onChanged(question.copyWith(isRequired: value)),
          ),
          if (_showsOptions(question.type)) ...[
            const SizedBox(height: AppSpacing.md),
            _OptionsEditor(question: question, onChanged: onChanged),
          ],
          const SizedBox(height: AppSpacing.md),
          _AnswerEditor(question: question, onChanged: onChanged),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.tonalIcon(
                onPressed: onDuplicate,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Duplicate'),
              ),
              FilledButton.tonalIcon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionsEditor extends StatelessWidget {
  const _OptionsEditor({required this.question, required this.onChanged});

  final QuizBuilderQuestionDraft question;
  final ValueChanged<QuizBuilderQuestionDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = _normalizeOptionsForType(
      question.type,
      currentOptions: question.options,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choices', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (var index = 0; index < options.length; index++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: options[index],
                  enabled: question.type != 'true_false',
                  decoration: InputDecoration(labelText: 'Choice ${index + 1}'),
                  onChanged: (value) {
                    final nextOptions = List<String>.from(options);
                    nextOptions[index] = value;
                    onChanged(question.copyWith(options: nextOptions));
                  },
                ),
              ),
              if (question.type != 'true_false') ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: options.length <= 2
                      ? null
                      : () {
                          final nextOptions = List<String>.from(options)
                            ..removeAt(index);
                          final nextCorrectAnswers = question.correctAnswers
                              .where((answer) => answer != options[index])
                              .toList(growable: false);
                          onChanged(
                            question.copyWith(
                              options: nextOptions,
                              correctAnswers: nextCorrectAnswers,
                            ),
                          );
                        },
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
              ],
            ],
          ),
          if (index != options.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
        if (question.type != 'true_false') ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () {
              final nextOptions = List<String>.from(options)
                ..add('Option ${options.length + 1}');
              onChanged(question.copyWith(options: nextOptions));
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add choice'),
          ),
        ],
      ],
    );
  }
}

class _AnswerEditor extends StatelessWidget {
  const _AnswerEditor({required this.question, required this.onChanged});

  final QuizBuilderQuestionDraft question;
  final ValueChanged<QuizBuilderQuestionDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = _normalizeOptionsForType(
      question.type,
      currentOptions: question.options,
    );
    if (question.type == 'multiple_choice' || question.type == 'true_false') {
      final selected = question.correctAnswers.isEmpty
          ? null
          : question.correctAnswers.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correct answer',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: options
                .map(
                  (option) => ChoiceChip(
                    label: Text(option),
                    selected: selected == option,
                    onSelected: (_) => onChanged(
                      question.copyWith(correctAnswers: <String>[option]),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      );
    }

    if (question.type == 'checkbox') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correct answers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: options
                .map(
                  (option) => FilterChip(
                    label: Text(option),
                    selected: question.correctAnswers.contains(option),
                    onSelected: (selected) {
                      final nextAnswers = List<String>.from(
                        question.correctAnswers,
                      );
                      if (selected) {
                        nextAnswers.add(option);
                      } else {
                        nextAnswers.remove(option);
                      }
                      onChanged(question.copyWith(correctAnswers: nextAnswers));
                    },
                  ),
                )
                .toList(growable: false),
          ),
        ],
      );
    }

    return TextFormField(
      initialValue: question.correctAnswers.join(', '),
      maxLines: question.type == 'paragraph' ? 3 : 1,
      decoration: InputDecoration(
        labelText: question.type == 'paragraph'
            ? 'Expected answer guidance'
            : 'Correct answer',
      ),
      onChanged: (value) => onChanged(
        question.copyWith(
          correctAnswers: value.trim().isEmpty
              ? const <String>[]
              : <String>[value.trim()],
        ),
      ),
    );
  }
}

bool _showsOptions(String type) {
  return type == 'multiple_choice' ||
      type == 'true_false' ||
      type == 'checkbox';
}

List<String> _normalizeOptionsForType(
  String type, {
  required List<String> currentOptions,
}) {
  if (type == 'true_false') {
    return const <String>['True', 'False'];
  }
  if (type == 'multiple_choice' || type == 'checkbox') {
    if (currentOptions.length >= 2) {
      return currentOptions;
    }
    return const <String>['Option 1', 'Option 2', 'Option 3', 'Option 4'];
  }
  return const <String>[];
}

List<String> _normalizeCorrectAnswersForType(
  String type, {
  required List<String> currentAnswers,
}) {
  if (type == 'true_false') {
    return currentAnswers.isEmpty
        ? const <String>['True']
        : <String>[currentAnswers.first];
  }
  if (type == 'multiple_choice') {
    return currentAnswers.isEmpty
        ? const <String>[]
        : <String>[currentAnswers.first];
  }
  return currentAnswers;
}
