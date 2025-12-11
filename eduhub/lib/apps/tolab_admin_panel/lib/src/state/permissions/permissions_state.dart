class PermissionsState {
  final bool canViewStudents;
  final bool canEditStudents;
  final bool canDeleteStudents;

  final bool canViewDoctors;
  final bool canEditDoctors;

  PermissionsState({
    required this.canViewStudents,
    required this.canEditStudents,
    required this.canDeleteStudents,
    required this.canViewDoctors,
    required this.canEditDoctors,
  });

  factory PermissionsState.initial() {
    return PermissionsState(
      canViewStudents: true,
      canEditStudents: false,
      canDeleteStudents: false,
      canViewDoctors: true,
      canEditDoctors: false,
    );
  }

  PermissionsState copyWith({
    bool? canViewStudents,
    bool? canEditStudents,
    bool? canDeleteStudents,
    bool? canViewDoctors,
    bool? canEditDoctors,
  }) {
    return PermissionsState(
      canViewStudents: canViewStudents ?? this.canViewStudents,
      canEditStudents: canEditStudents ?? this.canEditStudents,
      canDeleteStudents: canDeleteStudents ?? this.canDeleteStudents,
      canViewDoctors: canViewDoctors ?? this.canViewDoctors,
      canEditDoctors: canEditDoctors ?? this.canEditDoctors,
    );
  }
}
