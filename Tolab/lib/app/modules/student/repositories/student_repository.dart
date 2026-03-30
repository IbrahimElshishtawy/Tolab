import '../../academy_panel/models/academy_models.dart';
import '../models/student_models.dart';
import '../services/student_api_service.dart';

class StudentRepository {
  StudentRepository(this._service);

  final StudentApiService _service;

  Future<RolePageData> fetchPage(
    String pageKey, {
    List<AcademyNotificationItem> notifications = const [],
  }) async {
    try {
      final records = await switch (pageKey) {
        'enrolled-courses' => _service.fetchCollection('/student/courses'),
        'calendar' => _service.fetchCollection('/student/timetable'),
        _ => Future.value(const <JsonMap>[]),
      };
      return buildStudentPageData(
        pageKey,
        payload: {'records': records},
        notifications: notifications,
      );
    } catch (_) {
      return buildStudentPageData(pageKey, notifications: notifications);
    }
  }

  Future<String> saveRecord(
    String pageKey,
    JsonMap payload, {
    String? entityId,
  }) async {
    if (pageKey == 'profile') {
      await _service.updateProfile(payload);
      return 'Profile updated successfully.';
    }
    return 'This student page is read-focused and does not expose write actions yet.';
  }
}
