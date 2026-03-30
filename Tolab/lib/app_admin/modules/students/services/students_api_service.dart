import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/student_management_models.dart';

class StudentsApiService {
  StudentsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<StudentModuleSnapshot> fetchModuleSnapshot() {
    return _apiClient.get<StudentModuleSnapshot>(
      '/admin/students/module',
      decoder: (json) => StudentModuleSnapshot.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  Future<void> saveStudent(StudentProfile student, {String? verificationCode}) {
    final payload = {
      ...student.toJson(),
      if (verificationCode != null && verificationCode.isNotEmpty)
        'two_factor_code': verificationCode,
    };
    final path = student.id.isEmpty
        ? '/admin/students'
        : '/admin/students/${student.id}';
    final request = student.id.isEmpty
        ? _apiClient.post<void>(path, data: payload, decoder: (_) => null)
        : _apiClient.put<void>(path, data: payload, decoder: (_) => null);
    return request;
  }

  Future<void> performBulkAction({
    required StudentBulkActionType actionType,
    required List<String> studentIds,
    String? courseTitle,
    StudentEnrollmentStatus? status,
    String? verificationCode,
  }) {
    return _apiClient.post<void>(
      '/admin/students/bulk-actions',
      data: {
        'action': actionType.backendValue,
        'student_ids': studentIds,
        if (courseTitle != null && courseTitle.isNotEmpty)
          'course_title': courseTitle,
        if (status != null) 'status': status.backendValue,
        if (verificationCode != null && verificationCode.isNotEmpty)
          'two_factor_code': verificationCode,
      },
      decoder: (_) => null,
    );
  }

  Future<void> uploadDocuments(
    String studentId,
    List<StudentUploadedFile> files,
  ) {
    final formData = FormData.fromMap({
      'documents': [
        for (final file in files)
          MultipartFile.fromBytes(file.bytes, filename: file.name),
      ],
    });
    return _apiClient.multipart<void>(
      '/admin/students/$studentId/documents',
      data: formData,
      decoder: (_) => null,
    );
  }

  Future<void> updateDocumentStatus({
    required String studentId,
    required String documentId,
    required StudentDocumentStatus status,
    String? verificationCode,
  }) {
    return _apiClient.patch<void>(
      '/admin/students/$studentId/documents/$documentId',
      data: {
        'status': status.backendValue,
        if (verificationCode != null && verificationCode.isNotEmpty)
          'two_factor_code': verificationCode,
      },
      decoder: (_) => null,
    );
  }

  Future<void> sendCampaign({
    required String title,
    required String body,
    required StudentCommunicationChannel channel,
    required List<String> recipientStudentIds,
    String? audienceLabel,
    String? groupId,
  }) {
    return _apiClient.post<void>(
      '/admin/students/communications',
      data: {
        'title': title,
        'body': body,
        'channel': channel.backendValue,
        'recipient_student_ids': recipientStudentIds,
        if (audienceLabel != null && audienceLabel.isNotEmpty)
          'audience_label': audienceLabel,
        if (groupId != null && groupId.isNotEmpty) 'group_id': groupId,
      },
      decoder: (_) => null,
    );
  }

  Future<void> requestDocumentBundle({
    required String studentId,
    required List<String> documentIds,
  }) {
    return _apiClient.post<void>(
      '/admin/students/$studentId/documents/bundle',
      data: {'document_ids': documentIds},
      decoder: (_) => null,
    );
  }
}
