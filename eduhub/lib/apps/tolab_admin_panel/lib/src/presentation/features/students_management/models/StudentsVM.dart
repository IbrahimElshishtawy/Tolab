// ignore_for_file: file_names

import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/app_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/students/students_actions.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class StudentsVM {
  final List<Map<String, dynamic>> students;
  final bool canViewStudents;
  final bool canEditStudents;
  final String? department;
  final int? year;
  final ValueChanged<String?> onDepartmentChange;
  final ValueChanged<int?> onYearChange;

  StudentsVM({
    required this.students,
    required this.canViewStudents,
    required this.canEditStudents,
    required this.department,
    required this.year,
    required this.onDepartmentChange,
    required this.onYearChange,
  });

  // هذه الدالة يجب أن تكون بدون static لأنها تعتمد على الكائنات
  StudentsVM.fromStore(Store<AppState> store, dynamic d, this.onYearChange)
    : students =
          store.state.students.students, // استخراج الطلاب من الـ Redux Store
      canViewStudents = store.state.permissions.canViewStudents,
      canEditStudents = store.state.permissions.canEditStudents,
      department = store.state.students.selectedDepartment,
      year = store.state.students.selectedYear,
      onDepartmentChange = (d) {
    store.dispatch(FilterStudentsByDepartmentAction(d)); // فلاتر تغيير القسم
  }

  // دالة لتصفية الطلاب بناءً على القسم والسنة الدراسية
  List<Map<String, dynamic>> selectFilteredStudents(
    String searchQuery,
    String? selectedDepartment,
    int? selectedYear,
  ) {
    return students.where((student) {
      final matchesSearch = student["name"].toString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesDepartment =
          selectedDepartment == null ||
          student["department"] == selectedDepartment;
      final matchesYear =
          selectedYear == null || student["year"] == selectedYear;

      return matchesSearch && matchesDepartment && matchesYear;
    }).toList();
  }
}
