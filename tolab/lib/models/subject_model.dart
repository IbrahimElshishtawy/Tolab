class SubjectModel {
  final String id;
  final String name;
  final String description;
  final double progress;

  SubjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.progress,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    progress: (json['progress'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'progress': progress,
  };
}
