class GradeItemModel {
  const GradeItemModel({
    required this.id,
    required this.title,
    required this.score,
    required this.total,
    this.type,
  });

  final String id;
  final String title;
  final double score;
  final double total;
  final String? type;

  factory GradeItemModel.fromJson(Map<String, dynamic> json) {
    return GradeItemModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Assessment') as String,
      score: (json['score'] as num?)?.toDouble() ?? 0,
      total:
          (json['max_score'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          100,
      type: json['type'] as String?,
    );
  }
}
