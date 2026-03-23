class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.code,
    required this.instructor,
    this.section,
    this.heroImage,
    this.progress = 0,
    this.nextClass,
    this.creditHours,
  });

  final String id;
  final String title;
  final String code;
  final String instructor;
  final String? section;
  final String? heroImage;
  final double progress;
  final String? nextClass;
  final int? creditHours;

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>?;
    final doctor = json['doctor'] as Map<String, dynamic>?;
    final section = json['section'] as Map<String, dynamic>?;
    return CourseModel(
      id: (json['id'] ?? '').toString(),
      title:
          (subject?['name'] ?? json['title'] ?? json['name'] ?? 'Course')
              as String,
      code: (subject?['code'] ?? json['code'] ?? 'CRS') as String,
      instructor:
          (doctor?['name'] ?? json['instructor_name'] ?? 'Staff') as String,
      section: section?['name'] as String? ?? json['section_name'] as String?,
      heroImage: json['hero_image'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      nextClass: json['next_class'] as String?,
      creditHours: (json['credit_hours'] as num?)?.toInt(),
    );
  }
}
