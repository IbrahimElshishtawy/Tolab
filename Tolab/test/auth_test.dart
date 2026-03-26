import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/app/modules/auth/presentation/login_screen.dart';
import 'package:tolab_fci/app/shared/models/auth_models.dart';
import 'package:tolab_fci/app/state/app_reducer.dart';
import 'package:tolab_fci/app/state/app_state.dart';

void main() {
  testWidgets('login screen renders seeded admin hint', (tester) async {
    final store = Store<AppState>(appReducer, initialState: AppState.initial());

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Admin Sign In'), findsOneWidget);
    expect(find.textContaining('admin@tolab.edu'), findsWidgets);
  });

  test('auth models parse backend camelCase payloads', () {
    final tokens = AuthTokens.fromJson(const {
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
    });
    final user = UserProfile.fromJson(const {
      'id': 7,
      'username': 'Super Admin',
      'email': 'admin@tolab.edu',
      'role': 'admin',
      'is_active': true,
    });

    expect(tokens.accessToken, 'access-token');
    expect(tokens.refreshToken, 'refresh-token');
    expect(user.name, 'Super Admin');
    expect(user.status, 'active');
  });
}
