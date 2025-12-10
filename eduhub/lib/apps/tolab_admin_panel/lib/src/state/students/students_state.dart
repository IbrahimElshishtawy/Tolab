class StudentsState {
  final bool isLoading;
  final List<Map<String, dynamic>> students;
  final String? error;

  const StudentsState({
    required this.isLoading,
    required this.students,
    this.error,
  });

  factory StudentsState.initial() {
    return const StudentsState(isLoading: false, students: [], error: null);
  }

  StudentsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? students,
    String? error,
  }) {
    return StudentsState(
      isLoading: isLoading ?? this.isLoading,
      students: students ?? this.students,
      error: error,
    );
  }
}
