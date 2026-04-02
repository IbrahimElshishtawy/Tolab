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
  });

  final int id;
  final String name;
  final String code;
  final bool isActive;
  final String departmentName;
  final String academicYearName;
  final String? description;
  final List<SectionModel> sections;

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isActive: json['is_active'] != false,
      departmentName: json['department_name']?.toString() ?? '',
      academicYearName: json['academic_year_name']?.toString() ?? '',
      description: json['description']?.toString(),
      sections: (json['sections'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SectionModel.fromJson)
          .toList(),
    );
  }
}
