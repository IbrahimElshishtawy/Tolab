import 'package:flutter_test/flutter_test.dart';
import 'package:tolab_fci/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    final store = createStore();
    await tester.pumpWidget(App(store: store));
    expect(find.byType(App), findsOneWidget);
  });
}
