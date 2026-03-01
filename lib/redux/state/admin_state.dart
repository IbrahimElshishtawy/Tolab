class AdminState {
  final bool isLoading;
  final String? error;
  final List<dynamic> users;
  final int userPage;
  final bool hasMoreUsers;
  final List<dynamic> subjects;
  final List<dynamic> offerings;
  final List<dynamic> enrollments;
  final List<dynamic> moderationQueue;

  AdminState({
    required this.isLoading,
    this.error,
    required this.users,
    this.userPage = 1,
    this.hasMoreUsers = true,
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
    int? userPage,
    bool? hasMoreUsers,
    List<dynamic>? subjects,
    List<dynamic>? offerings,
    List<dynamic>? enrollments,
    List<dynamic>? moderationQueue,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      users: users ?? this.users,
      userPage: userPage ?? this.userPage,
      hasMoreUsers: hasMoreUsers ?? this.hasMoreUsers,
      subjects: subjects ?? this.subjects,
      offerings: offerings ?? this.offerings,
      enrollments: enrollments ?? this.enrollments,
      moderationQueue: moderationQueue ?? this.moderationQueue,
    );
  }
}
