class Task {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;

  Task({required this.id, required this.title, required this.description, required this.dueDate});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
    );
  }
}

class Submission {
  final int id;
  final int taskId;
  final String studentName;
  final String? fileUrl;
  final String? grade;
  final DateTime submittedAt;

  Submission({
    required this.id,
    required this.taskId,
    required this.studentName,
    this.fileUrl,
    this.grade,
    required this.submittedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'],
      taskId: json['task_id'],
      studentName: json['student_name'] ?? 'Unknown',
      fileUrl: json['file_url'],
      grade: json['grade']?.toString(),
      submittedAt: DateTime.parse(json['submitted_at']),
    );
  }
}
