import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/preferences_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/storage/storage_providers.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final secureStorage = SecureStorageService();
  final preferencesService = PreferencesService(sharedPreferences);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        preferencesServiceProvider.overrideWithValue(preferencesService),
        secureStorageServiceProvider.overrideWithValue(secureStorage),
      ],
      child: const TolabApp(),
    ),
  );
}
