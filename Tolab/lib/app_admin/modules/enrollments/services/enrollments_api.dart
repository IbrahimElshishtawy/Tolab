import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../models/enrollment_models.dart';

class EnrollmentsApi {
  EnrollmentsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<EnrollmentsBundle> fetchEnrollments({
    required EnrollmentsFilters filters,
    required EnrollmentsSort sort,
    required EnrollmentsPagination pagination,
  }) {
    return _apiClient.get<EnrollmentsBundle>(
      '/admin/enrollments',
      queryParameters: <String, dynamic>{
        'page': pagination.page,
        'per_page': pagination.perPage,
        if (filters.searchQuery.trim().isNotEmpty)
          'search': filters.searchQuery,
        if (filters.status != null) 'status': filters.status!.apiValue,
        if (filters.courseId != null) 'course_id': filters.courseId,
        if (filters.sectionId != null) 'section_id': filters.sectionId,
        if (filters.semester != null) 'semester': filters.semester,
        if (filters.academicYear != null) 'academic_year': filters.academicYear,
        if (filters.staffId != null) 'staff_id': filters.staffId,
        'sort_by': sort.field.apiValue,
        'sort_direction': sort.ascending ? 'asc' : 'desc',
      },
      decoder: (json) => _decodeBundle(json),
    );
  }

  Future<EnrollmentRecord> createEnrollment(EnrollmentUpsertPayload payload) {
    return _apiClient.post<EnrollmentRecord>(
      '/admin/enrollments',
      data: payload.toJson(),
      decoder: (json) => EnrollmentRecord.fromJson(
        (json as JsonMap?) ?? const <String, dynamic>{},
      ),
    );
  }

  Future<EnrollmentRecord> updateEnrollment(
    String enrollmentId,
    EnrollmentUpsertPayload payload,
  ) {
    return _apiClient.put<EnrollmentRecord>(
      '/admin/enrollments/$enrollmentId',
      data: payload.toJson(),
      decoder: (json) => EnrollmentRecord.fromJson(
        (json as JsonMap?) ?? const <String, dynamic>{},
      ),
    );
  }

  Future<void> deleteEnrollment(String enrollmentId) {
    return _apiClient.delete<void>(
      '/admin/enrollments/$enrollmentId',
      decoder: (_) {},
    );
  }

  Future<List<EnrollmentRecord>> bulkUpload(
    List<EnrollmentUpsertPayload> payloads,
  ) {
    return _apiClient.post<List<EnrollmentRecord>>(
      '/admin/enrollments/bulk-upload',
      data: <String, dynamic>{
        'enrollments': payloads.map((item) => item.toJson()).toList(),
      },
      decoder: (json) {
        if (json is List) {
          return json
              .whereType<JsonMap>()
              .map(EnrollmentRecord.fromJson)
              .toList(growable: false);
        }
        if (json is JsonMap && json['items'] is List) {
          return (json['items'] as List)
              .whereType<JsonMap>()
              .map(EnrollmentRecord.fromJson)
              .toList(growable: false);
        }
        return const <EnrollmentRecord>[];
      },
    );
  }

  EnrollmentsBundle _decodeBundle(dynamic json) {
    if (json is JsonMap && json['items'] is List) {
      final lookups = json['lookups'] is JsonMap
          ? EnrollmentLookupBundle.fromJson(json['lookups'] as JsonMap)
          : const EnrollmentLookupBundle();
      final items = (json['items'] as List)
          .whereType<JsonMap>()
          .map(EnrollmentRecord.fromJson)
          .toList(growable: false);
      final pagination = _decodePagination(
        json['pagination'],
        fallbackTotalItems: items.length,
      );
      final summary = json['summary'] is JsonMap
          ? _decodeSummary(json['summary'] as JsonMap)
          : buildEnrollmentSummary(items, lookups.offerings);
      return EnrollmentsBundle(
        items: items,
        pagination: pagination,
        lookups: lookups,
        summary: summary,
      );
    }

    if (json is JsonMap && json['data'] is List) {
      final items = (json['data'] as List)
          .whereType<JsonMap>()
          .map(EnrollmentRecord.fromJson)
          .toList(growable: false);
      final lookups = json['lookups'] is JsonMap
          ? EnrollmentLookupBundle.fromJson(json['lookups'] as JsonMap)
          : const EnrollmentLookupBundle();
      return EnrollmentsBundle(
        items: items,
        pagination: _decodePagination(
          json['meta'],
          fallbackTotalItems: items.length,
        ),
        lookups: lookups,
        summary: buildEnrollmentSummary(items, lookups.offerings),
      );
    }

    if (json is List) {
      final items = json
          .whereType<JsonMap>()
          .map(EnrollmentRecord.fromJson)
          .toList(growable: false);
      return EnrollmentsBundle(
        items: items,
        pagination: EnrollmentsPagination(
          totalItems: items.length,
          totalPages: 1,
        ),
        lookups: const EnrollmentLookupBundle(),
        summary: buildEnrollmentSummary(
          items,
          const <EnrollmentOfferingOption>[],
        ),
      );
    }

    return const EnrollmentsBundle(
      items: <EnrollmentRecord>[],
      pagination: EnrollmentsPagination(),
      lookups: EnrollmentLookupBundle(),
      summary: EnrollmentDashboardSummary(
        totalEnrollments: 0,
        enrolledCount: 0,
        pendingCount: 0,
        rejectedCount: 0,
        averageOccupancy: 0,
        courseSummary: <EnrollmentCourseSummary>[],
        sectionSummary: <EnrollmentSectionSummary>[],
        statusBreakdown: <EnrollmentStatusSlice>[
          EnrollmentStatusSlice(status: EnrollmentStatus.enrolled, count: 0),
          EnrollmentStatusSlice(status: EnrollmentStatus.pending, count: 0),
          EnrollmentStatusSlice(status: EnrollmentStatus.rejected, count: 0),
        ],
      ),
    );
  }

