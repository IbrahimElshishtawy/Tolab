import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/helpers/json_types.dart';

enum UploadFileType {
  image,
  pdf,
  video,
  spreadsheet,
  archive,
  document,
  audio,
  other,
}

extension UploadFileTypeX on UploadFileType {
  String get label => switch (this) {
    UploadFileType.image => 'Image',
    UploadFileType.pdf => 'PDF',
    UploadFileType.video => 'Video',
    UploadFileType.spreadsheet => 'Spreadsheet',
    UploadFileType.archive => 'Archive',
    UploadFileType.document => 'Document',
    UploadFileType.audio => 'Audio',
    UploadFileType.other => 'Other',
  };

  IconData get icon => switch (this) {
    UploadFileType.image => Icons.image_rounded,
    UploadFileType.pdf => Icons.picture_as_pdf_rounded,
    UploadFileType.video => Icons.play_circle_outline_rounded,
    UploadFileType.spreadsheet => Icons.table_chart_rounded,
    UploadFileType.archive => Icons.folder_zip_rounded,
    UploadFileType.document => Icons.description_rounded,
    UploadFileType.audio => Icons.graphic_eq_rounded,
    UploadFileType.other => Icons.insert_drive_file_rounded,
  };

  Color get accent => switch (this) {
    UploadFileType.image => AppColors.info,
    UploadFileType.pdf => AppColors.danger,
    UploadFileType.video => AppColors.purple,
    UploadFileType.spreadsheet => AppColors.secondary,
    UploadFileType.archive => AppColors.warning,
    UploadFileType.document => AppColors.primary,
    UploadFileType.audio => AppColors.info,
    UploadFileType.other => AppColors.slate,
  };

  bool get supportsRichPreview => switch (this) {
    UploadFileType.image || UploadFileType.pdf || UploadFileType.video => true,
    _ => false,
  };

  static UploadFileType fromMimeType(String mimeType, {String? fileName}) {
    final lowerMime = mimeType.toLowerCase();
    final lowerName = fileName?.toLowerCase() ?? '';

    if (lowerMime.startsWith('image/') ||
        _matchesExtension(lowerName, const [
          'png',
          'jpg',
          'jpeg',
          'gif',
          'webp',
        ])) {
      return UploadFileType.image;
    }
    if (lowerMime == 'application/pdf' || lowerName.endsWith('.pdf')) {
      return UploadFileType.pdf;
    }
    if (lowerMime.startsWith('video/') ||
        _matchesExtension(lowerName, const [
          'mp4',
          'mov',
          'avi',
          'mkv',
          'webm',
        ])) {
      return UploadFileType.video;
    }
    if (lowerMime.contains('sheet') ||
        lowerMime.contains('excel') ||
        _matchesExtension(lowerName, const ['xlsx', 'xls', 'csv'])) {
      return UploadFileType.spreadsheet;
    }
    if (lowerMime.contains('zip') ||
        lowerMime.contains('rar') ||
        lowerMime.contains('tar') ||
        lowerMime.contains('7z') ||
        _matchesExtension(lowerName, const ['zip', 'rar', '7z', 'tar', 'gz'])) {
      return UploadFileType.archive;
    }
    if (lowerMime.startsWith('audio/') ||
        _matchesExtension(lowerName, const ['mp3', 'wav', 'aac'])) {
      return UploadFileType.audio;
    }
    if (lowerMime.startsWith('text/') ||
        lowerMime.contains('word') ||
        lowerMime.contains('document') ||
        _matchesExtension(lowerName, const [
          'doc',
          'docx',
          'txt',
          'ppt',
          'pptx',
        ])) {
      return UploadFileType.document;
    }
    return UploadFileType.other;
  }

  static bool _matchesExtension(String name, List<String> extensions) {
    return extensions.any((extension) => name.endsWith('.$extension'));
  }
}

enum UploadStatus { uploaded, uploading, failed, cancelled }

extension UploadStatusX on UploadStatus {
  String get label => switch (this) {
    UploadStatus.uploaded => 'Uploaded',
    UploadStatus.uploading => 'Uploading',
    UploadStatus.failed => 'Failed',
    UploadStatus.cancelled => 'Cancelled',
  };

