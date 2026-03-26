import '../../../config/admin_config.dart';
import '../../../core/network/api_exception_mapper.dart';
import '../../datasources/admin/admin_resource_remote_data_source.dart';
import '../../dto/pagination_query_dto.dart';
import '../../models/admin_models.dart';
import '../../models/admin_seed_data.dart';

class NotificationsRepository {
  NotificationsRepository(this._remoteDataSource);

  final AdminResourceRemoteDataSource _remoteDataSource;
  List<AdminNotificationModel>? _cache;

  List<AdminNotificationModel> get _items =>
      _cache ??= List<AdminNotificationModel>.from(AdminSeedData.notifications);

  Future<List<AdminNotificationModel>> getNotifications() async {
    if (AdminConfig.useMockData) return _items;
    try {
      final page = await _remoteDataSource.getList<AdminNotificationModel>(
        endpoint: '/admin/notifications',
        query: const PaginationQueryDto(),
        parser: AdminNotificationModel.fromJson,
      );
      return page.items;
    } catch (error) {
      throw ApiExceptionMapper.map(error);
    }
  }

  Future<void> markAllRead() async {
    if (AdminConfig.useMockData) {
      _cache = _items.map((item) => item.copyWith(isRead: true)).toList();
      return;
    }
  }

  Future<void> broadcast({
    required String title,
    required String body,
    required String audience,
  }) async {
    if (AdminConfig.useMockData) {
      _items.insert(
        0,
        AdminNotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          body: body,
          audience: audience,
          createdAt: DateTime.now(),
          isRead: false,
          status: 'sent',
        ),
      );
      return;
    }
  }
}
