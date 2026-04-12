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
  });

  final String id;
  final String subjectId;
  final String title;
  final String typeLabel;
  final String startAtLabel;
  final String durationLabel;
  final bool isOnline;
  final List<String> instructions;
}
