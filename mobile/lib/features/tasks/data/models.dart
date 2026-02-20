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
