import 'package:meta/meta.dart';

@immutable
class StudentsState {
  final bool isLoading;
  final List<Map<String, dynamic>> students;
  final String? error;
  final String? department;
  final int? year;
  final String? programType;

  const StudentsState({
    required this.isLoading,
    required this.students,
    this.error,
    this.department,
    this.year,
    this.programType,
  });

  factory StudentsState.initial() {
    return const StudentsState(
      isLoading: false,
      students: [],
      error: null,
      programType: null,
      department: null,
      year: null,
    );
  }

  StudentsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? students,
    String? error,
    String? programType,
    String? department,
    int? year,
  }) {
    return StudentsState(
      isLoading: isLoading ?? this.isLoading,
      students: students ?? this.students,
      error: error,
      programType: programType ?? this.programType,
      department: department ?? this.department,
      year: year ?? this.year,
    );
  }
}
