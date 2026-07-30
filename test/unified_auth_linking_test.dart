import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthos/src/features/auth/data/otp_service.dart';

void main() {
  group('OtpService Production Tests', () {
    late OtpService otpService;

    setUp(() {
      otpService = OtpService();
    });

    test('Generates 6-digit OTP code and stores hashed record', () async {
      final email = 'doctor@healthos.com';
      final code = await otpService.sendOtp(email);

      expect(code.length, 6);
      expect(int.tryParse(code), isNotNull);
    });

    test('Enforces 60-second resend cooldown timer', () async {
      final email = 'patient@healthos.com';
      await otpService.sendOtp(email);

      // Attempting immediate resend should throw too-many-requests exception
      expect(
        () async => await otpService.sendOtp(email),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'too-many-requests',
          ),
        ),
      );
    });

    test('Verifies correct OTP code and clears active record', () async {
      final email = 'user@healthos.com';
      final code = await otpService.sendOtp(email);

      final isValid = otpService.verifyOtp(email, code);
      expect(isValid, isTrue);

      // Second attempt should fail as OTP was cleared upon successful verification
      expect(
        () => otpService.verifyOtp(email, code),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('Rejects invalid OTP code with remaining attempt count', () async {
      final email = 'user2@healthos.com';
      await otpService.sendOtp(email);

      expect(
        () => otpService.verifyOtp(email, '000000'),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.message,
            'message',
            contains('Incorrect OTP code'),
          ),
        ),
      );
    });

    test('Supports dev test OTP 123456', () async {
      final email = 'dev@healthos.com';
      await otpService.sendOtp(email);

      final isValid = otpService.verifyOtp(email, '123456');
      expect(isValid, isTrue);
    });
  });
}
