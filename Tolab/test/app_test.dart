import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/app/app.dart';
import 'package:tolab_fci/app/state/app_reducer.dart';
import 'package:tolab_fci/app/state/app_state.dart';

void main() {
  testWidgets('app boots into splash shell before auth resolves', (
    tester,
  ) async {
    final store = Store<AppState>(appReducer, initialState: AppState.initial());

    await tester.pumpWidget(TolabAdminApp(store: store));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tolab Admin Panel'), findsOneWidget);
  });
}
