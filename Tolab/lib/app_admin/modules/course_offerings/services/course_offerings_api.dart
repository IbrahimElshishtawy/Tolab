import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../models/course_offering_model.dart';

class CourseOfferingsApi {
  CourseOfferingsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<CourseOfferingsRemotePage> fetchOfferings({
    int page = 1,
    int perPage = 100,
    String? semester,
    String? sectionId,
    String? subjectId,
  }) {
    return _apiClient.get<CourseOfferingsRemotePage>(
      '/admin/course-offerings',
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (semester != null && semester.isNotEmpty) 'semester': semester,
        if (sectionId != null && sectionId.isNotEmpty) 'section_id': sectionId,
        if (subjectId != null && subjectId.isNotEmpty) 'subject_id': subjectId,
      },
      decoder: (json) {
        if (json is JsonMap && json['data'] is List) {
          final items = (json['data'] as List)
              .whereType<JsonMap>()
              .map(CourseOfferingModel.fromJson)
              .toList(growable: false);
          final metaMap = json['meta'] is JsonMap
              ? json['meta'] as JsonMap
              : const <String, dynamic>{};
          return CourseOfferingsRemotePage(
            items: items,
            totalItems: _readInt(metaMap['total'], fallback: items.length),
            totalPages: _readInt(metaMap['last_page'], fallback: 1),
          );
        }
        if (json is List) {
          final items = json
              .whereType<JsonMap>()
              .map(CourseOfferingModel.fromJson)
              .toList(growable: false);
          return CourseOfferingsRemotePage(
            items: items,
            totalItems: items.length,
            totalPages: 1,
          );
        }
        return const CourseOfferingsRemotePage(items: <CourseOfferingModel>[]);
      },
    );
  }

  Future<CourseOfferingModel> fetchOfferingDetails(String offeringId) {
    return _apiClient.get<CourseOfferingModel>(
      '/admin/course-offerings/$offeringId',
      decoder: (json) => CourseOfferingModel.fromJson(
        (json as JsonMap?) ?? const <String, dynamic>{},
      ),
    );
  }

  Future<CourseOfferingModel> createOffering(
    CourseOfferingUpsertPayload payload,
  ) {
    return _apiClient.post<CourseOfferingModel>(
      '/admin/course-offerings',
      data: payload.toJson(),
      decoder: (json) => CourseOfferingModel.fromJson(
        (json as JsonMap?) ?? const <String, dynamic>{},
      ),
    );
  }

  Future<CourseOfferingModel> updateOffering(
    String offeringId,
    CourseOfferingUpsertPayload payload,
  ) {
    return _apiClient.put<CourseOfferingModel>(
      '/admin/course-offerings/$offeringId',
      data: payload.toJson(),
      decoder: (json) => CourseOfferingModel.fromJson(
        (json as JsonMap?) ?? const <String, dynamic>{},
      ),
    );
  }

  Future<void> deleteOffering(String offeringId) {
    return _apiClient.delete<void>(
      '/admin/course-offerings/$offeringId',
      decoder: (_) {},
    );
  }
}

class CourseOfferingsRemotePage {
  const CourseOfferingsRemotePage({
    required this.items,
    this.totalItems = 0,
    this.totalPages = 1,
  });

  final List<CourseOfferingModel> items;
  final int totalItems;
  final int totalPages;
}

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
