import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../models/upload_model.dart';
import '../services/uploads_service.dart';

class UploadsRepository {
  UploadsRepository(this._service);

  final UploadsService _service;
  final Map<String, CancelToken> _cancelTokens = <String, CancelToken>{};

  List<UploadItem>? _cache;
  UploadLookups? _lookups;

  Future<UploadFetchResult> fetchUploads({
    required UploadListFilters filters,
    required UploadListSort sort,
    required UploadPagination pagination,
  }) async {
    _seedIfNeeded();
    final isOnline = await _service.isOnline();

    if (isOnline) {
      try {
        final remote = await _service.fetchUploads(
          filters: filters,
          sort: sort,
          pagination: pagination,
        );
        _cache = remote.items;
        _lookups = _mergeLookups(remote.lookups);
        return UploadFetchResult(
          bundle: UploadListBundle(
            items: remote.items,
            pagination: remote.pagination,
            lookups: _lookups!,
            totalStorageBytes: remote.totalStorageBytes,
          ),
        );
      } catch (_) {}
    }

    final filtered = _applyFilters(_cache!, filters);
    final sorted = _applySort(filtered, sort);
    return UploadFetchResult(
      bundle: UploadListBundle(
        items: _applyPagination(sorted, pagination),
        pagination: _buildPagination(
          totalItems: sorted.length,
          pagination: pagination,
        ),
        lookups: _lookups!,
        totalStorageBytes: _cache!.fold<int>(
          0,
          (sum, item) => sum + item.sizeBytes,
        ),
      ),
      isOffline: !isOnline,
      feedbackMessage: !isOnline
          ? 'You are offline. Showing the latest synced uploads.'
          : null,
    );
  }

  Future<UploadItem> uploadFile(
    UploadLocalFile file, {
    required UploadAssignmentPayload assignment,
    required String uploadedBy,
    void Function(double progress)? onProgress,
  }) async {
    _seedIfNeeded();
    final cancelToken = CancelToken();
    _cancelTokens[file.localId] = cancelToken;

    try {
      final item = await _service.uploadFile(
        file,
        assignment: assignment,
        cancelToken: cancelToken,
        onProgress: onProgress,
      );
      _cancelTokens.remove(file.localId);
      final resolved = item.copyWith(
        assignment: _resolveAssignment(item.assignment, assignment),
        accessControl: assignment.accessControl,
        uploadedBy: item.uploadedBy.isEmpty ? uploadedBy : item.uploadedBy,
        clearLocalBytes: true,
        clearLocalPath: true,
      );
      _upsertItem(resolved);
      return resolved;
    } on DioException catch (error) {
      _cancelTokens.remove(file.localId);
      if (CancelToken.isCancel(error)) {
        throw AppException('Upload cancelled.');
      }
      rethrow;
    } catch (_) {
      _cancelTokens.remove(file.localId);
      rethrow;
    }
  }

  void cancelUpload(String uploadId) {
    _cancelTokens.remove(uploadId)?.cancel();
  }

  Future<UploadMutationResult> deleteUploads(
    Set<String> uploadIds, {
    required UploadListFilters filters,
    required UploadListSort sort,
    required UploadPagination pagination,
  }) async {
    _seedIfNeeded();
    for (final id in uploadIds) {
      try {
        await _service.deleteUpload(id);
      } catch (_) {}
    }

    _cache = _cache!
        .where((item) => !uploadIds.contains(item.id))
        .toList(growable: false);
    final filtered = _applySort(_applyFilters(_cache!, filters), sort);
    return UploadMutationResult(
      items: _applyPagination(filtered, pagination),
      pagination: _buildPagination(
        totalItems: filtered.length,
        pagination: pagination,
      ),
      message:
          'Deleted ${uploadIds.length} upload${uploadIds.length == 1 ? '' : 's'}.',
    );
  }

  Future<UploadMutationResult> assignUploads(
    Set<String> uploadIds,
    UploadAssignmentPayload payload, {
    required UploadListFilters filters,
    required UploadListSort sort,
    required UploadPagination pagination,
  }) async {
    _seedIfNeeded();
    try {
      await _service.assignUploads(uploadIds, payload);
    } catch (_) {}

    _cache = _cache!
        .map((item) {
          if (!uploadIds.contains(item.id)) return item;
          return item.copyWith(
            assignment: _resolveAssignment(item.assignment, payload),
            accessControl: payload.accessControl,
          );
        })
        .toList(growable: false);
    final filtered = _applySort(_applyFilters(_cache!, filters), sort);
    return UploadMutationResult(
      items: _applyPagination(filtered, pagination),
      pagination: _buildPagination(
        totalItems: filtered.length,
        pagination: pagination,
      ),
      message:
          'Assigned ${uploadIds.length} upload${uploadIds.length == 1 ? '' : 's'}.',
    );
  }

  Future<UploadPreviewData> fetchPreview(String uploadId) async {
    _seedIfNeeded();
    final item = _cache!.firstWhere(
      (candidate) => candidate.id == uploadId,
      orElse: () =>
          throw AppException('The selected upload could not be found.'),
    );
    try {
      return await _service.fetchPreview(item);
    } catch (_) {
      return UploadPreviewData.fromItem(item);
    }
  }

