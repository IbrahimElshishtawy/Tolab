import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/staff_portal_models.dart';

class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onTitleChanged,
    required this.onPointsChanged,
    required this.onRequiredChanged,
    required this.onTypeChanged,
    required this.onSampleAnswerChanged,
    required this.onAddChoice,
    required this.onChoiceChanged,
    required this.onChoiceCorrectToggled,
    required this.onRemoveChoice,
    required this.onDuplicate,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final int index;
  final StaffQuizQuestion question;
  final bool canMoveUp;
  final bool canMoveDown;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<int> onPointsChanged;
  final ValueChanged<bool> onRequiredChanged;
  final ValueChanged<StaffQuestionType> onTypeChanged;
  final ValueChanged<String> onSampleAnswerChanged;
  final VoidCallback onAddChoice;
  final void Function(int choiceIndex, String value) onChoiceChanged;
  final void Function(int choiceIndex, bool selected) onChoiceCorrectToggled;
  final void Function(int choiceIndex) onRemoveChoice;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final isMultiAnswer = question.type == StaffQuestionType.checkbox;
    final usesChoices = _usesChoices(question.type);

    return AppCard(
      backgroundColor: palette.surfaceElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.tr('سؤال ${index + 1}', 'Question ${index + 1}'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: canMoveUp ? onMoveUp : null,
                icon: const Icon(Icons.arrow_upward_rounded),
                tooltip: context.tr('نقل لأعلى', 'Move up'),
              ),
              IconButton(
                onPressed: canMoveDown ? onMoveDown : null,
                icon: const Icon(Icons.arrow_downward_rounded),
                tooltip: context.tr('نقل لأسفل', 'Move down'),
              ),
              IconButton(
                onPressed: onDuplicate,
                icon: const Icon(Icons.copy_all_outlined),
                tooltip: context.tr('نسخ السؤال', 'Duplicate question'),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: context.tr('حذف السؤال', 'Delete question'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: question.title,
            onChanged: onTitleChanged,
            decoration: InputDecoration(
              labelText: context.tr('نص السؤال', 'Question title'),
              hintText: context.tr(
                'اكتب صياغة واضحة ودقيقة',
                'Write a clear and direct prompt',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<StaffQuestionType>(
                  initialValue: question.type,
                  decoration: InputDecoration(
                    labelText: context.tr('نوع السؤال', 'Question type'),
                  ),
                  items: StaffQuestionType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_questionTypeLabel(context, type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onTypeChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 120,
                child: TextFormField(
                  initialValue: '${question.points}',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => onPointsChanged(
                    int.tryParse(value.trim()) ?? question.points,
                  ),
                  decoration: InputDecoration(
                    labelText: context.tr('الدرجة', 'Marks'),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: question.isRequired,
                  title: Text(context.tr('إجباري', 'Required')),
                  onChanged: onRequiredChanged,
                ),
              ),
            ],
          ),
          if (usesChoices) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              context.tr(
                'الخيارات والإجابة الصحيحة',
                'Choices and correct answer',
              ),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...question.choices.asMap().entries.map((entry) {
              final choiceIndex = entry.key;
              final choice = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => onChoiceCorrectToggled(
                        choiceIndex,
                        !choice.isCorrect,
                      ),
                      icon: Icon(
                        isMultiAnswer
                            ? choice.isCorrect
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded
                            : choice.isCorrect
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: choice.isCorrect
                            ? AppColors.primary
                            : palette.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: choice.label,
                        onChanged: (value) =>
                            onChoiceChanged(choiceIndex, value),
                        decoration: InputDecoration(
                          labelText: context.tr(
                            'خيار ${choiceIndex + 1}',
                            'Choice ${choiceIndex + 1}',
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: question.choices.length > 2
                          ? () => onRemoveChoice(choiceIndex)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: onAddChoice,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.tr('إضافة خيار', 'Add choice')),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              initialValue: question.sampleAnswer,
              onChanged: onSampleAnswerChanged,
              minLines: question.type == StaffQuestionType.paragraph ? 3 : 1,
              maxLines: question.type == StaffQuestionType.paragraph ? 5 : 2,
              decoration: InputDecoration(
                labelText: context.tr('إجابة نموذجية', 'Sample answer'),
                hintText: context.tr(
                  'للمعاينة فقط أو لتوضيح المطلوب',
                  'Used for preview or to clarify expectations',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _usesChoices(StaffQuestionType type) {
    return switch (type) {
      StaffQuestionType.multipleChoice ||
      StaffQuestionType.checkbox ||
      StaffQuestionType.trueFalse ||
      StaffQuestionType.dropdown => true,
      StaffQuestionType.shortAnswer || StaffQuestionType.paragraph => false,
    };
  }

  String _questionTypeLabel(BuildContext context, StaffQuestionType type) {
    return switch (type) {
      StaffQuestionType.multipleChoice => context.tr(
        'اختيار من متعدد',
        'Multiple choice',
      ),
      StaffQuestionType.checkbox => context.tr('اختيارات متعددة', 'Checkbox'),
      StaffQuestionType.trueFalse => context.tr('صح / خطأ', 'True / False'),
      StaffQuestionType.shortAnswer => context.tr(
        'إجابة قصيرة',
        'Short answer',
      ),
      StaffQuestionType.paragraph => context.tr('إجابة مطولة', 'Paragraph'),
      StaffQuestionType.dropdown => context.tr('قائمة منسدلة', 'Dropdown'),
    };
  }
}
