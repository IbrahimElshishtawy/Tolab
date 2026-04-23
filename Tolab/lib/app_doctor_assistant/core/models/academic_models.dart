class DepartmentModel {
  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.description,
  });

  final int id;
  final String name;
  final String code;
  final bool isActive;
  final String? description;

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isActive: json['is_active'] != false,
      description: json['description']?.toString(),
    );
  }
}

class AcademicYearModel {
  const AcademicYearModel({
    required this.id,
    required this.name,
    required this.level,
    required this.isActive,
  });

  final int id;
  final String name;
  final int level;
  final bool isActive;

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      isActive: json['is_active'] != false,
    );
  }
}

class SectionModel {
  const SectionModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.assistantName,
  });

  final int id;
  final String name;
  final String code;
  final bool isActive;
  final String? assistantName;

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isActive: json['is_active'] != false,
      assistantName: json['assistant_name']?.toString(),
    );
  }
}

class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.departmentName,
    required this.academicYearName,
    this.description,
    this.sections = const <SectionModel>[],
    this.doctorName,
    this.assistantName,
    this.studentCount = 0,
    this.lecturesCount = 0,
    this.sectionsCount = 0,
    this.quizzesCount = 0,
    this.tasksCount = 0,
    this.progress = 0,
    this.lastActivityLabel = '',
    this.statusLabel = 'Active',
    this.levelLabel = '',
    this.averageScore = 0,
    this.pendingGradesCount = 0,
    this.publishedResultsCount = 0,
    this.groupPostsCount = 0,
  });

  final int id;
  final String name;
  final String code;
  final bool isActive;
  final String departmentName;
  final String academicYearName;
  final String? description;
  final List<SectionModel> sections;
  final String? doctorName;
  final String? assistantName;
  final int studentCount;
  final int lecturesCount;
  final int sectionsCount;
  final int quizzesCount;
  final int tasksCount;
  final double progress;
  final String lastActivityLabel;
  final String statusLabel;
  final String levelLabel;
  final double averageScore;
  final int pendingGradesCount;
  final int publishedResultsCount;
  final int groupPostsCount;

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isActive: json['is_active'] != false,
      departmentName: json['department_name']?.toString() ?? '',
      academicYearName: json['academic_year_name']?.toString() ?? '',
      description: json['description']?.toString(),
      doctorName: json['doctor_name']?.toString(),
      assistantName: json['assistant_name']?.toString(),
      studentCount: (json['student_count'] as num?)?.toInt() ?? 0,
      lecturesCount: (json['lectures_count'] as num?)?.toInt() ?? 0,
      sectionsCount:
          (json['sections_count'] as num?)?.toInt() ??
          (json['section_count'] as num?)?.toInt() ??
          0,
      quizzesCount: (json['quizzes_count'] as num?)?.toInt() ?? 0,
      tasksCount: (json['tasks_count'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      lastActivityLabel: json['last_activity_label']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? 'Active',
      levelLabel: json['level_label']?.toString() ?? '',
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
      pendingGradesCount:
          (json['pending_grades_count'] as num?)?.toInt() ?? 0,
      publishedResultsCount:
          (json['published_results_count'] as num?)?.toInt() ?? 0,
      groupPostsCount: (json['group_posts_count'] as num?)?.toInt() ?? 0,
      sections: (json['sections'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SectionModel.fromJson)
          .toList(),
    );
  }
}
