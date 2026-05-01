import 'package:flutter_test/flutter_test.dart';
import 'package:tolabfci/app/app.dart';

void main() {
  testWidgets('renders Tolab student prototype splash', (tester) async {
    await tester.pumpWidget(const TolabApp());

    expect(find.text('Tola'), findsOneWidget);
    expect(find.text('ابدأ التجربة'), findsOneWidget);
  });
}