  EnrollmentsPagination _decodePagination(
    dynamic raw, {
    required int fallbackTotalItems,
  }) {
    if (raw is JsonMap) {
      return EnrollmentsPagination(
        page: _readInt(raw['page'] ?? raw['current_page'], fallback: 1),
        perPage: _readInt(raw['per_page'], fallback: 10),
        totalItems: _readInt(
          raw['total'] ?? raw['total_items'],
          fallback: fallbackTotalItems,
        ),
        totalPages: _readInt(
          raw['last_page'] ?? raw['total_pages'],
          fallback: 1,
        ),
      );
    }
    return EnrollmentsPagination(
      totalItems: fallbackTotalItems,
      totalPages: fallbackTotalItems == 0 ? 1 : 1,
    );
  }

  EnrollmentDashboardSummary _decodeSummary(JsonMap json) {
    return EnrollmentDashboardSummary(
      totalEnrollments: _readInt(json['total_enrollments'], fallback: 0),
      enrolledCount: _readInt(json['enrolled_count'], fallback: 0),
      pendingCount: _readInt(json['pending_count'], fallback: 0),
      rejectedCount: _readInt(json['rejected_count'], fallback: 0),
      averageOccupancy:
          double.tryParse(json['average_occupancy']?.toString() ?? '0') ?? 0,
      courseSummary: _decodeCourseSummary(json['course_summary']),
      sectionSummary: _decodeSectionSummary(json['section_summary']),
      statusBreakdown: _decodeStatusBreakdown(json['status_breakdown']),
    );
  }

  List<EnrollmentCourseSummary> _decodeCourseSummary(dynamic raw) {
    if (raw is! List) return const <EnrollmentCourseSummary>[];
    return raw
        .whereType<JsonMap>()
        .map((item) {
          return EnrollmentCourseSummary(
            courseLabel: item['course_label']?.toString() ?? 'Course',
            enrolledCount: _readInt(item['enrolled_count'], fallback: 0),
            pendingCount: _readInt(item['pending_count'], fallback: 0),
            rejectedCount: _readInt(item['rejected_count'], fallback: 0),
          );
        })
        .toList(growable: false);
  }

  List<EnrollmentSectionSummary> _decodeSectionSummary(dynamic raw) {
    if (raw is! List) return const <EnrollmentSectionSummary>[];
    return raw
        .whereType<JsonMap>()
        .map((item) {
          return EnrollmentSectionSummary(
            sectionName: item['section_name']?.toString() ?? 'Section',
            courseLabel: item['course_label']?.toString() ?? 'Course',
            occupied: _readInt(item['occupied'], fallback: 0),
            capacity: _readInt(item['capacity'], fallback: 0),
          );
        })
        .toList(growable: false);
  }

  List<EnrollmentStatusSlice> _decodeStatusBreakdown(dynamic raw) {
    if (raw is! List) {
      return const <EnrollmentStatusSlice>[
        EnrollmentStatusSlice(status: EnrollmentStatus.enrolled, count: 0),
        EnrollmentStatusSlice(status: EnrollmentStatus.pending, count: 0),
        EnrollmentStatusSlice(status: EnrollmentStatus.rejected, count: 0),
      ];
    }
    return raw
        .whereType<JsonMap>()
        .map((item) {
          return EnrollmentStatusSlice(
            status: EnrollmentStatusX.fromJson(item['status']),
            count: _readInt(item['count'], fallback: 0),
          );
        })
        .toList(growable: false);
  }
}

int _readInt(dynamic value, {required int fallback}) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
