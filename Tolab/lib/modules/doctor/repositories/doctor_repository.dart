import '../../../academy_panel/models/academy_models.dart';
import '../models/doctor_models.dart';
import '../services/doctor_api_service.dart';

class DoctorRepository {
  DoctorRepository(this._service);

  final DoctorApiService _service;

  Future<RolePageData> fetchPage(
    String pageKey, {
    List<AcademyNotificationItem> notifications = const [],
  }) async {
    try {
      final records = await switch (pageKey) {
        'assigned-courses' => _service.fetchCollection(
          '/admin/course-offerings',
        ),
        'student-performance' => _service.fetchCollection(
          '/admin/course-offerings',
        ),
        _ => Future.value(const <JsonMap>[]),
      };
      return buildDoctorPageData(
        pageKey,
        payload: {'records': records},
        notifications: notifications,
      );
    } catch (_) {
      return buildDoctorPageData(pageKey, notifications: notifications);
    }
  }

  Future<String> saveRecord(
    String pageKey,
    JsonMap payload, {
    String? entityId,
  }) async {
    switch (pageKey) {
      case 'tasks':
        await _service.createRecord('/admin/courses/1/assessments', payload);
        return 'Task published successfully.';
      case 'exams':
        await _service.createRecord('/admin/courses/1/exams', payload);
        return 'Exam saved successfully.';
      case 'profile':
        await _service.updateProfile(payload);
        return 'Profile updated successfully.';
      default:
        return 'This teaching page is currently operating in read-first mode.';
    }
  }

  Future<String> uploadFiles(List<UploadDraft> files) async {
    await _service.uploadFiles(files);
    return '${files.length} file(s) uploaded successfully.';
  }
}
