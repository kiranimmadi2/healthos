import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HealthIdGenerator', () {
    test('generates valid health ID', () {
      final healthId = HealthIdGenerator.generate();

      expect(HealthIdGenerator.isValid(healthId), true);
      expect(healthId.startsWith('HOS-'), true);
      expect(healthId.length, 13);
    });

    test('generates unique IDs', () {
      final ids = List.generate(100, (_) => HealthIdGenerator.generate());
      final uniqueIds = ids.toSet();

      expect(uniqueIds.length, ids.length);
    });

    test('validates correct formats', () {
      expect(HealthIdGenerator.isValid('HOS-2024-AB12'), true);
      expect(HealthIdGenerator.isValid('HOS-2025-XY99'), true);
    });

    test('rejects invalid formats', () {
      expect(HealthIdGenerator.isValid(''), false);
      expect(HealthIdGenerator.isValid('HOS-2024'), false);
      expect(HealthIdGenerator.isValid('ABC-2024-AB12'), false);
      expect(HealthIdGenerator.isValid('HOS-20-AB12'), false);
      expect(HealthIdGenerator.isValid('hos-2024-ab12'), false);
    });
  });

  group('Validators', () {
    test('validates phone numbers', () {
      expect(Validators.validatePhone('+919876543210'), isNull);
      expect(Validators.validatePhone('9876543210'), isNull);
      expect(Validators.validatePhone(''), isNotNull);
      expect(Validators.validatePhone('123'), isNotNull);
    });

    test('validates email addresses', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid'), isNotNull);
    });

    test('validates health IDs', () {
      expect(Validators.validateHealthId('HOS-2024-AB12'), isNull);
      expect(Validators.validateHealthId(''), isNotNull);
      expect(Validators.validateHealthId('invalid'), isNotNull);
    });

    test('validates OTP', () {
      expect(Validators.validateOtp('123456'), isNull);
      expect(Validators.validateOtp(''), isNotNull);
      expect(Validators.validateOtp('12345'), isNotNull);
      expect(Validators.validateOtp('abcdef'), isNotNull);
    });
  });
}
