import 'package:equatable/equatable.dart';

enum AssignmentStatus { draft, published, closed, graded }

class AssignmentEntity extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final AssignmentStatus status;
  final double maxScore;
  final String? attachmentUrl;
  final int totalSubmissions;
  final int gradedSubmissions;
  final String createdBy;

  const AssignmentEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.status,
    required this.maxScore,
    this.attachmentUrl,
    required this.totalSubmissions,
    required this.gradedSubmissions,
    required this.createdBy,
  });

  bool get isOverdue => DateTime.now().isAfter(dueDate);
  bool get isFullyGraded => totalSubmissions == gradedSubmissions;

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        dueDate,
        createdAt,
        status,
        maxScore,
        attachmentUrl,
        totalSubmissions,
        gradedSubmissions,
        createdBy,
      ];
}
