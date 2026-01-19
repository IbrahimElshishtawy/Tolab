import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/app/app.dart';
import 'package:tolab_fci/redux/state/app_state.dart';
import 'package:tolab_fci/redux/reducers/root_reducer.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    final store = Store<AppState>(appReducer, initialState: AppState.initial());

    await tester.pumpWidget(App(store: store));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
