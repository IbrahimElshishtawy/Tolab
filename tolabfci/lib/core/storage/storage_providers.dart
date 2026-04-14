import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_service.dart';
import 'secure_storage_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) =>
      throw UnimplementedError('preferencesServiceProvider must be overridden'),
);

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => throw UnimplementedError(
    'secureStorageServiceProvider must be overridden',
  ),
);
