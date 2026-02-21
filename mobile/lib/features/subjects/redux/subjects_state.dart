import '../data/models.dart';
import '../data/announcement_model.dart';

class SubjectsState {
  final List<Subject> subjects;
  final Map<int, List<Announcement>> announcements; // subjectId -> list
  final Map<int, List<dynamic>> attendance; // subjectId -> list (sessions or records)
  final Map<int, List<dynamic>> gradebooks; // subjectId -> list
  final Map<int, dynamic> studentProgress; // subjectId -> object
  final bool isLoading;
  final String? error;

  SubjectsState({
    required this.subjects,
    required this.announcements,
    required this.attendance,
    required this.gradebooks,
    required this.studentProgress,
    required this.isLoading,
    this.error,
  });

  factory SubjectsState.initial() => SubjectsState(
    subjects: [],
    announcements: {},
    attendance: {},
    gradebooks: {},
    studentProgress: {},
    isLoading: false,
  );

  SubjectsState copyWith({
    List<Subject>? subjects,
    Map<int, List<Announcement>>? announcements,
    Map<int, List<dynamic>>? attendance,
    Map<int, List<dynamic>>? gradebooks,
    Map<int, dynamic>? studentProgress,
    bool? isLoading,
    String? error,
  }) {
    return SubjectsState(
      subjects: subjects ?? this.subjects,
      announcements: announcements ?? this.announcements,
      attendance: attendance ?? this.attendance,
      gradebooks: gradebooks ?? this.gradebooks,
      studentProgress: studentProgress ?? this.studentProgress,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
