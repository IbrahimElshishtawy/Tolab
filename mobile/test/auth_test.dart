import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/features/auth/presentation/screens/login_screen.dart';
import 'package:tolab_fci/features/auth/presentation/widgets/Login_Card.dart';
import 'package:tolab_fci/redux/state/app_state.dart';
import 'package:tolab_fci/redux/reducers/root_reducer.dart';

void main() {
  testWidgets('LoginScreen shows email and password fields', (WidgetTester tester) async {
    final store = Store<AppState>(appReducer, initialState: AppState.initial());

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.byType(TextField), findsWidgets);
    expect(find.text('تسجيل الدخول'), findsNWidgets(2));
  });
}
