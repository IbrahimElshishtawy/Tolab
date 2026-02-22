import 'package:flutter_test/flutter_test.dart';
import 'package:tolab_educator/core/validators/app_validators.dart';

void main() {
  group('AppValidators', () {
    test('validateEmail returns error for invalid format', () {
      expect(AppValidators.validateEmail('invalid'), isNotNull);
      expect(AppValidators.validateEmail('user@domain.com'), isNull);
    });

    test('validatePassword returns error for short password', () {
      expect(AppValidators.validatePassword('123'), isNotNull);
      expect(AppValidators.validatePassword('password123'), isNull);
    });
  });
}
