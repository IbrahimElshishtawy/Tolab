import 'dart:math' as math;

import 'package:collection/collection.dart';

import '../../../state/app_state.dart';
import '../models/department_models.dart';
import 'departments_state.dart';

class DepartmentsSummaryMetrics {
  const DepartmentsSummaryMetrics({
    required this.departmentsCount,
    required this.activeDepartmentsCount,
    required this.studentsCount,
    required this.staffCount,
    required this.activeCoursesCount,
    required this.averageSuccessRate,
  });

  final int departmentsCount;
  final int activeDepartmentsCount;
  final int studentsCount;
  final int staffCount;
  final int activeCoursesCount;
  final double averageSuccessRate;
}

DepartmentsState departmentsStateOf(AppState state) => state.departmentsState;

List<String> selectDepartmentFacultyOptions(DepartmentsState state) {
  final options =
      state.items.map((department) => department.faculty).toSet().toList()
        ..sort();
  return options;
}

List<DepartmentRecord> selectFilteredDepartments(DepartmentsState state) {
  final query = state.filters.searchQuery.trim().toLowerCase();
  return state.items
      .where((department) {
        final matchesQuery =
            query.isEmpty ||
            department.name.toLowerCase().contains(query) ||
            department.code.toLowerCase().contains(query) ||
            department.description.toLowerCase().contains(query) ||
            department.headName.toLowerCase().contains(query);
        final matchesStatus = switch (state.filters.status) {
          DepartmentStatusFilter.active =>
            department.isActive && !department.isArchived,
          DepartmentStatusFilter.inactive =>
            !department.isActive || department.isArchived,
          DepartmentStatusFilter.all => true,
        };
        final matchesFaculty =
            state.filters.faculty == null ||
            state.filters.faculty == department.faculty;
        final matchesDensity = switch (state.filters.density) {
          DepartmentDensityFilter.light => department.studentDensity < 110,
          DepartmentDensityFilter.balanced =>
            department.studentDensity >= 110 && department.studentDensity < 165,
          DepartmentDensityFilter.dense => department.studentDensity >= 165,
          DepartmentDensityFilter.all => true,
        };
        return matchesQuery &&
            matchesStatus &&
            matchesFaculty &&
            matchesDensity;
      })
      .toList(growable: false);
}

List<DepartmentRecord> selectSortedDepartments(DepartmentsState state) {
  final sorted = [...selectFilteredDepartments(state)];
  sorted.sort((left, right) {
    final direction = state.sort.ascending ? 1 : -1;
    final comparison = switch (state.sort.field) {
      DepartmentSortField.name => left.name.compareTo(right.name),
      DepartmentSortField.studentsCount => left.studentsCount.compareTo(
        right.studentsCount,
      ),
      DepartmentSortField.subjectsCount => left.subjectsCount.compareTo(
        right.subjectsCount,
      ),
    };
    return comparison * direction;
  });
  return List<DepartmentRecord>.unmodifiable(sorted);
}

List<DepartmentRecord> selectVisibleDepartments(DepartmentsState state) {
  final sorted = selectSortedDepartments(state);
  final page = math.max(1, state.pagination.page);
  final start = math.min(sorted.length, (page - 1) * state.pagination.perPage);
  final end = math.min(sorted.length, start + state.pagination.perPage);
  return List<DepartmentRecord>.unmodifiable(sorted.sublist(start, end));
}

int selectTotalPages(DepartmentsState state) {
  final total = selectFilteredDepartments(state).length;
  if (total == 0) return 1;
  return (total / state.pagination.perPage).ceil();
}

DepartmentRecord? selectSelectedDepartment(DepartmentsState state) {
  return state.items.firstWhereOrNull(
    (department) => department.id == state.selectedDepartmentId,
  );
}

bool selectAreAllVisibleDepartmentsSelected(DepartmentsState state) {
  final visibleIds = selectVisibleDepartments(
    state,
  ).map((item) => item.id).toSet();
  if (visibleIds.isEmpty) return false;
  return visibleIds.every(state.selectedIds.contains);
}

DepartmentsSummaryMetrics selectDepartmentsSummary(DepartmentsState state) {
  if (state.items.isEmpty) {
    return const DepartmentsSummaryMetrics(
      departmentsCount: 0,
      activeDepartmentsCount: 0,
      studentsCount: 0,
      staffCount: 0,
      activeCoursesCount: 0,
      averageSuccessRate: 0,
    );
  }
  final departmentsCount = state.items.length;
  final activeDepartmentsCount = state.items
      .where((department) => department.isActive && !department.isArchived)
      .length;
  final studentsCount = state.items.fold<int>(
    0,
    (sum, department) => sum + department.studentsCount,
  );
  final staffCount = state.items.fold<int>(
    0,
    (sum, department) => sum + department.staffCount,
  );
  final activeCoursesCount = state.items.fold<int>(
    0,
    (sum, department) => sum + department.activeCoursesCount,
  );
  final averageSuccessRate =
      state.items.fold<double>(
        0,
        (sum, department) => sum + department.successRate,
      ) /
      departmentsCount;
  return DepartmentsSummaryMetrics(
    departmentsCount: departmentsCount,
    activeDepartmentsCount: activeDepartmentsCount,
    studentsCount: studentsCount,
    staffCount: staffCount,
    activeCoursesCount: activeCoursesCount,
    averageSuccessRate: averageSuccessRate,
  );
}

bool selectCanCreateDepartment(DepartmentsState state) {
  if (state.items.isEmpty) return true;
  return state.items.any(
    (department) => department.permissions.allows('create_department'),
  );
}

bool selectDepartmentPermission(
  DepartmentRecord? department,
  String permissionCode,
) {
  return department?.permissions.allows(permissionCode) ?? false;
}
