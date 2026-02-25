import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/main.dart';
import 'package:tolab_fci/redux/app_state.dart';
import 'package:tolab_fci/redux/reducers.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    final store = Store<AppState>(appReducer, initialState: AppState.initial());

    await tester.pumpWidget(App(store: store));

    // Pump to handle any initial frames
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);

    // To handle the SplashScreen timer if it's still there
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
