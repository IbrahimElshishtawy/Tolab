import 'package:dio/dio.dart';

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
      '/admin/dashboard',
      queryParameters: filters.toQueryParameters(),
      cancelToken: cancelToken,
      decoder: (json) {
        final payload = json is JsonMap ? json : <String, dynamic>{};
        return DashboardBundle.fromJson(
          payload,
          fallbackFilters: filters,
        );
      },
    );
  }
}
