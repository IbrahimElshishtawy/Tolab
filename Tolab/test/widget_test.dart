import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/app/modules/settings/presentation/settings_screen.dart';
import 'package:tolab_fci/app/state/app_reducer.dart';
import 'package:tolab_fci/app/state/app_state.dart';

void main() {
  testWidgets('settings screen exposes security section', (tester) async {
    final store = Store<AppState>(appReducer, initialState: AppState.initial());

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
  });
}
