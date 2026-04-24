class QuizItem {
  const QuizItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.typeLabel,
    required this.startAtLabel,
    required this.durationLabel,
    required this.isOnline,
    required this.instructions,
    this.description,
    this.subjectName,
    this.startsAt,
    this.closesAt,
    this.locationLabel,
    this.attemptsUsed = 0,
    this.maxAttempts = 1,
    this.isSubmitted = false,
    this.questionCount,
    this.submissionStateLabel,
    this.scoreLabel,
    this.endAtLabel,
    this.reviewAllowed = true,
    this.durationMinutes,
  });

  final String id;
  final String subjectId;
  final String title;
  final String typeLabel;
  final String startAtLabel;
  final String durationLabel;
  final bool isOnline;
  final List<String> instructions;
  final String? description;
  final String? subjectName;
  final DateTime? startsAt;
  final DateTime? closesAt;
  final String? locationLabel;
  final int attemptsUsed;
  final int maxAttempts;
  final bool isSubmitted;
  final int? questionCount;
  final String? submissionStateLabel;
  final String? scoreLabel;
  final String? endAtLabel;
  final bool reviewAllowed;
  final int? durationMinutes;

  QuizItem copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? typeLabel,
    String? startAtLabel,
    String? durationLabel,
    bool? isOnline,
    List<String>? instructions,
    String? description,
    String? subjectName,
    DateTime? startsAt,
    DateTime? closesAt,
    String? locationLabel,
    int? attemptsUsed,
    int? maxAttempts,
    bool? isSubmitted,
    int? questionCount,
    String? submissionStateLabel,
    String? scoreLabel,
    String? endAtLabel,
    bool? reviewAllowed,
    int? durationMinutes,
  }) {
    return QuizItem(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      typeLabel: typeLabel ?? this.typeLabel,
      startAtLabel: startAtLabel ?? this.startAtLabel,
      durationLabel: durationLabel ?? this.durationLabel,
      isOnline: isOnline ?? this.isOnline,
      instructions: instructions ?? this.instructions,
      description: description ?? this.description,
      subjectName: subjectName ?? this.subjectName,
      startsAt: startsAt ?? this.startsAt,
      closesAt: closesAt ?? this.closesAt,
      locationLabel: locationLabel ?? this.locationLabel,
      attemptsUsed: attemptsUsed ?? this.attemptsUsed,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      questionCount: questionCount ?? this.questionCount,
      submissionStateLabel: submissionStateLabel ?? this.submissionStateLabel,
      scoreLabel: scoreLabel ?? this.scoreLabel,
      endAtLabel: endAtLabel ?? this.endAtLabel,
      reviewAllowed: reviewAllowed ?? this.reviewAllowed,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}

enum QuizQuestionType { mcq, trueFalse, checkbox, shortAnswer }

class QuizOption {
  const QuizOption({
    required this.id,
    required this.label,
    this.isCorrect = false,
  });

  final String id;
  final String label;
  final bool isCorrect;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.title,
    required this.type,
    required this.points,
    this.description,
    this.options = const [],
    this.correctShortAnswer,
  });

  final String id;
  final String title;
  final QuizQuestionType type;
  final int points;
  final String? description;
  final List<QuizOption> options;
  final String? correctShortAnswer;
}

class StudentQuizDetails {
  const StudentQuizDetails({
    required this.quiz,
    required this.rules,
    required this.questions,
    required this.availableStatusLabel,
    required this.attemptsLabel,
    this.overview,
  });

  final QuizItem quiz;
  final String? overview;
  final List<String> rules;
  final List<QuizQuestion> questions;
  final String availableStatusLabel;
  final String attemptsLabel;
}
