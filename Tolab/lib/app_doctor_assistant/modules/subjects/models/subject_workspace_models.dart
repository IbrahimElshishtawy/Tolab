import '../../../core/models/academic_models.dart';
import '../../../core/models/content_models.dart';
import '../../groups/models/group_models.dart';
import '../../results/models/results_models.dart';

class SubjectWorkspaceModel {
  const SubjectWorkspaceModel({
    required this.subject,
    required this.lectures,
    required this.sections,
    required this.quizzes,
    required this.tasks,
    required this.group,
    required this.results,
    required this.students,
  });

  final SubjectModel subject;
  final List<LectureModel> lectures;
  final List<SectionContentModel> sections;
  final List<QuizModel> quizzes;
  final List<TaskModel> tasks;
  final SubjectGroupModel group;
  final SubjectResultsModel results;
  final List<SubjectStudentPreviewModel> students;

  factory SubjectWorkspaceModel.fromJson(Map<String, dynamic> json) {
    return SubjectWorkspaceModel(
      subject: SubjectModel.fromJson(
        json['subject'] as Map<String, dynamic>? ?? const {},
      ),
      lectures: (json['lectures'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(LectureModel.fromJson)
          .toList(growable: false),
      sections: (json['sections'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SectionContentModel.fromJson)
          .toList(growable: false),
      quizzes: (json['quizzes'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuizModel.fromJson)
          .toList(growable: false),
      tasks: (json['tasks'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .toList(growable: false),
      group: SubjectGroupModel.fromJson(
        json['group'] as Map<String, dynamic>? ?? const {},
      ),
      results: SubjectResultsModel.fromJson(
        json['results'] as Map<String, dynamic>? ?? const {},
      ),
      students: (json['students'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SubjectStudentPreviewModel.fromJson)
          .toList(growable: false),
    );
  }
}

class SubjectStudentPreviewModel {
  const SubjectStudentPreviewModel({
    required this.id,
    required this.name,
    required this.code,
    required this.sectionLabel,
    required this.statusLabel,
    this.averageScore = 0,
    this.attendanceRate = 0,
  });

  final int id;
  final String name;
  final String code;
  final String sectionLabel;
  final String statusLabel;
  final double averageScore;
  final int attendanceRate;

  factory SubjectStudentPreviewModel.fromJson(Map<String, dynamic> json) {
    return SubjectStudentPreviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      sectionLabel: json['section_label']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? 'Active',
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
      attendanceRate: (json['attendance_rate'] as num?)?.toInt() ?? 0,
    );
  }
}
