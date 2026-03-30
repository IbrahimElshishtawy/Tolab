import 'package:flutter/material.dart';

import '../../../core/errors/app_exception.dart';
import '../models/content_models.dart';
import '../services/content_api_service.dart';
import '../services/content_seed_service.dart';

class ContentRepository {
  ContentRepository(this._apiService, this._seedService);

  final ContentApiService _apiService;
  final ContentSeedService _seedService;

  ContentRepositoryBundle? _cache;

  Future<ContentRepositoryBundle> fetchContentBundle() async {
    _cache ??= _seedService.createBundle();
    await Future<void>.delayed(const Duration(milliseconds: 240));
    return _cloneBundle(_cache!);
  }

  Future<ContentMutationResult> createContent({
    required ContentUpsertPayload payload,
    required List<ContentAttachment> attachments,
    required List<ContentUploadTask> uploadTasks,
  }) async {
    final bundle = await _ensureCache();
    final now = DateTime.now();
    final subject = bundle.subjects.firstWhere(
      (item) => item.id == payload.subjectId,
    );
    final section = bundle.sections.firstWhere(
      (item) => item.id == payload.sectionId,
    );
    final instructor = bundle.instructors.firstWhere(
      (item) => item.id == payload.instructorId,
    );

    try {
      await _apiService.createContent(
        payload,
        uploadTasks.map((item) => item.source).toList(growable: false),
      );
    } catch (_) {}

    final record = ContentRecord(
      id: 'cnt-${now.microsecondsSinceEpoch}',
      title: payload.title,
      description: payload.description,
      type: payload.type,
      status: payload.status,
      visibility: payload.visibility,
      subject: subject,
      section: section,
      instructor: instructor,
      publishAt: payload.publishAt,
      dueAt: payload.dueAt,
      createdAt: now,
      updatedAt: now,
      attachments: List<ContentAttachment>.unmodifiable(attachments),
      students: const [],
      submissions: const [],
      activity: [
        ContentActivityItem(
          id: 'act-create-${now.microsecondsSinceEpoch}',
          title: 'Content created',
          subtitle: 'Prepared in the admin workspace.',
          timestamp: now,
          icon: payload.type.icon,
          tone: instructor.accentColor,
        ),
      ],
      gradeBands: const [],
      permissions: const ContentPermissionSet(),
      assessmentSettings: payload.assessmentSettings,
      enrollmentCount: section.capacity,
      viewCount: 0,
      completionRate: 0,
      isPinned: false,
    );

    _cache = ContentRepositoryBundle(
      items: [record, ...bundle.items],
      subjects: bundle.subjects,
      sections: bundle.sections,
      instructors: bundle.instructors,
    );

    return ContentMutationResult(
      items: _cache!.items,
      message: '${payload.type.label} created successfully.',
      selectedContentId: record.id,
    );
  }

  Future<ContentMutationResult> updateContent({
    required String contentId,
    required ContentUpsertPayload payload,
    required List<ContentAttachment> attachments,
    required List<ContentUploadTask> uploadTasks,
  }) async {
    final bundle = await _ensureCache();
    final existing = bundle.items.firstWhere((item) => item.id == contentId);
    final subject = bundle.subjects.firstWhere(
      (item) => item.id == payload.subjectId,
    );
    final section = bundle.sections.firstWhere(
      (item) => item.id == payload.sectionId,
    );
    final instructor = bundle.instructors.firstWhere(
      (item) => item.id == payload.instructorId,
    );

    try {
      await _apiService.updateContent(
        contentId,
        payload,
        uploadTasks.map((item) => item.source).toList(growable: false),
      );
    } catch (_) {}

    final updated = existing.copyWith(
      title: payload.title,
      description: payload.description,
      type: payload.type,
      status: payload.status,
      visibility: payload.visibility,
      subject: subject,
      section: section,
      instructor: instructor,
      publishAt: payload.publishAt,
      clearPublishAt: payload.publishAt == null,
      dueAt: payload.dueAt,
      clearDueAt: payload.dueAt == null,
      updatedAt: DateTime.now(),
      attachments: attachments,
      activity: [
        ContentActivityItem(
          id: 'act-update-${DateTime.now().microsecondsSinceEpoch}',
          title: 'Content updated',
          subtitle: 'Latest schedule and visibility settings saved.',
          timestamp: DateTime.now(),
          icon: Icons.edit_note_rounded,
          tone: instructor.accentColor,
        ),
        ...existing.activity,
      ],
      assessmentSettings: payload.assessmentSettings,
    );

    _cache = ContentRepositoryBundle(
      items: [
        for (final item in bundle.items)
          if (item.id == contentId) updated else item,
      ],
      subjects: bundle.subjects,
      sections: bundle.sections,
      instructors: bundle.instructors,
    );

    return ContentMutationResult(
      items: _cache!.items,
      message: '${payload.type.label} updated successfully.',
      selectedContentId: updated.id,
    );
  }

