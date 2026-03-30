import '../../../core/errors/app_exception.dart';
import '../models/moderation_models.dart';
import '../services/moderation_api_service.dart';
import '../services/moderation_seed_service.dart';

class ModerationRepository {
  ModerationRepository(this._apiService, this._seedService);

  final ModerationApiService _apiService;
  final ModerationSeedService _seedService;

  ModerationDashboardBundle? _cachedBundle;

  Future<ModerationDashboardBundle> fetchDashboard() async {
    try {
      final seedBundle = _cachedBundle ?? _seedService.createBundle();
      final responses = await Future.wait<dynamic>([
        _apiService.fetchGroups(),
        _apiService.fetchPosts(),
        _apiService.fetchComments(),
        _apiService.fetchMessages(),
        _apiService.fetchReports(),
      ]);

      final bundle = _seedService.composeBundle(
        groups: responses[0] as List<ModerationGroup>,
        posts: responses[1] as List<ModerationPost>,
        comments: responses[2] as List<ModerationComment>,
        messages: responses[3] as List<ModerationMessage>,
        reports: responses[4] as List<ModerationReport>,
        moderators: seedBundle.moderators,
        permissionScopes: seedBundle.permissionScopes,
        roleProfiles: seedBundle.roleProfiles,
      );
      _cachedBundle = bundle;
      return bundle;
    } catch (_) {
      final fallback = (_cachedBundle?.isFallback ?? false)
          ? _cachedBundle!
          : _seedService.createBundle();
      _cachedBundle = fallback;
      return fallback;
    }
  }

  Future<ModerationMutationResult> performAction(
    ModerationActionCommand command,
  ) async {
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
      if (_cachedBundle?.isFallback ?? true) {
        final base = _cachedBundle ?? _seedService.createBundle();
        final nextBundle = _seedService.applyCommand(base, command);
        _cachedBundle = nextBundle;
        return ModerationMutationResult(
          bundle: nextBundle,
          message:
              '${command.actionType.label} applied to local moderation data.',
        );
      }

      if (error is AppException) rethrow;
      throw AppException(error.toString());
    }
  }

  Future<List<ModerationNotificationItem>> fetchNotifications() async {
    final bundle = await fetchDashboard();
    return bundle.notifications;
  }
}
