import '../../../core/errors/app_exception.dart';
import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../models/schedule_models.dart';

class ScheduleApiService {
  ScheduleApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ScheduleEventItem>> fetchEvents({
    required ScheduleFilters filters,
  }) {
    return _apiClient.get<List<ScheduleEventItem>>(
      '/admin/schedule-events',
      queryParameters: <String, dynamic>{
        if (filters.departmentId != null) 'department': filters.departmentId,
        if (filters.yearId != null) 'academic_year': filters.yearId,
        if (filters.subjectId != null) 'subject_id': filters.subjectId,
        if (filters.instructorId != null) 'staff_id': filters.instructorId,
        if (filters.sectionId != null) 'section_id': filters.sectionId,
        'statuses[]': <String>[
          if (filters.showPlanned) ScheduleEventStatus.planned.apiValue,
          if (filters.showCompleted) ScheduleEventStatus.completed.apiValue,
        ],
        'types[]': filters.eventTypes.map((item) => item.apiValue).toList(),
      },
      decoder: _decodeEvents,
    );
  }

  Future<ScheduleEventItem> createEvent(ScheduleEventUpsertPayload payload) {
    final courseOfferingId = payload.courseOfferingId;
    if (courseOfferingId == null || courseOfferingId.isEmpty) {
      throw AppException(
        'A course offering is required before syncing a new schedule event.',
      );
    }

    return _apiClient.post<ScheduleEventItem>(
      '/admin/courses/$courseOfferingId/schedule-events',
      data: payload.toRemoteApiJson(),
      decoder: _decodeSingle,
    );
  }

  Future<ScheduleEventItem> updateEvent(
    String eventId,
    ScheduleEventUpsertPayload payload,
  ) {
    return _apiClient.put<ScheduleEventItem>(
      '/admin/schedule-events/$eventId',
      data: payload.toRemoteApiJson(),
      decoder: _decodeSingle,
    );
  }

  Future<void> deleteEvent(String eventId) {
    return _apiClient.delete<void>(
      '/admin/schedule-events/$eventId',
      decoder: (_) {},
    );
  }

  List<ScheduleEventItem> _decodeEvents(dynamic json) {
    if (json is List) {
      return json
          .whereType<JsonMap>()
          .map(ScheduleEventItem.fromJson)
          .toList(growable: false);
    }
    if (json is JsonMap && json['items'] is List) {
      return (json['items'] as List)
          .whereType<JsonMap>()
          .map(ScheduleEventItem.fromJson)
          .toList(growable: false);
    }
    if (json is JsonMap && json['data'] is List) {
      return (json['data'] as List)
          .whereType<JsonMap>()
          .map(ScheduleEventItem.fromJson)
          .toList(growable: false);
    }
    return const <ScheduleEventItem>[];
  }

  ScheduleEventItem _decodeSingle(dynamic json) {
    if (json is JsonMap) {
      return ScheduleEventItem.fromJson(json);
    }
    return ScheduleEventItem.fromJson(const <String, dynamic>{});
  }
}