  Future<ContentMutationResult> setStatus(
    Set<String> ids,
    ContentStatus status,
  ) async {
    final bundle = await _ensureCache();
    final updatedItems = [
      for (final item in bundle.items)
        ids.contains(item.id)
            ? item.copyWith(status: status, updatedAt: DateTime.now())
            : item,
    ];
    _cache = ContentRepositoryBundle(
      items: updatedItems,
      subjects: bundle.subjects,
      sections: bundle.sections,
      instructors: bundle.instructors,
    );
    return ContentMutationResult(
      items: updatedItems,
      message:
          '${status.label} applied to ${ids.length} item${ids.length == 1 ? '' : 's'}.',
      selectedContentId: ids.length == 1 ? ids.first : null,
    );
  }

  Future<ContentMutationResult> deleteContent(Set<String> ids) async {
    final bundle = await _ensureCache();

    for (final item in bundle.items.where(
      (record) => ids.contains(record.id),
    )) {
      try {
        await _apiService.deleteContent(item.id, item.type);
      } on AppException {
        continue;
      } catch (_) {
        continue;
      }
    }

    final updatedItems = bundle.items
        .where((item) => !ids.contains(item.id))
        .toList(growable: false);
    _cache = ContentRepositoryBundle(
      items: updatedItems,
      subjects: bundle.subjects,
      sections: bundle.sections,
      instructors: bundle.instructors,
    );
    return ContentMutationResult(
      items: updatedItems,
      message: 'Deleted ${ids.length} item${ids.length == 1 ? '' : 's'}.',
    );
  }

  Future<ContentAttachment> uploadAttachment(
    ContentUploadSource source, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      return await _apiService.uploadFile(source, onProgress: onProgress);
    } catch (_) {
      for (var step = 1; step <= 4; step++) {
        await Future<void>.delayed(const Duration(milliseconds: 120));
        onProgress?.call(step / 4);
      }
      return ContentAttachment(
        id: 'upl-${DateTime.now().microsecondsSinceEpoch}',
        name: source.name,
        mimeType: source.mimeType,
        sizeBytes: source.sizeBytes,
        url: '#',
        uploadedAt: DateTime.now(),
        uploadedBy: 'Admin',
      );
    }
  }

  Future<ContentRepositoryBundle> _ensureCache() async {
    _cache ??= _seedService.createBundle();
    return _cache!;
  }

  ContentRepositoryBundle _cloneBundle(ContentRepositoryBundle bundle) {
    return ContentRepositoryBundle(
      items: List<ContentRecord>.unmodifiable(bundle.items),
      subjects: List<ContentSubjectOption>.unmodifiable(bundle.subjects),
      sections: List<ContentSectionOption>.unmodifiable(bundle.sections),
      instructors: List<ContentInstructorOption>.unmodifiable(
        bundle.instructors,
      ),
    );
  }
}
