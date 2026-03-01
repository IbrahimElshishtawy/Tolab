class User {
  final int id;
  final String name;
  final String code;
  final String religion;
  final String nationality;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String maritalStatus;
  final String idNumber;
  final String idType;
  final DateTime dateOfIssue;
  final String placeOfIssue;
  final String fatherName;
  final String motherName;
  final String enrollmentStatus;
  final String admissionType;
  final int yearOfAdmission;

  // Qualification
  final String qualification;
  final String school;
  final int yearOfQualification;
  final String grade;
  final double percentage;

  final String departmentName;
  final String academicYear;

  User({
    required this.id,
    required this.name,
    required this.code,
    required this.religion,
    required this.nationality,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.maritalStatus,
    required this.idNumber,
    required this.idType,
    required this.dateOfIssue,
    required this.placeOfIssue,
    required this.fatherName,
    required this.motherName,
    required this.enrollmentStatus,
    required this.admissionType,
    required this.yearOfAdmission,
    required this.qualification,
    required this.school,
    required this.yearOfQualification,
    required this.grade,
    required this.percentage,
    required this.departmentName,
    required this.academicYear,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      religion: json['religion'] ?? '',
      nationality: json['nationality'] ?? '',
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : DateTime.now(),
      placeOfBirth: json['place_of_birth'] ?? '',
      maritalStatus: json['marital_status'] ?? '',
      idNumber: json['id_number'] ?? '',
      idType: json['id_type'] ?? '',
      dateOfIssue: json['date_of_issue'] != null ? DateTime.parse(json['date_of_issue']) : DateTime.now(),
      placeOfIssue: json['place_of_issue'] ?? '',
      fatherName: json['father_name'] ?? '',
      motherName: json['mother_name'] ?? '',
      enrollmentStatus: json['enrollment_status'] ?? '',
      admissionType: json['admission_type'] ?? '',
      yearOfAdmission: json['year_of_admission'] ?? 0,
      qualification: json['qualification'] ?? '',
      school: json['school'] ?? '',
      yearOfQualification: json['year_of_qualification'] ?? 0,
      grade: json['grade'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
      departmentName: json['department_name'] ?? '',
      academicYear: json['academic_year'] ?? '',
    );
  }
}

class AcademicResultRow {
  final String subjectName;
  final String grade;

  AcademicResultRow({required this.subjectName, required this.grade});

  factory AcademicResultRow.fromJson(Map<String, dynamic> json) {
    return AcademicResultRow(
      subjectName: json['subject_name'] ?? '',
      grade: json['grade'] ?? '',
    );
  }
}

class ScheduleGrid {
  final String day;
  final String time;
  final String subjectName;
  final String location;
  final String type; // lecture/section

  ScheduleGrid({
    required this.day,
    required this.time,
    required this.subjectName,
    required this.location,
    required this.type,
  });

  factory ScheduleGrid.fromJson(Map<String, dynamic> json) {
    return ScheduleGrid(
      day: json['day'] ?? '',
      time: json['time'] ?? '',
      subjectName: json['subject_name'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class AppSettings {
  final String language;
  final bool notificationsEnabled;

  AppSettings({required this.language, required this.notificationsEnabled});
}
