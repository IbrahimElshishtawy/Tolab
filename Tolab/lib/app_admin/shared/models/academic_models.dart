class DepartmentModel {
  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.head,
    required this.status,
    required this.studentsCount,
  });

  final String id;
  final String name;
  final String code;
  final String head;
  final String status;
  final int studentsCount;
}

class SectionModel {
  const SectionModel({
    required this.id,
    required this.name,
    required this.department,
    required this.year,
    required this.semester,
    required this.status,
  });

  final String id;
  final String name;
  final String department;
  final String year;
  final String semester;
  final String status;
}

class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.code,
    required this.name,
    required this.department,
    required this.credits,
    required this.status,
  });

  final String id;
  final String code;
  final String name;
  final String department;
  final int credits;
  final String status;
}

class CourseOfferingModel {
  const CourseOfferingModel({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.sectionName,
    required this.doctorName,
    required this.assistantName,
    required this.semester,
    required this.enrolled,
    required this.capacity,
    required this.status,
  });

  final String id;
  final String subjectCode;
  final String subjectName;
  final String sectionName;
  final String doctorName;
  final String assistantName;
  final String semester;
  final int enrolled;
  final int capacity;
  final String status;
}

class EnrollmentRecord {
  const EnrollmentRecord({
    required this.id,
    required this.studentName,
    required this.subjectName,
    required this.department,
    required this.level,
    required this.status,
  });

  final String id;
  final String studentName;
  final String subjectName;
  final String department;
  final String level;
  final String status;
}
