import '../../../../core/models/timetable_item.dart';

abstract class TimetableRepository {
  Future<List<TimetableItem>> getStudentTimetable({
    String weekPattern = 'all',
    DateTime? date,
  });

  Future<List<TimetableItem>> getDoctorTimetable({
    String weekPattern = 'all',
    DateTime? date,
  });

  Future<List<TimetableItem>> getAdminSchedule({
    Map<String, Object?> filters = const {},
  });
}
