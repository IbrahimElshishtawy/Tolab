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
    bool preferRemote = true,
  }) async {
    final seededBundle = _seedService.buildBundle(filters: filters);
    if (!preferRemote) {
      return seededBundle;
    }

    try {
      final remoteBundle = await _apiService.fetchDashboard(
        filters: filters,
        cancelToken: cancelToken,
      );
      return _mergeBundles(seeded: seededBundle, remote: remoteBundle);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.cancel) rethrow;
      return seededBundle;
    } on AppException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) rethrow;
      return seededBundle;
    } catch (_) {
      return seededBundle;
    }
  }

  Future<List<DashboardDirectoryEntry>> searchDirectory({
    required String query,
    required DashboardSearchScope scope,
    CancelToken? cancelToken,
    bool preferRemote = true,
  }) async {
    if (!preferRemote) {
      return _seedService.searchDirectory(query: query, scope: scope);
    }

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

  DashboardBundle _mergeBundles({
    required DashboardBundle seeded,
    required DashboardBundle remote,
  }) {
    return DashboardBundle(
      filters: remote.filters,
      stats: remote.stats.isNotEmpty ? remote.stats : seeded.stats,
      trendPoints: remote.trendPoints.isNotEmpty
          ? remote.trendPoints
          : seeded.trendPoints,
      departmentStats: remote.departmentStats.isNotEmpty
          ? remote.departmentStats
          : seeded.departmentStats,
      taskBreakdown: remote.taskBreakdown.isNotEmpty
          ? remote.taskBreakdown
          : seeded.taskBreakdown,
      directoryEntries: remote.directoryEntries.isNotEmpty
          ? remote.directoryEntries
          : seeded.directoryEntries,
      activityRows: remote.activityRows.isNotEmpty
          ? remote.activityRows
          : seeded.activityRows,
      alerts: remote.alerts.isNotEmpty ? remote.alerts : seeded.alerts,
      quickActions: remote.quickActions.isNotEmpty
          ? remote.quickActions
          : seeded.quickActions,
      sourceLabel: remote.sourceLabel,
      refreshedAt: remote.refreshedAt,
      isFallback: remote.isFallback,
    );
  }
}
