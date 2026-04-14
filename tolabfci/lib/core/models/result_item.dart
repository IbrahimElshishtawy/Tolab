class SubjectResult {
  const SubjectResult({
    required this.subjectId,
    required this.subjectName,
    required this.totalGrade,
    required this.letterGrade,
    required this.status,
    required this.quizGrade,
    required this.assignmentGrade,
    this.midtermGrade,
    this.finalGrade,
    this.notes,
  });

  final String subjectId;
  final String subjectName;
  final int totalGrade;
  final String letterGrade;
  final String status;
  final int quizGrade;
  final int assignmentGrade;
  final int? midtermGrade;
  final int? finalGrade;
  final String? notes;
}
