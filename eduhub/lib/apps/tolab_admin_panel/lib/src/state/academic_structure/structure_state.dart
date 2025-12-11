class AcademicStructureState {
  final bool isLoading;
  final List<dynamic> departments;
  final List<dynamic> programs;
  final List<dynamic> years;
  final String? error;

  AcademicStructureState({
    required this.isLoading,
    required this.departments,
    required this.programs,
    required this.years,
    this.error,
  });

  factory AcademicStructureState.initial() {
    return AcademicStructureState(
      isLoading: false,
      departments: [],
      programs: [],
      years: [1, 2, 3, 4],
      error: null,
    );
  }

  AcademicStructureState copyWith({
    bool? isLoading,
    List<dynamic>? departments,
    List<dynamic>? programs,
    List<dynamic>? years,
    String? error,
  }) {
    return AcademicStructureState(
      isLoading: isLoading ?? this.isLoading,
      departments: departments ?? this.departments,
      programs: programs ?? this.programs,
      years: years ?? this.years,
      error: error,
    );
  }
}