  String get apiValue => switch (this) {
    UploadStatus.uploaded => 'uploaded',
    UploadStatus.uploading => 'uploading',
    UploadStatus.failed => 'failed',
    UploadStatus.cancelled => 'cancelled',
  };

  static UploadStatus fromJson(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      'uploaded' ||
      'complete' ||
      'completed' ||
      'success' => UploadStatus.uploaded,
      'uploading' || 'processing' || 'queued' => UploadStatus.uploading,
      'cancelled' || 'canceled' => UploadStatus.cancelled,
      _ => UploadStatus.failed,
    };
  }
}

enum UploadAccessLevel {
  private,
  sectionOnly,
  courseOnly,
  students,
  publicLink,
}

extension UploadAccessLevelX on UploadAccessLevel {
  String get label => switch (this) {
    UploadAccessLevel.private => 'Admins only',
    UploadAccessLevel.sectionOnly => 'Assigned section',
    UploadAccessLevel.courseOnly => 'Assigned course',
    UploadAccessLevel.students => 'Enrolled students',
    UploadAccessLevel.publicLink => 'Secure link',
  };

  String get apiValue => switch (this) {
    UploadAccessLevel.private => 'private',
    UploadAccessLevel.sectionOnly => 'section_only',
    UploadAccessLevel.courseOnly => 'course_only',
    UploadAccessLevel.students => 'students',
    UploadAccessLevel.publicLink => 'public_link',
  };

  static UploadAccessLevel fromJson(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      'section_only' => UploadAccessLevel.sectionOnly,
      'course_only' => UploadAccessLevel.courseOnly,
      'students' => UploadAccessLevel.students,
      'public_link' => UploadAccessLevel.publicLink,
      _ => UploadAccessLevel.private,
    };
  }
}

enum UploadViewMode { table, grid }

enum UploadSortField { name, type, size, material, uploadedAt, status }

extension UploadSortFieldX on UploadSortField {
  String get apiValue => switch (this) {
    UploadSortField.name => 'name',
    UploadSortField.type => 'type',
    UploadSortField.size => 'size',
    UploadSortField.material => 'material',
    UploadSortField.uploadedAt => 'uploaded_at',
    UploadSortField.status => 'status',
  };
}

enum UploadPreviewKind { image, pdf, video, unsupported }

class UploadLookupOption {
  const UploadLookupOption({
    required this.id,
    required this.label,
    this.subtitle,
  });

  final String id;
  final String label;
  final String? subtitle;

  factory UploadLookupOption.fromJson(JsonMap json) {
    return UploadLookupOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
    );
  }
}

class UploadLookups {
  const UploadLookups({
    this.courses = const <UploadLookupOption>[],
    this.sections = const <UploadLookupOption>[],
    this.subjects = const <UploadLookupOption>[],
    this.years = const <String>[],
    this.uploaders = const <UploadLookupOption>[],
    this.materials = const <UploadLookupOption>[],
  });

  final List<UploadLookupOption> courses;
  final List<UploadLookupOption> sections;
  final List<UploadLookupOption> subjects;
  final List<String> years;
  final List<UploadLookupOption> uploaders;
  final List<UploadLookupOption> materials;

  UploadLookups copyWith({
    List<UploadLookupOption>? courses,
    List<UploadLookupOption>? sections,
    List<UploadLookupOption>? subjects,
    List<String>? years,
    List<UploadLookupOption>? uploaders,
    List<UploadLookupOption>? materials,
  }) {
    return UploadLookups(
      courses: List<UploadLookupOption>.unmodifiable(courses ?? this.courses),
      sections: List<UploadLookupOption>.unmodifiable(
        sections ?? this.sections,
      ),
      subjects: List<UploadLookupOption>.unmodifiable(
        subjects ?? this.subjects,
      ),
      years: List<String>.unmodifiable(years ?? this.years),
      uploaders: List<UploadLookupOption>.unmodifiable(
        uploaders ?? this.uploaders,
      ),
      materials: List<UploadLookupOption>.unmodifiable(
        materials ?? this.materials,
      ),
    );
  }

