import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../models/upload_model.dart';

class UploadsService {
  UploadsService(this._apiClient, {Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final ApiClient _apiClient;
  final Connectivity _connectivity;

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result.any((status) => status != ConnectivityResult.none);
  }

  Future<UploadListBundle> fetchUploads({
    required UploadListFilters filters,
    required UploadListSort sort,
    required UploadPagination pagination,
  }) {
    return _apiClient.get<UploadListBundle>(
      '/admin/uploads',
      queryParameters: <String, dynamic>{
        'page': pagination.page,
        'per_page': pagination.perPage,
        ...filters.toQuery(),
        'sort_by': sort.field.apiValue,
        'sort_direction': sort.ascending ? 'asc' : 'desc',
      },
      decoder: _decodeBundle,
    );
  }

  Future<UploadItem> uploadFile(
    UploadLocalFile file, {
    required UploadAssignmentPayload assignment,
    required CancelToken cancelToken,
    void Function(double progress)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      ...assignment.toJson(),
      'file': file.bytes != null
          ? MultipartFile.fromBytes(
              file.bytes!,
              filename: file.name,
              contentType: DioMediaType.parse(file.mimeType),
            )
          : await MultipartFile.fromFile(
              file.path!,
              filename: file.name,
              contentType: DioMediaType.parse(file.mimeType),
            ),
    });

    return _apiClient.multipart<UploadItem>(
      '/admin/uploads',
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: (sent, total) {
        if (total <= 0) return;
        onProgress?.call(sent / total);
      },
      decoder: (json) =>
          UploadItem.fromJson((json as JsonMap?) ?? const <String, dynamic>{}),
    );
  }

  Future<void> deleteUpload(String uploadId) {
    return _apiClient.delete<void>('/admin/uploads/$uploadId', decoder: (_) {});
  }

  Future<void> assignUploads(
    Set<String> uploadIds,
    UploadAssignmentPayload payload,
  ) {
    return _apiClient.post<void>(
      '/admin/uploads',
      data: <String, dynamic>{
        'action': 'assign',
        'upload_ids': uploadIds.toList(growable: false),
        ...payload.toJson(),
      },
      decoder: (_) {},
    );
  }

  Future<UploadPreviewData> fetchPreview(UploadItem item) {
    return _apiClient.get<UploadPreviewData>(
      '/admin/uploads/${item.id}/preview',
      decoder: (json) => UploadPreviewData.fromJson(
        (json as JsonMap?) ?? const <String, dynamic>{},
        item,
      ),
    );
  }

  UploadListBundle _decodeBundle(dynamic json) {
    if (json is JsonMap && json['items'] is List) {
      final items = (json['items'] as List)
          .whereType<JsonMap>()
          .map(UploadItem.fromJson)
          .toList(growable: false);
      final lookups = json['lookups'] is JsonMap
          ? UploadLookups.fromJson(json['lookups'] as JsonMap)
          : const UploadLookups();
      return UploadListBundle(
        items: items,
        pagination: _decodePagination(
          json['pagination'],
          fallbackTotalItems: items.length,
        ),
        lookups: lookups,
        totalStorageBytes: _readInt(
          json['total_storage_bytes'] ?? json['storage_bytes'],
          fallback: items.fold<int>(0, (sum, item) => sum + item.sizeBytes),
        ),
      );
    }

    if (json is JsonMap && json['data'] is List) {
      final items = (json['data'] as List)
          .whereType<JsonMap>()
          .map(UploadItem.fromJson)
          .toList(growable: false);
      return UploadListBundle(
        items: items,
        pagination: _decodePagination(
          json['meta'],
          fallbackTotalItems: items.length,
        ),
        lookups: json['lookups'] is JsonMap
            ? UploadLookups.fromJson(json['lookups'] as JsonMap)
            : const UploadLookups(),
        totalStorageBytes: _readInt(
          json['total_storage_bytes'] ?? json['storage_bytes'],
          fallback: items.fold<int>(0, (sum, item) => sum + item.sizeBytes),
        ),
      );
    }

    if (json is List) {
      final items = json
          .whereType<JsonMap>()
          .map(UploadItem.fromJson)
          .toList(growable: false);
      return UploadListBundle(
        items: items,
        pagination: UploadPagination(
          totalItems: items.length,
          totalPages: items.isEmpty ? 1 : 1,
        ),
        lookups: const UploadLookups(),
        totalStorageBytes: items.fold<int>(
          0,
          (sum, item) => sum + item.sizeBytes,
        ),
      );
    }

    return const UploadListBundle(
      items: <UploadItem>[],
      pagination: UploadPagination(),
      lookups: UploadLookups(),
      totalStorageBytes: 0,
    );
  }

  UploadPagination _decodePagination(
    dynamic raw, {
    required int fallbackTotalItems,
  }) {
    if (raw is JsonMap) {
      return UploadPagination(
        page: _readInt(raw['page'] ?? raw['current_page'], fallback: 1),
        perPage: _readInt(raw['per_page'], fallback: 12),
        totalItems: _readInt(
          raw['total'] ?? raw['total_items'],
          fallback: fallbackTotalItems,
        ),
        totalPages: _readInt(
          raw['last_page'] ?? raw['total_pages'],
          fallback: fallbackTotalItems == 0 ? 1 : 1,
        ),
      );
    }
    return UploadPagination(
      totalItems: fallbackTotalItems,
      totalPages: fallbackTotalItems == 0 ? 1 : 1,
    );
  }
}

int _readInt(dynamic value, {required int fallback}) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
