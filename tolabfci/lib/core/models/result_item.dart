class SubjectResult {
  const SubjectResult({
    required this.subjectId,
    required this.subjectName,
    required this.totalGrade,
    required this.letterGrade,
    required this.status,
  });

  final String subjectId;
  final String subjectName;
  final int totalGrade;
  final String letterGrade;
  final String status;
}