  factory UploadLookups.fromJson(JsonMap json) {
    List<UploadLookupOption> decodeLookup(dynamic raw) {
      if (raw is! List) return const <UploadLookupOption>[];
      return raw
          .whereType<JsonMap>()
          .map(UploadLookupOption.fromJson)
          .toList(growable: false);
    }

    List<String> decodeYears(dynamic raw) {
      if (raw is! List) return const <String>[];
      return raw.map((item) => item.toString()).toList(growable: false);
    }

    return UploadLookups(
      courses: decodeLookup(json['courses']),
      sections: decodeLookup(json['sections']),
      subjects: decodeLookup(json['subjects']),
      years: decodeYears(json['years']),
      uploaders: decodeLookup(json['uploaders']),
      materials: decodeLookup(json['materials']),
    );
  }
}

class UploadAccessControl {
  const UploadAccessControl({
    this.level = UploadAccessLevel.private,
    this.canDownload = true,
    this.allowPublicLink = false,
    this.allowedRoleIds = const <String>[],
    this.expiresAt,
  });

  final UploadAccessLevel level;
  final bool canDownload;
  final bool allowPublicLink;
  final List<String> allowedRoleIds;
  final DateTime? expiresAt;

  UploadAccessControl copyWith({
    UploadAccessLevel? level,
    bool? canDownload,
    bool? allowPublicLink,
    List<String>? allowedRoleIds,
    DateTime? expiresAt,
    bool clearExpiry = false,
  }) {
    return UploadAccessControl(
      level: level ?? this.level,
      canDownload: canDownload ?? this.canDownload,
      allowPublicLink: allowPublicLink ?? this.allowPublicLink,
      allowedRoleIds: List<String>.unmodifiable(
        allowedRoleIds ?? this.allowedRoleIds,
      ),
      expiresAt: clearExpiry ? null : expiresAt ?? this.expiresAt,
    );
  }

