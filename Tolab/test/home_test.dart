import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/app_admin/modules/dashboard/presentation/dashboard_screen.dart';
import 'package:tolab_fci/app_admin/modules/dashboard/services/dashboard_seed_service.dart';
import 'package:tolab_fci/app_admin/modules/dashboard/models/dashboard_models.dart';
import 'package:tolab_fci/app_admin/modules/dashboard/state/dashboard_state.dart';
import 'package:tolab_fci/app_admin/state/app_reducer.dart';
import 'package:tolab_fci/app_admin/state/app_state.dart';

void main() {
  testWidgets('dashboard screen renders seeded metrics', (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = Store<AppState>(appReducer, initialState: AppState.initial());
    final seededBundle = const DashboardSeedService().buildBundle(
      filters: const DashboardFilters(),
    );

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
      ),
    );
    store.dispatch(DashboardLoadedAction(seededBundle));
    await tester.pumpAndSettle();

    expect(find.text('Search directory'), findsOneWidget);
  });
}
