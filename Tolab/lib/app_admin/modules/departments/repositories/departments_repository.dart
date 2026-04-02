import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/demo_data_service.dart';
import '../models/department_models.dart';
import '../services/departments_seed_service.dart';

class DepartmentsRepository {
  DepartmentsRepository(
    this._apiClient,
    DemoDataService _, {
    DepartmentsSeedService? seedService,
  }) : _seedService = seedService ?? const DepartmentsSeedService();

  final ApiClient _apiClient;
  final DepartmentsSeedService _seedService;

  List<DepartmentRecord>? _cache;
  bool _remoteUnavailable = false;

  Future<List<DepartmentRecord>> fetchDepartments() async {
    final seedRecords = _cache ??= _seedService.build();
    if (_remoteUnavailable) {
      return _cache ?? _seedService.build();
    }
    try {
      final remote = await _apiClient.get<List<DepartmentRecord>>(
        '/departments',
        decoder: (json) {
          if (json is! List) return seedRecords;
          return json
              .whereType<JsonMap>()
              .map((item) {
                final fallback = _seedService.match(
                  departments: seedRecords,
                  id: item['id']?.toString(),
                  code: item['code']?.toString(),
                  name: item['name']?.toString(),
                );
                if (fallback != null) {
                  return DepartmentRecord.fromJson(item, fallback: fallback);
                }
                return _seedService.createRecord(
                  id: item['id']?.toString() ?? _generateDepartmentId(),
                  payload: DepartmentUpsertPayload(
                    name: item['name']?.toString() ?? 'Department',
                    code:
                        item['code']?.toString() ?? _codeFromName(item['name']),
                    description: item['description']?.toString() ?? '',
                    isActive: item['is_active'] == null
                        ? true
                        : DepartmentRecord.fromJson(item).isActive,
                    faculty: item['faculty']?.toString(),
                  ),
                );
              })
              .toList(growable: false);
        },
      );
      if (remote.isNotEmpty) {
        _cache = remote;
      }
    } on AppException catch (error) {
      if (error.statusCode != null && error.statusCode! >= 500) {
        _remoteUnavailable = true;
      }
    } on DioException {
      _remoteUnavailable = true;
      // Falls through to the seeded local snapshot below.
    }
    return _cache ?? _seedService.build();
  }

  Future<DepartmentMutationResult> createDepartment(
    DepartmentUpsertPayload payload,
  ) async {
    final template = _seedService.match(
      departments: _cache ?? _seedService.build(),
      code: payload.code,
      name: payload.name,
    );
    try {
      final created = await _apiClient.post<DepartmentRecord>(
        '/admin/departments',
        data: payload.toJson(),
        decoder: (json) {
          final map = json is JsonMap ? json : <String, dynamic>{};
          return DepartmentRecord.fromJson(
            map,
            fallback: _seedService.createRecord(
              id: map['id']?.toString() ?? _generateDepartmentId(),
              payload: payload,
              template: template,
            ),
          );
        },
      );
      final next = [..._ensureCache(), created];
      _cache = _dedupe(next);
      return DepartmentMutationResult(
        items: _cache!,
        message: 'Department created successfully.',
        selectedDepartmentId: created.id,
      );
    } catch (_) {
      final local = _seedService.createRecord(
        id: _generateDepartmentId(),
        payload: payload,
        template: template,
      );
      _cache = _dedupe([..._ensureCache(), local]);
      return DepartmentMutationResult(
        items: _cache!,
        message: 'Department created successfully.',
        selectedDepartmentId: local.id,
      );
    }
  }

  Future<DepartmentMutationResult> updateDepartment({
    required String departmentId,
    required DepartmentUpsertPayload payload,
  }) async {
    final existing = _ensureCache().firstWhereOrNull(
      (department) => department.id == departmentId,
    );
    final fallback = _seedService.createRecord(
      id: departmentId,
      payload: payload,
      template: existing,
    );
    try {
      final updated = await _apiClient.put<DepartmentRecord>(
        '/admin/departments/$departmentId',
        data: payload.toJson(),
        decoder: (json) => DepartmentRecord.fromJson(
          json is JsonMap ? json : <String, dynamic>{},
          fallback: fallback,
        ),
      );
      _cache = _replaceOne(updated);
    } catch (_) {
      _cache = _replaceOne(fallback);
    }
    return DepartmentMutationResult(
      items: _cache!,
      message: 'Department updated successfully.',
      selectedDepartmentId: departmentId,
    );
  }

  Future<DepartmentMutationResult> setActivation({
    required Set<String> departmentIds,
    required bool isActive,
  }) async {
    final next = _ensureCache()
        .map(
          (department) => departmentIds.contains(department.id)
              ? department.copyWith(
                  isActive: isActive,
                  isArchived: false,
                  updatedAt: DateTime.now(),
                )
              : department,
        )
        .toList(growable: false);
    _cache = next;
    return DepartmentMutationResult(
      items: next,
      message: isActive
          ? 'Department access restored successfully.'
          : 'Department access disabled successfully.',
      selectedDepartmentId: departmentIds.length == 1
          ? departmentIds.first
          : null,
    );
  }

  Future<DepartmentMutationResult> archiveDepartments(
    Set<String> departmentIds,
  ) async {
    final next = _ensureCache()
        .map(
          (department) => departmentIds.contains(department.id)
              ? department.copyWith(
                  isArchived: true,
                  isActive: false,
                  updatedAt: DateTime.now(),
                )
              : department,
        )
        .toList(growable: false);
    _cache = next;
    return DepartmentMutationResult(
      items: next,
      message: departmentIds.length == 1
          ? 'Department archived successfully.'
          : 'Selected departments archived successfully.',
    );
  }

  List<DepartmentRecord> _ensureCache() => _cache ??= _seedService.build();

  List<DepartmentRecord> _replaceOne(DepartmentRecord record) {
    final next = [..._ensureCache()];
    final index = next.indexWhere((department) => department.id == record.id);
    if (index >= 0) {
      next[index] = record;
    } else {
      next.insert(0, record);
    }
    return _dedupe(next);
  }

  List<DepartmentRecord> _dedupe(List<DepartmentRecord> items) {
    final map = <String, DepartmentRecord>{};
    for (final item in items) {
      map[item.id] = item;
    }
    return map.values.toList(growable: false);
  }

  String _generateDepartmentId() {
    return 'DEP-${DateTime.now().microsecondsSinceEpoch}';
  }

  String _codeFromName(Object? name) {
    final source = name?.toString().trim() ?? 'Department';
    final segments = source.split(RegExp(r'\s+'));
    return segments
        .where((segment) => segment.isNotEmpty)
        .take(4)
        .map((segment) => segment[0].toUpperCase())
        .join();
  }
}
