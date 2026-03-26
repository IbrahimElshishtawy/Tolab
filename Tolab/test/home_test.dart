import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/app/core/services/demo_data_service.dart';
import 'package:tolab_fci/app/modules/dashboard/presentation/dashboard_screen.dart';
import 'package:tolab_fci/app/modules/dashboard/state/dashboard_state.dart';
import 'package:tolab_fci/app/state/app_reducer.dart';
import 'package:tolab_fci/app/state/app_state.dart';

void main() {
  testWidgets('dashboard screen renders seeded metrics', (tester) async {
    final store = Store<AppState>(appReducer, initialState: AppState.initial());

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
      ),
    );
    store.dispatch(
      DashboardLoadedAction(const DemoDataService().dashboardBundle()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('University Overview'), findsOneWidget);
    expect(find.text('Active students'), findsOneWidget);
  });
}
