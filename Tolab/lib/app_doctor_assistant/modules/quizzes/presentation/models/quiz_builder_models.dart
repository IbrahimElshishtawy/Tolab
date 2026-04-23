import 'package:flutter/material.dart';

class QuizBuilderQuestionDraft {
  const QuizBuilderQuestionDraft({
    required this.id,
    required this.prompt,
    required this.type,
    required this.options,
    required this.correctAnswers,
    required this.marks,
    required this.isRequired,
  });

  final String id;
  final String prompt;
  final String type;
  final List<String> options;
  final List<String> correctAnswers;
  final int marks;
  final bool isRequired;

  QuizBuilderQuestionDraft copyWith({
    String? id,
    String? prompt,
    String? type,
    List<String>? options,
    List<String>? correctAnswers,
    int? marks,
    bool? isRequired,
  }) {
    return QuizBuilderQuestionDraft(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      marks: marks ?? this.marks,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  QuizBuilderQuestionDraft duplicate() {
    return QuizBuilderQuestionDraft(
      id: '${id}_copy_${DateTime.now().microsecondsSinceEpoch}',
      prompt: '$prompt Copy',
      type: type,
      options: List<String>.from(options),
      correctAnswers: List<String>.from(correctAnswers),
      marks: marks,
      isRequired: isRequired,
    );
  }

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'id': id,
      'prompt': prompt,
      'type': type,
      'options': options,
      'correct_answers': correctAnswers,
      'marks': marks,
      'is_required': isRequired,
    };
  }
}

const List<String> quizQuestionTypes = <String>[
  'multiple_choice',
  'true_false',
  'short_answer',
  'checkbox',
  'paragraph',
];

String quizQuestionTypeLabel(String type) {
  return switch (type) {
    'multiple_choice' => 'Multiple choice',
    'true_false' => 'True / False',
    'short_answer' => 'Short answer',
    'checkbox' => 'Checkbox',
    'paragraph' => 'Paragraph',
    _ => type,
  };
}

IconData quizQuestionTypeIcon(String type) {
  return switch (type) {
    'multiple_choice' => Icons.radio_button_checked_rounded,
    'true_false' => Icons.toggle_on_rounded,
    'short_answer' => Icons.short_text_rounded,
    'checkbox' => Icons.check_box_rounded,
    'paragraph' => Icons.notes_rounded,
    _ => Icons.help_outline_rounded,
  };
}
