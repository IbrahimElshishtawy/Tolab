import 'package:dio/dio.dart';

import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../models/content_models.dart';

class ContentApiService {
  ContentApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<ContentAttachment> uploadFile(
    ContentUploadSource source, {
    void Function(double progress)? onProgress,
  }) {
    final formData = FormData.fromMap({
      'file': source.bytes != null
          ? MultipartFile.fromBytes(
              source.bytes!,
              filename: source.name,
              contentType: DioMediaType.parse(source.mimeType),
            )
          : MultipartFile.fromFileSync(
              source.path!,
              filename: source.name,
              contentType: DioMediaType.parse(source.mimeType),
            ),
    });

    return _apiClient.multipart<ContentAttachment>(
      '/files/upload',
      data: formData,
      onSendProgress: (sent, total) {
        if (total <= 0) return;
        onProgress?.call(sent / total);
      },
      decoder: (json) => ContentAttachment.fromUploadJson(
        json as JsonMap,
        fallbackName: source.name,
      ),
    );
  }

  Future<void> createContent(
    ContentUpsertPayload payload,
    List<ContentUploadSource> files,
  ) {
    return _requestForType(payload: payload, files: files, updateId: null);
  }

  Future<void> updateContent(
    String contentId,
    ContentUpsertPayload payload,
    List<ContentUploadSource> files,
  ) {
    return _requestForType(payload: payload, files: files, updateId: contentId);
  }

  Future<void> deleteContent(String contentId, ContentType type) {
    final path = switch (type) {
      ContentType.lecture => '/admin/lectures/$contentId',
      ContentType.section => '/admin/sections-sessions/$contentId',
      ContentType.summary => '/admin/summaries/$contentId',
      ContentType.quiz || ContentType.task => '/admin/assessments/$contentId',
      ContentType.exam => '/admin/exams/$contentId',
      ContentType.file => '/admin/course-files/$contentId',
    };

    return _apiClient.delete<void>(path, decoder: (_) {});
  }

  Future<void> _requestForType({
    required ContentUpsertPayload payload,
    required List<ContentUploadSource> files,
    required String? updateId,
  }) async {
    final body = Map<String, dynamic>.from(payload.toApiJson());
    if (files.isNotEmpty) {
      final multipartFiles = await Future.wait(
        files.map((source) async {
          if (source.bytes != null) {
            return MultipartFile.fromBytes(
              source.bytes!,
              filename: source.name,
              contentType: DioMediaType.parse(source.mimeType),
            );
          }
          return MultipartFile.fromFile(
            source.path!,
            filename: source.name,
            contentType: DioMediaType.parse(source.mimeType),
          );
        }),
      );
      body['files'] = multipartFiles;
    }

    if (payload.type == ContentType.summary &&
        body['files'] is List &&
        files.isNotEmpty) {
      body
        ..['file'] = (body['files'] as List<MultipartFile>).first
        ..remove('files');
    }

    if (payload.type == ContentType.file &&
        body['files'] is List &&
        files.isNotEmpty) {
      body
        ..['file'] = (body['files'] as List<MultipartFile>).first
        ..['category'] = payload.type.label
        ..remove('files');
    }

    final formData = FormData.fromMap(body);
    final createPath = switch (payload.type) {
      ContentType.lecture =>
        '/admin/courses/${payload.courseOfferingId}/lectures',
      ContentType.section =>
        '/admin/courses/${payload.courseOfferingId}/sections',
      ContentType.summary =>
        '/admin/courses/${payload.courseOfferingId}/summaries',
      ContentType.quiz || ContentType.task =>
        '/admin/courses/${payload.courseOfferingId}/assessments',
      ContentType.exam => '/admin/courses/${payload.courseOfferingId}/exams',
      ContentType.file => '/admin/courses/${payload.courseOfferingId}/files',
    };
    final updatePath = switch (payload.type) {
      ContentType.lecture => '/admin/lectures/$updateId',
      ContentType.section => '/admin/sections-sessions/$updateId',
      ContentType.summary => '/admin/summaries/$updateId',
      ContentType.quiz || ContentType.task => '/admin/assessments/$updateId',
      ContentType.exam => '/admin/exams/$updateId',
      ContentType.file => '/admin/course-files/$updateId',
    };

    if (updateId == null) {
      await _apiClient.multipart<void>(
        createPath,
        data: formData,
        decoder: (_) {},
      );
      return;
    }

    formData.fields.add(const MapEntry('_method', 'PUT'));
    await _apiClient.post<void>(updatePath, data: formData, decoder: (_) {});
  }
}
