import '../../../core/errors/app_exception.dart';
import '../models/moderation_models.dart';
import '../services/moderation_api_service.dart';
import '../services/moderation_seed_service.dart';

class ModerationRepository {
  ModerationRepository(this._apiService, this._seedService);

  final ModerationApiService _apiService;
  final ModerationSeedService _seedService;

  ModerationDashboardBundle? _cachedBundle;
  bool _dashboardRoutesUnavailable = false;
  bool _actionRouteUnavailable = false;

  Future<ModerationDashboardBundle> fetchDashboard() async {
    if (_dashboardRoutesUnavailable) {
      return _fallbackBundle();
    }

    try {
      final seedBundle = _cachedBundle ?? _seedService.createBundle();
      final groups = await _apiService.fetchGroups();
      final posts = await _apiService.fetchPosts();
      final comments = await _apiService.fetchComments();
      final messages = await _apiService.fetchMessages();
      final reports = await _apiService.fetchReports();

      final bundle = _seedService.composeBundle(
        groups: groups,
        posts: posts,
        comments: comments,
        messages: messages,
        reports: reports,
        moderators: seedBundle.moderators,
        permissionScopes: seedBundle.permissionScopes,
        roleProfiles: seedBundle.roleProfiles,
      );
      _cachedBundle = bundle;
      return bundle;
    } catch (error) {
      if (_isMissingRoute(error)) {
        _dashboardRoutesUnavailable = true;
      }
      return _fallbackBundle();
    }
  }

  Future<ModerationMutationResult> performAction(
    ModerationActionCommand command,
  ) async {
    if (_dashboardRoutesUnavailable ||
        _actionRouteUnavailable ||
        (_cachedBundle?.isFallback ?? true)) {
      return _applyLocally(command);
    }

    try {
      await _apiService.submitAction(command);
      final bundle = await fetchDashboard();
      final result = ModerationMutationResult(
        bundle: bundle,
        message: '${command.actionType.label} completed successfully.',
      );
      _cachedBundle = result.bundle;
      return result;
    } catch (error) {
      if (_isMissingRoute(error)) {
        _actionRouteUnavailable = true;
      }

      if (_cachedBundle?.isFallback ?? true) {
        return _applyLocally(command);
      }

      if (error is AppException) rethrow;
      throw AppException(error.toString());
    }
  }

  Future<List<ModerationNotificationItem>> fetchNotifications() async {
    if (_dashboardRoutesUnavailable && _cachedBundle != null) {
      return _cachedBundle!.notifications;
    }
    final bundle = await fetchDashboard();
    return bundle.notifications;
  }

  ModerationDashboardBundle _fallbackBundle() {
    final fallback = (_cachedBundle?.isFallback ?? false)
        ? _cachedBundle!
        : _seedService.createBundle();
    _cachedBundle = fallback;
    return fallback;
  }

  ModerationMutationResult _applyLocally(ModerationActionCommand command) {
    final base = _cachedBundle ?? _seedService.createBundle();
    final nextBundle = _seedService.applyCommand(base, command);
    _cachedBundle = nextBundle;
    return ModerationMutationResult(
      bundle: nextBundle,
      message: '${command.actionType.label} applied to local moderation data.',
    );
  }

  bool _isMissingRoute(Object error) {
    return error is AppException &&
        error.statusCode == 404 &&
        error.message.trim().toLowerCase() == 'route not found.';
  }
}
