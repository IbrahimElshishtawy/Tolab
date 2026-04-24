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
    );
  }
}
