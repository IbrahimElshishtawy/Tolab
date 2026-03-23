import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/features/home/presentation/screens/doctor_home_screen.dart';
import 'package:tolab_fci/features/home/presentation/screens/it_home_screen.dart';
import 'package:tolab_fci/features/home/presentation/screens/ta_home_screen.dart';
import 'package:tolab_fci/redux/app_state.dart';
import 'package:tolab_fci/redux/reducers.dart';

void main() {
  late Store<AppState> store;

  setUp(() {
    store = Store<AppState>(appReducer, initialState: AppState.initial());
  });

  Widget createTestWidget(Widget child) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(home: child),
    );
  }

  testWidgets('DoctorHomeScreen displays correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget(const DoctorHomeScreen()));

    expect(find.text('My Courses'), findsOneWidget);
    expect(find.text('Doctor Actions'), findsOneWidget);
  });

  testWidgets('TaHomeScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const TaHomeScreen()));

    expect(find.text('Teaching Assistant'), findsOneWidget);
    expect(find.text('Upcoming Lab Sessions'), findsOneWidget);
    expect(find.text('TA Dashboard'), findsOneWidget);
  });

  testWidgets('ItHomeScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const ItHomeScreen()));

    expect(find.text('IT Administrator'), findsOneWidget);
    expect(find.text('System Status: Healthy'), findsOneWidget);
    expect(find.text('Admin Panel'), findsOneWidget);
  });
}
