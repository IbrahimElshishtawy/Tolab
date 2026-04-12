import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tolabfci/app/app.dart';
import 'package:tolabfci/core/storage/preferences_service.dart';
import 'package:tolabfci/core/storage/secure_storage_service.dart';
import 'package:tolabfci/core/storage/storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _InMemorySecureStorageService extends SecureStorageService {
  _InMemorySecureStorageService() : super(null);

  final Map<String, String> _store = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }

  @override
  Future<String?> read(String key) async {
    return _store[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }
}

void main() {
  testWidgets('renders auth flow entrypoint', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final secureStorage = _InMemorySecureStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          preferencesServiceProvider.overrideWithValue(
            PreferencesService(preferences),
          ),
          secureStorageServiceProvider.overrideWithValue(secureStorage),
        ],
        child: const TolabApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
