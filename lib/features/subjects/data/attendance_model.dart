class AttendanceSession {
  final int id;
  final int subjectId;
  final String type;
  final DateTime startsAt;
  final DateTime endsAt;
  final String code;

  AttendanceSession({
    required this.id,
    required this.subjectId,
    required this.type,
    required this.startsAt,
    required this.endsAt,
    required this.code,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'],
      subjectId: json['subject_id'],
      type: json['type'],
      startsAt: DateTime.parse(json['starts_at']),
      endsAt: DateTime.parse(json['ends_at']),
      code: json['code'],
    );
  }
}

class AttendanceRecord {
  final int id;
  final int sessionId;
  final int studentId;
  final DateTime checkedInAt;

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.checkedInAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      sessionId: json['session_id'],
      studentId: json['student_id'],
      checkedInAt: DateTime.parse(json['checked_in_at']),
    );
  }
}
