import '../../../core/errors/app_exception.dart';
import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/notification_models.dart';

class NotificationsRepository {
  NotificationsRepository(this._apiClient, this._demoDataService);

  final ApiClient _apiClient;
  final DemoDataService _demoDataService;

  List<AdminNotification>? _cache;

  Future<List<AdminNotification>> fetchNotifications({int perPage = 60}) async {
    final seed = _cache ??= _demoDataService.notifications();

    try {
      final remote = await _apiClient.get<List<AdminNotification>>(
        '/notifications',
        queryParameters: {'per_page': perPage},
        decoder: (json) => _decodeNotificationList(json),
      );
      if (remote.isNotEmpty) {
        _cache = _sort(remote);
      }
    } catch (_) {
      // Falls through to the locally cached snapshot below.
    }

    return List<AdminNotification>.unmodifiable(_cache ?? seed);
  }

  Future<void> markRead(String notificationId) async {
    _cache = _sort([
      for (final item in _cache ?? _demoDataService.notifications())
        if (item.id == notificationId) item.markRead() else item,
    ]);

    try {
      await _apiClient.patch<void>(
        '/notifications/$notificationId/read',
        decoder: (_) {},
      );
    } catch (_) {}
  }

  Future<void> markAllRead(Iterable<String> notificationIds) async {
    final ids = notificationIds.toSet();
    if (ids.isEmpty) return;

    _cache = _sort([
      for (final item in _cache ?? _demoDataService.notifications())
        if (ids.contains(item.id)) item.markRead() else item,
    ]);

    for (final id in ids) {
      try {
        await _apiClient.patch<void>(
          '/notifications/$id/read',
          decoder: (_) {},
        );
      } catch (_) {}
    }
  }

  Future<AdminNotification> broadcast({
    required String title,
    required String body,
    required AdminNotificationCategory category,
    required NotificationAudienceType audienceType,
    required NotificationTone tone,
    String? audienceLabel,
    DateTime? scheduledAt,
    String? refType,
    String? refId,
  }) async {
    final payload = {
      'title': title,
      'body': body,
      'type': category.backendType,
      'audience_type': audienceType.backendValue,
      'tone': tone.backendValue,
      if (audienceLabel != null && audienceLabel.isNotEmpty)
        'audience': audienceLabel,
      if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
      if (refType != null && refType.isNotEmpty) 'ref_type': refType,
      if (refId != null && refId.isNotEmpty) 'ref_id': refId,
    };

    final fallbackNotification = AdminNotification(
      id: 'LOCAL-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      category: category,
      createdAt: DateTime.now(),
      isRead: false,
      rawType: category.backendType,
      refType: refType,
      refId: refId,
      source: 'local-fallback',
      audienceLabel: audienceLabel,
      audienceType: audienceType,
      tone: tone,
      scheduledAt: scheduledAt,
    );

    try {
      return await _apiClient.post<AdminNotification>(
        '/admin/notifications/broadcast',
        data: payload,
        decoder: (json) {
          if (json is JsonMap && json['data'] is JsonMap) {
            return AdminNotification.fromJson(json['data'] as JsonMap);
          }
          if (json is JsonMap) {
            return AdminNotification.fromJson({
              ...json,
              ...payload,
              'source': 'api',
            });
          }
          return fallbackNotification.copyWith(source: 'api');
        },
      );
    } catch (_) {
      return fallbackNotification;
    }
  }

  void cacheIncoming(AdminNotification notification) {
    _cache = _sort(
      _upsert(_cache ?? _demoDataService.notifications(), notification),
    );
  }

  List<AdminNotification> _decodeNotificationList(dynamic json) {
    final resolved = switch (json) {
      List<dynamic>() => json,
      JsonMap() when json['data'] is List<dynamic> =>
        json['data'] as List<dynamic>,
      JsonMap() when json['items'] is List<dynamic> =>
        json['items'] as List<dynamic>,
      _ => const <dynamic>[],
    };

    return _sort(
      resolved
          .whereType<JsonMap>()
          .map(AdminNotification.fromJson)
          .toList(growable: false),
    );
  }

  List<AdminNotification> _upsert(
    List<AdminNotification> items,
    AdminNotification notification,
  ) {
    final next = <String, AdminNotification>{
      for (final item in items) item.id: item,
      notification.id: notification,
    };
    return next.values.toList(growable: false);
  }

  List<AdminNotification> _sort(List<AdminNotification> items) {
    final next = [...items]
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return List<AdminNotification>.unmodifiable(next);
  }
}
