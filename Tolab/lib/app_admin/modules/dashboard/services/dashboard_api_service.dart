import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/config/app_config.dart';
import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../models/dashboard_models.dart';

class DashboardApiService {
  DashboardApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardBundle> fetchDashboard({
    required DashboardFilters filters,
    CancelToken? cancelToken,
  }) {
    return _apiClient.get<DashboardBundle>(
      '/admin/overview',
      queryParameters: filters.toQueryParameters(),
      cancelToken: cancelToken,
      decoder: (json) => _decodeDashboardBundle(json, filters: filters),
    );
  }

  Future<List<DashboardDirectoryEntry>> searchDirectory({
    required String query,
    required DashboardSearchScope scope,
    CancelToken? cancelToken,
  }) {
    return _apiClient.get<List<DashboardDirectoryEntry>>(
      '/admin/users',
      queryParameters: {
        'q': query,
        'per_page': 12,
        if (scope.backendRole != null) 'role': scope.backendRole,
      },
      cancelToken: cancelToken,
      decoder: (json) => _decodeDirectoryEntries(json, scope: scope),
    );
  }

  Stream<DashboardRealtimeSignal> watchRealtimeSignals({
    String? accessToken,
    String? userId,
  }) async* {
    final url = AppConfig.dashboardSocketUrl.trim();
    if (url.isEmpty) {
      yield* _fallbackRealtimeSignals();
      return;
    }

    WebSocketChannel? channel;
    try {
      final baseUri = Uri.parse(url);
      final uri = baseUri.replace(
        queryParameters: {
          ...baseUri.queryParameters,
          if (accessToken != null && accessToken.isNotEmpty)
            'token': accessToken,
          if (userId != null && userId.isNotEmpty) 'user_id': userId,
        },
      );

      channel = WebSocketChannel.connect(uri);
      await channel.ready;
      yield DashboardRealtimeSignal.heartbeat('socket');

      await for (final event in channel.stream) {
        final signal = DashboardRealtimeSignal.fromSocketEvent(event);
        if (signal != null) {
          yield signal;
        }
      }
    } catch (_) {
      yield* _fallbackRealtimeSignals();
    } finally {
      await channel?.sink.close();
    }
  }

  List<DashboardDirectoryEntry> _decodeDirectoryEntries(
    dynamic json, {
    required DashboardSearchScope scope,
  }) {
    final resolved = switch (json) {
      List<dynamic>() => json,
      JsonMap() when json['data'] is List<dynamic> =>
        json['data'] as List<dynamic>,
      JsonMap() when json['items'] is List<dynamic> =>
        json['items'] as List<dynamic>,
      _ => const <dynamic>[],
    };

    return resolved
        .whereType<JsonMap>()
        .where(
          (item) =>
              (item['role']?.toString().trim().toUpperCase() ?? '') != 'ADMIN',
        )
        .map(DashboardDirectoryEntry.fromJson)
        .where((entry) => entry.matchesScope(scope))
        .toList(growable: false);
  }

  Stream<DashboardRealtimeSignal> _fallbackRealtimeSignals() {
    return Stream<DashboardRealtimeSignal>.periodic(
      const Duration(seconds: 18),
      (_) => DashboardRealtimeSignal.heartbeat('polling'),
    );
  }

  DashboardBundle _decodeDashboardBundle(
    dynamic json, {
    required DashboardFilters filters,
  }) {
    final payload = json is JsonMap ? json : <String, dynamic>{};
    final normalized = _looksLikeAdminOverview(payload)
        ? _mapAdminOverviewPayload(payload, filters: filters)
        : payload;
    return DashboardBundle.fromJson(normalized, fallbackFilters: filters);
  }

  bool _looksLikeAdminOverview(JsonMap payload) {
    return payload.containsKey('staff') ||
        payload.containsKey('active_staff') ||
        payload.containsKey('departments') ||
        payload.containsKey('permissions');
  }

  JsonMap _mapAdminOverviewPayload(
    JsonMap payload, {
    required DashboardFilters filters,
  }) {
    return <String, dynamic>{
      'filters': {'range': filters.timeRange.backendValue},
      'stats': [
        {
          'id': 'staff',
          'label': 'Staff members',
          'value': '${payload['staff'] ?? 0}',
          'delta_label': 'Live backend count',
          'delta_value': 0,
          'caption': 'Doctors and assistants currently in the system.',
          'tone': 'primary',
        },
        {
          'id': 'active_staff',
          'label': 'Active staff',
          'value': '${payload['active_staff'] ?? 0}',
          'delta_label': 'Accounts ready to work',
          'delta_value': 0,
          'caption': 'Staff accounts marked active in the control panel.',
          'tone': 'success',
        },
        {
          'id': 'departments',
          'label': 'Departments',
          'value': '${payload['departments'] ?? 0}',
          'delta_label': 'Academic structure',
          'delta_value': 0,
          'caption': 'Departments available across the university.',
          'tone': 'info',
        },
        {
          'id': 'permissions',
          'label': 'Permissions',
          'value': '${payload['permissions'] ?? 0}',
          'delta_label': 'Access rules loaded',
          'delta_value': 0,
          'caption': 'Permission records currently configured.',
          'tone': 'warning',
        },
      ],
      'source_label': 'Admin overview API',
      'refreshed_at': DateTime.now().toIso8601String(),
      'is_fallback': false,
    };
  }
}
