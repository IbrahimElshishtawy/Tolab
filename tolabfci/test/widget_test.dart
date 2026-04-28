import 'package:flutter_test/flutter_test.dart';
import 'package:tolabfci/app/tolab_student_prototype.dart';

void main() {
  testWidgets('renders Tolab student prototype splash', (tester) async {
    await tester.pumpWidget(const TolabStudentPrototypeApp());

    expect(find.text('Tolab'), findsOneWidget);
    expect(find.text('ابدأ التجربة'), findsOneWidget);
  });
}