  List<UploadItem> itemsByIds(Set<String> uploadIds) {
    _seedIfNeeded();
    return _cache!
        .where((item) => uploadIds.contains(item.id))
        .toList(growable: false);
  }

  UploadAssignment _resolveAssignment(
    UploadAssignment current,
    UploadAssignmentPayload payload,
  ) {
    final course = _lookups?.courses.firstWhereOrNull(
      (item) => item.id == payload.courseId,
    );
    final section = _lookups?.sections.firstWhereOrNull(
      (item) => item.id == payload.sectionId,
    );
    final subject = _lookups?.subjects.firstWhereOrNull(
      (item) => item.id == payload.subjectId,
    );
    return current.copyWith(
      courseId: payload.courseId,
      courseName: payload.courseId == null ? current.courseName : course?.label,
      sectionId: payload.sectionId,
      sectionName: payload.sectionId == null
          ? current.sectionName
          : section?.label,
      subjectId: payload.subjectId,
      subjectName: payload.subjectId == null
          ? current.subjectName
          : subject?.label,
      academicYear: payload.academicYear,
    );
  }

  UploadPagination _buildPagination({
    required int totalItems,
    required UploadPagination pagination,
  }) {
    final totalPages = totalItems == 0
        ? 1
        : (totalItems / pagination.perPage).ceil();
    return pagination.copyWith(
      page: math.min(pagination.page, totalPages),
      totalItems: totalItems,
      totalPages: totalPages,
    );
  }

  List<UploadItem> _applyFilters(
    List<UploadItem> items,
    UploadListFilters filters,
  ) {
    final query = filters.searchQuery.trim().toLowerCase();
    return items
        .where((item) {
          final matchesQuery =
              query.isEmpty ||
              item.name.toLowerCase().contains(query) ||
              item.assignment.materialLabel.toLowerCase().contains(query) ||
              item.assignment.sectionLabel.toLowerCase().contains(query) ||
              item.uploadedBy.toLowerCase().contains(query);
          final matchesType = filters.type == null || item.type == filters.type;
          final matchesMaterial =
              filters.materialId == null ||
              item.assignment.subjectId == filters.materialId ||
              item.assignment.courseId == filters.materialId;
          final matchesSection =
              filters.sectionId == null ||
              item.assignment.sectionId == filters.sectionId;
          final matchesYear =
              filters.year == null ||
              item.assignment.academicYear == filters.year;
          final matchesStatus =
              filters.status == null || item.status == filters.status;
          return matchesQuery &&
              matchesType &&
              matchesMaterial &&
              matchesSection &&
              matchesYear &&
              matchesStatus;
        })
        .toList(growable: false);
  }

  List<UploadItem> _applySort(List<UploadItem> items, UploadListSort sort) {
    final ordered = List<UploadItem>.from(items);
    int compare<T extends Comparable<Object>>(T left, T right) =>
        left.compareTo(right);

    ordered.sort((a, b) {
      final result = switch (sort.field) {
        UploadSortField.name => compare(a.name, b.name),
        UploadSortField.type => compare(a.type.label, b.type.label),
        UploadSortField.size => compare(a.sizeBytes, b.sizeBytes),
        UploadSortField.material => compare(
          a.assignment.materialLabel,
          b.assignment.materialLabel,
        ),
        UploadSortField.uploadedAt => compare(a.uploadedAt, b.uploadedAt),
        UploadSortField.status => compare(a.status.index, b.status.index),
      };
      return sort.ascending ? result : -result;
    });
    return List<UploadItem>.unmodifiable(ordered);
  }

  List<UploadItem> _applyPagination(
    List<UploadItem> items,
    UploadPagination pagination,
  ) {
    final totalPages = items.isEmpty
        ? 1
        : (items.length / pagination.perPage).ceil();
    final resolvedPage = math.min(pagination.page, totalPages);
    final start = math.max(0, (resolvedPage - 1) * pagination.perPage);
    final end = math.min(items.length, start + pagination.perPage);
    return List<UploadItem>.unmodifiable(items.sublist(start, end));
  }

  void _upsertItem(UploadItem item) {
    _cache = [
      item,
      for (final existing in _cache!)
        if (existing.id != item.id) existing,
    ];
  }

  UploadLookups _mergeLookups(UploadLookups incoming) {
    final current = _lookups ?? const UploadLookups();
    return current.copyWith(
      courses: incoming.courses.isEmpty ? current.courses : incoming.courses,
      sections: incoming.sections.isEmpty
          ? current.sections
          : incoming.sections,
      subjects: incoming.subjects.isEmpty
          ? current.subjects
          : incoming.subjects,
      years: incoming.years.isEmpty ? current.years : incoming.years,
      uploaders: incoming.uploaders.isEmpty
          ? current.uploaders
          : incoming.uploaders,
      materials: incoming.materials.isEmpty
          ? current.materials
          : incoming.materials,
    );
  }

