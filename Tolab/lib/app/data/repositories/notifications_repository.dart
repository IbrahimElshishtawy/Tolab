import '../../core/utils/result.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../dto/pagination_query_dto.dart';
import '../models/notification_item_model.dart';
import '../models/paginated_response.dart';
import 'base_repository.dart';

class NotificationsRepository with BaseRepository {
  NotificationsRepository(this._remote);

  final NotificationsRemoteDataSource _remote;

  Future<Result<PaginatedResponse<NotificationItemModel>>> list(
    PaginationQueryDto query,
  ) => guard(() => _remote.list(query));
}
