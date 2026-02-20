import '../data/models.dart';

class SubjectsState {
  final List<Subject> subjects;
  final bool isLoading;
  final String? error;

  SubjectsState({
    required this.subjects,
    required this.isLoading,
    this.error,
  });

  factory SubjectsState.initial() => SubjectsState(
    subjects: [],
    isLoading: false,
  );

  SubjectsState copyWith({
    List<Subject>? subjects,
    bool? isLoading,
    String? error,
  }) {
    return SubjectsState(
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
