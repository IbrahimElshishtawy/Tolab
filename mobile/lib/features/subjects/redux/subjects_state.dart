import '../data/models.dart';
import '../data/announcement_model.dart';

class SubjectsState {
  final List<Subject> subjects;
  final Map<int, List<Announcement>> announcements;
  final Map<int, List<dynamic>> attendance;
  final Map<int, List<dynamic>> gradebooks;
  final Map<int, dynamic> studentProgress;
  final Map<int, List<Lecture>> lectures;
  final Map<int, List<Section>> sections;
  final Map<int, List<Quiz>> quizzes;
  final Map<int, List<Summary>> summaries;
  final bool isLoading;
  final String? error;

  SubjectsState({
    required this.subjects,
    required this.announcements,
    required this.attendance,
    required this.gradebooks,
    required this.studentProgress,
    required this.lectures,
    required this.sections,
    required this.quizzes,
    required this.summaries,
    required this.isLoading,
    this.error,
  });

  factory SubjectsState.initial() => SubjectsState(
    subjects: [],
    announcements: {},
    attendance: {},
    gradebooks: {},
    studentProgress: {},
    lectures: {},
    sections: {},
    quizzes: {},
    summaries: {},
    isLoading: false,
  );

  SubjectsState copyWith({
    List<Subject>? subjects,
    Map<int, List<Announcement>>? announcements,
    Map<int, List<dynamic>>? attendance,
    Map<int, List<dynamic>>? gradebooks,
    Map<int, dynamic>? studentProgress,
    Map<int, List<Lecture>>? lectures,
    Map<int, List<Section>>? sections,
    Map<int, List<Quiz>>? quizzes,
    Map<int, List<Summary>>? summaries,
    bool? isLoading,
    String? error,
  }) {
    return SubjectsState(
      subjects: subjects ?? this.subjects,
      announcements: announcements ?? this.announcements,
      attendance: attendance ?? this.attendance,
      gradebooks: gradebooks ?? this.gradebooks,
      studentProgress: studentProgress ?? this.studentProgress,
      lectures: lectures ?? this.lectures,
      sections: sections ?? this.sections,
      quizzes: quizzes ?? this.quizzes,
      summaries: summaries ?? this.summaries,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
