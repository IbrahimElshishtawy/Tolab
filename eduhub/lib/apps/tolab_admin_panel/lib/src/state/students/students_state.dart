class StudentsState {
  final List<Map<String, dynamic>> students;
  final String selectedDepartment;
  final int selectedYear;

  StudentsState({
    required this.students,
    required this.selectedDepartment,
    required this.selectedYear,
  });

  factory StudentsState.initial() {
    return StudentsState(
      students: [], // يمكن تعبئة هذه البيانات عند الحاجة
      selectedDepartment: "Computer Science",
      selectedYear: 1,
    );
  }

  StudentsState copyWith({
    List<Map<String, dynamic>>? students,
    String? selectedDepartment,
    int? selectedYear,
  }) {
    return StudentsState(
      students: students ?? this.students,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}