  factory UploadAccessControl.fromJson(JsonMap json) {
    return UploadAccessControl(
      level: UploadAccessLevelX.fromJson(json['level']),
      canDownload: json['can_download'] as bool? ?? true,
      allowPublicLink: json['allow_public_link'] as bool? ?? false,
      allowedRoleIds: ((json['allowed_role_ids'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
    );
  }

  JsonMap toJson() {
    return <String, dynamic>{
      'level': level.apiValue,
      'can_download': canDownload,
      'allow_public_link': allowPublicLink,
      'allowed_role_ids': allowedRoleIds,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }
}

class UploadAssignment {
  const UploadAssignment({
    this.courseId,
    this.courseName,
    this.sectionId,
    this.sectionName,
    this.subjectId,
    this.subjectName,
    this.academicYear,
  });

  final String? courseId;
  final String? courseName;
  final String? sectionId;
  final String? sectionName;
  final String? subjectId;
  final String? subjectName;
  final String? academicYear;

  String get materialLabel => subjectName ?? courseName ?? 'Unassigned';
  String get sectionLabel => sectionName ?? academicYear ?? 'No section';

  UploadAssignment copyWith({
    String? courseId,
    String? courseName,
    String? sectionId,
    String? sectionName,
    String? subjectId,
    String? subjectName,
    String? academicYear,
    bool clearCourse = false,
    bool clearSection = false,
    bool clearSubject = false,
    bool clearYear = false,
  }) {
    return UploadAssignment(
      courseId: clearCourse ? null : courseId ?? this.courseId,
      courseName: clearCourse ? null : courseName ?? this.courseName,
      sectionId: clearSection ? null : sectionId ?? this.sectionId,
      sectionName: clearSection ? null : sectionName ?? this.sectionName,
      subjectId: clearSubject ? null : subjectId ?? this.subjectId,
      subjectName: clearSubject ? null : subjectName ?? this.subjectName,
      academicYear: clearYear ? null : academicYear ?? this.academicYear,
    );
  }

  factory UploadAssignment.fromJson(JsonMap json) {
    return UploadAssignment(
      courseId: json['course_id']?.toString(),
      courseName: json['course_name']?.toString(),
      sectionId: json['section_id']?.toString(),
      sectionName: json['section_name']?.toString(),
      subjectId: json['subject_id']?.toString(),
      subjectName: json['subject_name']?.toString(),
      academicYear: json['academic_year']?.toString(),
    );
  }

  JsonMap toJson() {
    return <String, dynamic>{
      if (courseId != null) 'course_id': courseId,
      if (courseName != null) 'course_name': courseName,
      if (sectionId != null) 'section_id': sectionId,
      if (sectionName != null) 'section_name': sectionName,
      if (subjectId != null) 'subject_id': subjectId,
      if (subjectName != null) 'subject_name': subjectName,
      if (academicYear != null) 'academic_year': academicYear,
    };
  }
}

class UploadAssignmentPayload {
  const UploadAssignmentPayload({
    this.courseId,
    this.sectionId,
    this.subjectId,
    this.academicYear,
    this.accessControl = const UploadAccessControl(),
  });

  final String? courseId;
  final String? sectionId;
  final String? subjectId;
  final String? academicYear;
  final UploadAccessControl accessControl;

  JsonMap toJson() {
    return <String, dynamic>{
      if (courseId != null) 'course_id': courseId,
      if (sectionId != null) 'section_id': sectionId,
      if (subjectId != null) 'subject_id': subjectId,
      if (academicYear != null) 'academic_year': academicYear,
      'permissions': accessControl.toJson(),
    };
  }
}

class UploadLocalFile {
  const UploadLocalFile({
    required this.localId,
    required this.name,
    required this.sizeBytes,
    required this.mimeType,
    this.path,
    this.bytes,
  });

  final String localId;
  final String name;
  final int sizeBytes;
  final String mimeType;
  final String? path;
  final Uint8List? bytes;

  UploadFileType get type =>
      UploadFileTypeX.fromMimeType(mimeType, fileName: name);
}

class UploadItem {
  const UploadItem({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.assignment,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.status,
    required this.progress,
    required this.accessControl,
    this.previewUrl,
    this.thumbnailUrl,
    this.downloadUrl,
    this.errorMessage,
    this.localPath,
    this.localBytes,
  });

  final String id;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final UploadAssignment assignment;
  final String uploadedBy;
  final DateTime uploadedAt;
  final UploadStatus status;
  final double progress;
  final UploadAccessControl accessControl;
  final String? previewUrl;
  final String? thumbnailUrl;
  final String? downloadUrl;
  final String? errorMessage;
  final String? localPath;
  final Uint8List? localBytes;

  UploadFileType get type =>
      UploadFileTypeX.fromMimeType(mimeType, fileName: name);

  bool get hasLocalSource => localPath != null || localBytes != null;
  bool get isPreviewable => type.supportsRichPreview;
  bool get isUploading => status == UploadStatus.uploading;
  bool get isFailed => status == UploadStatus.failed;
  bool get isUploaded => status == UploadStatus.uploaded;

  UploadLocalFile? get localFile {
    if (!hasLocalSource) return null;
    return UploadLocalFile(
      localId: id,
      name: name,
      sizeBytes: sizeBytes,
      mimeType: mimeType,
      path: localPath,
      bytes: localBytes,
    );
  }

  UploadItem copyWith({
    String? id,
    String? name,
    String? mimeType,
    int? sizeBytes,
    UploadAssignment? assignment,
    String? uploadedBy,
    DateTime? uploadedAt,
    UploadStatus? status,
    double? progress,
    UploadAccessControl? accessControl,
    String? previewUrl,
    bool clearPreviewUrl = false,
    String? thumbnailUrl,
    bool clearThumbnailUrl = false,
    String? downloadUrl,
    bool clearDownloadUrl = false,
    String? errorMessage,
    bool clearError = false,
    String? localPath,
    bool clearLocalPath = false,
    Uint8List? localBytes,
    bool clearLocalBytes = false,
  }) {
    return UploadItem(
      id: id ?? this.id,
      name: name ?? this.name,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      assignment: assignment ?? this.assignment,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      accessControl: accessControl ?? this.accessControl,
      previewUrl: clearPreviewUrl ? null : previewUrl ?? this.previewUrl,
      thumbnailUrl: clearThumbnailUrl
          ? null
          : thumbnailUrl ?? this.thumbnailUrl,
      downloadUrl: clearDownloadUrl ? null : downloadUrl ?? this.downloadUrl,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      localPath: clearLocalPath ? null : localPath ?? this.localPath,
      localBytes: clearLocalBytes ? null : localBytes ?? this.localBytes,
    );
  }

  factory UploadItem.fromJson(JsonMap json) {
    final fileName =
        json['name']?.toString() ?? json['file_name']?.toString() ?? 'Upload';
    final mimeType =
        json['mime_type']?.toString() ??
        json['mimeType']?.toString() ??
        'application/octet-stream';
    return UploadItem(
      id: json['id']?.toString() ?? '',
      name: fileName,
      mimeType: mimeType,
      sizeBytes: _readInt(
        json['size_bytes'] ?? json['size'] ?? json['file_size'],
        fallback: 0,
      ),
      assignment: json['assignment'] is JsonMap
          ? UploadAssignment.fromJson(json['assignment'] as JsonMap)
          : UploadAssignment.fromJson(json),
      uploadedBy:
          json['uploaded_by']?.toString() ??
          json['uploadedBy']?.toString() ??
          'Administrator',
      uploadedAt:
          DateTime.tryParse(
            json['uploaded_at']?.toString() ??
                json['created_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      status: UploadStatusX.fromJson(json['status']),
      progress: _readDouble(json['progress'], fallback: 1),
      accessControl: json['permissions'] is JsonMap
          ? UploadAccessControl.fromJson(json['permissions'] as JsonMap)
          : const UploadAccessControl(),
      previewUrl: json['preview_url']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      downloadUrl: json['download_url']?.toString() ?? json['url']?.toString(),
      errorMessage: json['error_message']?.toString(),
    );
  }

  static UploadItem local({
    required UploadLocalFile file,
    required String uploadedBy,
    required UploadAssignment assignment,
    required UploadAccessControl accessControl,
  }) {
    return UploadItem(
      id: file.localId,
      name: file.name,
      mimeType: file.mimeType,
      sizeBytes: file.sizeBytes,
      assignment: assignment,
      uploadedBy: uploadedBy,
      uploadedAt: DateTime.now(),
      status: UploadStatus.uploading,
      progress: 0,
      accessControl: accessControl,
      localPath: file.path,
      localBytes: file.bytes,
    );
  }
}

class UploadListFilters {
  const UploadListFilters({
    this.searchQuery = '',
    this.type,
    this.materialId,
    this.sectionId,
    this.year,
    this.status,
  });

  final String searchQuery;
  final UploadFileType? type;
  final String? materialId;
  final String? sectionId;
  final String? year;
  final UploadStatus? status;

  UploadListFilters copyWith({
    String? searchQuery,
    UploadFileType? type,
    bool clearType = false,
    String? materialId,
    bool clearMaterial = false,
    String? sectionId,
    bool clearSection = false,
    String? year,
    bool clearYear = false,
    UploadStatus? status,
    bool clearStatus = false,
  }) {
    return UploadListFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      type: clearType ? null : type ?? this.type,
      materialId: clearMaterial ? null : materialId ?? this.materialId,
      sectionId: clearSection ? null : sectionId ?? this.sectionId,
      year: clearYear ? null : year ?? this.year,
      status: clearStatus ? null : status ?? this.status,
    );
  }

  JsonMap toQuery() {
    return <String, dynamic>{
      if (searchQuery.trim().isNotEmpty) 'search': searchQuery.trim(),
      if (type != null) 'type': type!.label.toLowerCase(),
      if (materialId != null) 'material_id': materialId,
      if (sectionId != null) 'section_id': sectionId,
      if (year != null) 'year': year,
      if (status != null) 'status': status!.apiValue,
    };
  }
}

class UploadListSort {
  const UploadListSort({
    this.field = UploadSortField.uploadedAt,
    this.ascending = false,
  });

  final UploadSortField field;
  final bool ascending;

  UploadListSort copyWith({UploadSortField? field, bool? ascending}) {
    return UploadListSort(
      field: field ?? this.field,
      ascending: ascending ?? this.ascending,
    );
  }
}

class UploadPagination {
  const UploadPagination({
    this.page = 1,
    this.perPage = 12,
    this.totalItems = 0,
    this.totalPages = 1,
  });

  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;

  UploadPagination copyWith({
    int? page,
    int? perPage,
    int? totalItems,
    int? totalPages,
  }) {
    return UploadPagination(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class UploadPreviewData {
  const UploadPreviewData({
    required this.uploadId,
    required this.kind,
    required this.fileName,
    required this.mimeType,
    this.previewUrl,
    this.thumbnailUrl,
    this.downloadUrl,
    this.bytes,
    this.localPath,
    this.sizeBytes = 0,
    this.durationLabel,
  });

  final String uploadId;
  final UploadPreviewKind kind;
  final String fileName;
  final String mimeType;
  final String? previewUrl;
  final String? thumbnailUrl;
  final String? downloadUrl;
  final Uint8List? bytes;
  final String? localPath;
  final int sizeBytes;
  final String? durationLabel;

  factory UploadPreviewData.fromItem(UploadItem item) {
    return UploadPreviewData(
      uploadId: item.id,
      kind: switch (item.type) {
        UploadFileType.image => UploadPreviewKind.image,
        UploadFileType.pdf => UploadPreviewKind.pdf,
        UploadFileType.video => UploadPreviewKind.video,
        _ => UploadPreviewKind.unsupported,
      },
      fileName: item.name,
      mimeType: item.mimeType,
      previewUrl: item.previewUrl,
      thumbnailUrl: item.thumbnailUrl,
      downloadUrl: item.downloadUrl,
      bytes: item.localBytes,
      localPath: item.localPath,
      sizeBytes: item.sizeBytes,
    );
  }

  factory UploadPreviewData.fromJson(JsonMap json, UploadItem fallback) {
    final previewUrl =
        json['preview_url']?.toString() ?? json['url']?.toString();
    final mimeType = json['mime_type']?.toString() ?? fallback.mimeType;
    return UploadPreviewData(
      uploadId: fallback.id,
      kind: switch (UploadFileTypeX.fromMimeType(
        mimeType,
        fileName: fallback.name,
      )) {
        UploadFileType.image => UploadPreviewKind.image,
        UploadFileType.pdf => UploadPreviewKind.pdf,
        UploadFileType.video => UploadPreviewKind.video,
        _ => UploadPreviewKind.unsupported,
      },
      fileName: json['name']?.toString() ?? fallback.name,
      mimeType: mimeType,
      previewUrl: previewUrl ?? fallback.previewUrl,
      thumbnailUrl: json['thumbnail_url']?.toString() ?? fallback.thumbnailUrl,
      downloadUrl: json['download_url']?.toString() ?? fallback.downloadUrl,
      sizeBytes: _readInt(
        json['size_bytes'] ?? json['size'],
        fallback: fallback.sizeBytes,
      ),
      durationLabel: json['duration_label']?.toString(),
      localPath: fallback.localPath,
      bytes: fallback.localBytes,
    );
  }
}

class UploadListBundle {
  const UploadListBundle({
    required this.items,
    required this.pagination,
    required this.lookups,
    required this.totalStorageBytes,
  });

  final List<UploadItem> items;
  final UploadPagination pagination;
  final UploadLookups lookups;
  final int totalStorageBytes;
}

class UploadFetchResult {
  const UploadFetchResult({
    required this.bundle,
    this.isOffline = false,
    this.feedbackMessage,
  });

  final UploadListBundle bundle;
  final bool isOffline;
  final String? feedbackMessage;
}

class UploadMutationResult {
  const UploadMutationResult({
    required this.items,
    required this.pagination,
    required this.message,
  });

  final List<UploadItem> items;
  final UploadPagination pagination;
  final String message;
}

class UploadMetrics {
  const UploadMetrics({
    required this.totalCount,
    required this.uploadedCount,
    required this.uploadingCount,
    required this.failedCount,
    required this.totalStorageBytes,
  });

  final int totalCount;
  final int uploadedCount;
  final int uploadingCount;
  final int failedCount;
  final int totalStorageBytes;
}

int _readInt(dynamic value, {required int fallback}) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _readDouble(dynamic value, {required double fallback}) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
