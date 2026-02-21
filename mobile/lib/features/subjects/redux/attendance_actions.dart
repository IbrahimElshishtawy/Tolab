import '../data/attendance_model.dart';

class FetchAttendanceAction {
  final int subjectId;
  FetchAttendanceAction(this.subjectId);
}

class FetchAttendanceSuccessAction {
  final int subjectId;
  final List<dynamic> data; // Can be List<AttendanceSession> or List<AttendanceRecord>
  FetchAttendanceSuccessAction(this.subjectId, this.data);
}

class StartAttendanceSessionAction {
  final int subjectId;
  final String type;
  final int duration;
  StartAttendanceSessionAction(this.subjectId, this.type, this.duration);
}

class CheckInAction {
  final int sessionId;
  final String code;
  CheckInAction(this.sessionId, this.code);
}
