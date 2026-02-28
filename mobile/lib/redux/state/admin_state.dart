class AdminState {
  final bool isLoading;
  final String? error;
  final List<dynamic> users;
  final List<dynamic> subjects;
  final List<dynamic> offerings;
  final List<dynamic> enrollments;
  final List<dynamic> moderationQueue;

  AdminState({
    required this.isLoading,
    this.error,
    required this.users,
    required this.subjects,
    required this.offerings,
    required this.enrollments,
    required this.moderationQueue,
  });

  factory AdminState.initial() => AdminState(
        isLoading: false,
        users: [],
        subjects: [],
        offerings: [],
        enrollments: [],
        moderationQueue: [],
      );

  AdminState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? users,
    List<dynamic>? subjects,
    List<dynamic>? offerings,
    List<dynamic>? enrollments,
    List<dynamic>? moderationQueue,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      users: users ?? this.users,
      subjects: subjects ?? this.subjects,
      offerings: offerings ?? this.offerings,
      enrollments: enrollments ?? this.enrollments,
      moderationQueue: moderationQueue ?? this.moderationQueue,
    );
  }
}
