import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_api_service.dart';
import '../services/dashboard_seed_service.dart';

class DashboardRepository {
  DashboardRepository(this._apiService, this._seedService);

  final DashboardApiService _apiService;
  final DashboardSeedService _seedService;

  Future<DashboardBundle> fetchDashboard({
    required DashboardFilters filters,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _apiService.fetchDashboard(
        filters: filters,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      if (error.type == DioExceptionType.cancel) rethrow;
      return _seedService.buildBundle(filters: filters);
    } on AppException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) rethrow;
      return _seedService.buildBundle(filters: filters);
    } catch (_) {
      return _seedService.buildBundle(filters: filters);
    }
  }

  Future<List<DashboardDirectoryEntry>> searchDirectory({
    required String query,
    required DashboardSearchScope scope,
    CancelToken? cancelToken,
  }) async {
    try {
      final remote = await _apiService.searchDirectory(
        query: query,
        scope: scope,
        cancelToken: cancelToken,
      );
      if (remote.isNotEmpty) {
        return remote;
      }
    } on DioException catch (error) {
      if (error.type == DioExceptionType.cancel) rethrow;
    } on AppException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) rethrow;
    } catch (_) {}

    return _seedService.searchDirectory(query: query, scope: scope);
  }

  Stream<DashboardRealtimeSignal> watchRealtimeSignals({
    String? accessToken,
    String? userId,
  }) {
    return _apiService.watchRealtimeSignals(
      accessToken: accessToken,
      userId: userId,
    );
  }
}
