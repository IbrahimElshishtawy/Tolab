import '../../../academy_panel/models/academy_models.dart';
import '../models/admin_models.dart';
import '../services/admin_api_service.dart';

class AdminRepository {
  AdminRepository(this._service);

  final AdminApiService _service;

  Future<RolePageData> fetchPage(
    String pageKey, {
    List<AcademyNotificationItem> notifications = const [],
  }) async {
    try {
      final records = await switch (pageKey) {
        'students-management' => _service.fetchCollection(
          '/admin/users',
          query: {'role': 'STUDENT'},
        ),
        'staff-management' => _service.fetchCollection(
          '/admin/users',
          query: {'role': 'DOCTOR'},
        ),
        'departments' => _service.fetchCollection('/departments'),
        'sections' => _service.fetchCollection('/sections'),
        'subjects' => _service.fetchCollection('/subjects'),
        'course-offerings' => _service.fetchCollection(
          '/admin/course-offerings',
        ),
        'enrollments' => _service.fetchCollection('/admin/enrollments'),
        'content-management' => _service.fetchCollection(
          '/admin/course-offerings',
        ),
        _ => Future.value(const <JsonMap>[]),
      };
      return buildAdminPageData(
        pageKey,
        payload: {'records': records},
        notifications: notifications,
      );
    } catch (_) {
      return buildAdminPageData(pageKey, notifications: notifications);
    }
  }

  Future<String> saveRecord(
    String pageKey,
    JsonMap payload, {
    String? entityId,
  }) async {
    final path = _crudPath(pageKey, entityId: entityId);
    if (path == null) return 'No write endpoint configured for this page.';
    if (entityId == null || entityId.isEmpty) {
      await _service.createRecord(path, payload);
      return 'Record created successfully.';
    }
    await _service.updateRecord(path, payload);
    return 'Record updated successfully.';
  }

  Future<String> deleteRecord(String pageKey, String entityId) async {
    final path = _crudPath(pageKey, entityId: entityId);
    if (path == null) return 'No delete endpoint configured for this page.';
    await _service.deleteRecord(path);
    return 'Record deleted successfully.';
  }

  Future<String> uploadFiles(List<UploadDraft> files) async {
    await _service.uploadFiles(files);
    return '${files.length} file(s) uploaded successfully.';
  }

  String? _crudPath(String pageKey, {String? entityId}) {
    return switch (pageKey) {
      'students-management' || 'staff-management' =>
        entityId == null ? '/admin/users' : '/admin/users/$entityId',
      'departments' => '/admin/departments',
      'sections' => '/admin/sections',
      'subjects' =>
        entityId == null ? '/admin/subjects' : '/admin/subjects/$entityId',
      'course-offerings' =>
        entityId == null
            ? '/admin/course-offerings'
            : '/admin/course-offerings/$entityId',
      'enrollments' =>
        entityId == null
            ? '/admin/enrollments'
            : '/admin/enrollments/$entityId',
      'notifications' => '/admin/notifications/broadcast',
      _ => null,
    };
  }
}