  void _seedIfNeeded() {
    _lookups ??= const UploadLookups(
      courses: <UploadLookupOption>[
        UploadLookupOption(id: 'course-cs401', label: 'Advanced Algorithms'),
        UploadLookupOption(id: 'course-is305', label: 'Enterprise Systems'),
        UploadLookupOption(id: 'course-eng210', label: 'Thermodynamics'),
      ],
      sections: <UploadLookupOption>[
        UploadLookupOption(id: 'section-cs4a', label: 'CS-4A'),
        UploadLookupOption(id: 'section-is3b', label: 'IS-3B'),
        UploadLookupOption(id: 'section-eng2a', label: 'ENG-2A'),
      ],
      subjects: <UploadLookupOption>[
        UploadLookupOption(id: 'subject-cs401', label: 'Greedy & DP Sheets'),
        UploadLookupOption(id: 'subject-is305', label: 'Lecture Assets'),
        UploadLookupOption(id: 'subject-eng210', label: 'Lab Demonstrations'),
      ],
      years: <String>['2025/2026', '2026/2027'],
      uploaders: <UploadLookupOption>[
        UploadLookupOption(id: 'admin-1', label: 'Dr. Laila Hassan'),
        UploadLookupOption(id: 'doctor-1', label: 'Dr. Hadeer Salah'),
        UploadLookupOption(id: 'assistant-1', label: 'Eng. Ahmed Samir'),
      ],
      materials: <UploadLookupOption>[
        UploadLookupOption(id: 'subject-cs401', label: 'Greedy & DP Sheets'),
        UploadLookupOption(id: 'subject-is305', label: 'Lecture Assets'),
        UploadLookupOption(id: 'subject-eng210', label: 'Lab Demonstrations'),
      ],
    );

    _cache ??= <UploadItem>[
      UploadItem(
        id: 'upload-1001',
        name: 'advanced-algorithms-week-08.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 3670016,
        assignment: const UploadAssignment(
          courseId: 'course-cs401',
          courseName: 'Advanced Algorithms',
          sectionId: 'section-cs4a',
          sectionName: 'CS-4A',
          subjectId: 'subject-cs401',
          subjectName: 'Greedy & DP Sheets',
          academicYear: '2025/2026',
        ),
        uploadedBy: 'Dr. Hadeer Salah',
        uploadedAt: DateTime(2026, 3, 27, 9, 30),
        status: UploadStatus.uploaded,
        progress: 1,
        accessControl: const UploadAccessControl(
          level: UploadAccessLevel.students,
          canDownload: true,
        ),
        previewUrl:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        downloadUrl:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      ),
      UploadItem(
        id: 'upload-1002',
        name: 'enterprise-systems-architecture.png',
        mimeType: 'image/png',
        sizeBytes: 1520435,
        assignment: const UploadAssignment(
          courseId: 'course-is305',
          courseName: 'Enterprise Systems',
          sectionId: 'section-is3b',
          sectionName: 'IS-3B',
          subjectId: 'subject-is305',
          subjectName: 'Lecture Assets',
          academicYear: '2025/2026',
        ),
        uploadedBy: 'Eng. Ahmed Samir',
        uploadedAt: DateTime(2026, 3, 26, 14, 10),
        status: UploadStatus.uploaded,
        progress: 1,
        accessControl: const UploadAccessControl(
          level: UploadAccessLevel.courseOnly,
          canDownload: true,
        ),
        previewUrl:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=600&q=80',
        downloadUrl:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80',
      ),
      UploadItem(
        id: 'upload-1003',
        name: 'thermodynamics-lab-demo.mp4',
        mimeType: 'video/mp4',
        sizeBytes: 26528972,
        assignment: const UploadAssignment(
          courseId: 'course-eng210',
          courseName: 'Thermodynamics',
          sectionId: 'section-eng2a',
          sectionName: 'ENG-2A',
          subjectId: 'subject-eng210',
          subjectName: 'Lab Demonstrations',
          academicYear: '2025/2026',
        ),
        uploadedBy: 'Dr. Laila Hassan',
        uploadedAt: DateTime(2026, 3, 24, 16, 45),
        status: UploadStatus.failed,
        progress: .42,
        accessControl: const UploadAccessControl(
          level: UploadAccessLevel.sectionOnly,
          canDownload: false,
        ),
        thumbnailUrl:
            'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1200&q=80',
        previewUrl: 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
        downloadUrl: 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
        errorMessage: 'Connection dropped during chunk 5 of 12.',
      ),
      UploadItem(
        id: 'upload-1004',
        name: 'semester-upload-policy.xlsx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        sizeBytes: 861245,
        assignment: const UploadAssignment(
          courseId: 'course-cs401',
          courseName: 'Advanced Algorithms',
          sectionId: 'section-cs4a',
          sectionName: 'CS-4A',
          subjectId: 'subject-cs401',
          subjectName: 'Greedy & DP Sheets',
          academicYear: '2026/2027',
        ),
        uploadedBy: 'Dr. Laila Hassan',
        uploadedAt: DateTime(2026, 3, 21, 10, 12),
        status: UploadStatus.uploading,
        progress: .68,
        accessControl: const UploadAccessControl(
          level: UploadAccessLevel.private,
          canDownload: true,
        ),
      ),
    ];
  }
}
