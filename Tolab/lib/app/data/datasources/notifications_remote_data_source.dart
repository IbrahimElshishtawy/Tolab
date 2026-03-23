import '../../core/constants/api_constants.dart';
import '../dto/pagination_query_dto.dart';
import '../models/notification_item_model.dart';
import '../models/paginated_response.dart';
import 'base_remote_data_source.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._remote);

  final BaseRemoteDataSource _remote;

  Future<PaginatedResponse<NotificationItemModel>> list(
    PaginationQueryDto query,
  ) async {
    final envelope = await _remote
        .get<PaginatedResponse<NotificationItemModel>>(
          ApiConstants.notifications,
          queryParameters: query.toQuery(),
          parser: (raw) => PaginatedResponse<NotificationItemModel>.fromLaravel(
            raw,
            NotificationItemModel.fromJson,
          ),
        );
    return envelope.data!;
  }
}
