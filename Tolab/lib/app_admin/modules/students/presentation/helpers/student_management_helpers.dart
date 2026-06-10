import '../../models/student_management_models.dart';

List<StudentProfile> filterStudents(
  List<StudentProfile> students,
  StudentFilters filters,
) {
  return students
      .where((student) {
        final query = filters.query.trim().toLowerCase();
        final matchesQuery =
            query.isEmpty ||
            student.fullName.toLowerCase().contains(query) ||
            student.studentNumber.toLowerCase().contains(query) ||
            student.contact.email.toLowerCase().contains(query) ||
            student.department.toLowerCase().contains(query) ||
            student.courses.any(
              (course) => course.title.toLowerCase().contains(query),
            );

        final matchesDepartment =
            filters.department == 'All departments' ||
            student.department == filters.department;
        final matchesYear =
            filters.year == 'All years' ||
            student.year.toString() == filters.year;
        final matchesStatus =
            filters.enrollmentStatus == 'All statuses' ||
            student.enrollmentStatus.label == filters.enrollmentStatus;
        final matchesGpa = switch (filters.gpaBand) {
          'High (3.5+)' => student.gpa >= 3.5,
          'Stable (2.5-3.49)' => student.gpa >= 2.5 && student.gpa < 3.5,
          'Low (<2.5)' => student.gpa < 2.5,
          _ => true,
        };
        final matchesAttendance = switch (filters.attendanceBand) {
          'Excellent (90%+)' => student.attendanceRate >= 90,
          'Stable (80-89%)' =>
            student.attendanceRate >= 80 && student.attendanceRate < 90,
          'At risk (<80%)' => student.attendanceRate < 80,
          _ => true,
        };
        final matchesCourse =
            filters.course == 'All courses' ||
            student.courses.any((course) => course.title == filters.course);
        return matchesQuery &&
            matchesDepartment &&
            matchesYear &&
            matchesStatus &&
            matchesGpa &&
            matchesAttendance &&
            matchesCourse;
      })
      .toList(growable: false);
}

List<StudentActivityRecord> filterActivities(
  StudentModuleSnapshot? snapshot,
  StudentFilters filters,
  List<StudentProfile> visibleStudents,
) {
  final visibleIds = visibleStudents.map((item) => item.id).toSet();
  return (snapshot?.allActivities ?? const [])
      .where((activity) {
        final matchesVisibleStudent = visibleIds.contains(activity.studentId);
        final matchesType =
            filters.activityType == 'All activity' ||
            activity.type.label == filters.activityType;
        final matchesCourse =
            filters.course == 'All courses' ||
            activity.courseTitle == null ||
            activity.courseTitle == filters.course;
        return matchesVisibleStudent && matchesType && matchesCourse;
      })
      .toList(growable: false);
}

List<StudentProfile> sortStudents(
  List<StudentProfile> students,
  String sortColumn,
  bool ascending,
) {
  final items = [...students];
  items.sort((left, right) {
    final factor = ascending ? 1 : -1;
    final result = switch (sortColumn) {
      'department' => left.department.compareTo(right.department),
      'attendance' => left.attendanceRate.compareTo(right.attendanceRate),
      'gpa' => left.gpa.compareTo(right.gpa),
      'status' => left.enrollmentStatus.label.compareTo(
          right.enrollmentStatus.label,
        ),
      _ => left.fullName.compareTo(right.fullName),
    };
    return result * factor;
  });
  return items;
}

StudentProfile? resolveSelectedStudent(
  StudentModuleSnapshot? snapshot,
  List<StudentProfile> visibleStudents,
  String? selectedStudentId,
) {
  if (visibleStudents.isEmpty) return null;
  final selected = visibleStudents.where(
    (item) => item.id == selectedStudentId,
  );
  if (selected.isNotEmpty) return selected.first;
  return snapshot?.findStudent(selectedStudentId) ?? visibleStudents.first;
}

String csvCell(String value) => '"${value.replaceAll('"', '""')}"';

extension ListHelpers<T> on List<T> {
  T? get singleOrNull => length == 1 ? this[0] : null;

  T? get firstOrNull => isEmpty ? null : first;
}
