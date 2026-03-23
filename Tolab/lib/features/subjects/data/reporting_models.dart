class GradebookEntry {
  final int studentId;
  final String studentName;
  final List<dynamic> tasks;

  GradebookEntry({required this.studentId, required this.studentName, required this.tasks});

  factory GradebookEntry.fromJson(Map<String, dynamic> json) {
    return GradebookEntry(
      studentId: json['student_id'],
      studentName: json['student_name'],
      tasks: json['tasks'],
    );
  }
}

class StudentProgress {
  final int totalTasks;
  final int completedTasks;
  final double averageGrade;
  final List<dynamic> submissions;

  StudentProgress({
    required this.totalTasks,
    required this.completedTasks,
    required this.averageGrade,
    required this.submissions,
  });

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    return StudentProgress(
      totalTasks: json['total_tasks'],
      completedTasks: json['completed_tasks'],
      averageGrade: (json['average_grade'] as num).toDouble(),
      submissions: json['submissions'],
    );
  }
}
