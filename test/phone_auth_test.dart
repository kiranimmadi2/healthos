import 'dart:io';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthos/src/features/auth/data/auth_repository.dart';
import 'package:healthos/src/features/auth/data/phone_auth_service.dart';

void main() {
  group('toE164', () {
    test('prefixes the dial code for a national number', () {
      expect(toE164('9876543210', '+91'), '+919876543210');
      expect(toE164('5551234567', '+1'), '+15551234567');
    });

    test('strips a national trunk zero', () {
      // "098765 43210" must not become "+910987654321".
      expect(toE164('09876543210', '+91'), '+919876543210');
      expect(toE164('007700900123', '+44'), '+447700900123');
    });

    test('strips spaces, dashes and brackets', () {
      expect(toE164('98765 43210', '+91'), '+919876543210');
      expect(toE164('(555) 123-4567', '+1'), '+15551234567');
    });

    test('keeps an already-qualified number and ignores the dial code', () {
      expect(toE164('+447700900123', '+91'), '+447700900123');
      expect(toE164('+44 7700 900123', '+1'), '+447700900123');
    });

    test('rejects input that cannot be a phone number', () {
      expect(toE164('', '+91'), isNull);
      expect(toE164('   ', '+91'), isNull);
      expect(toE164('abc', '+91'), isNull);
      expect(toE164('0', '+91'), isNull);
      expect(toE164('12', '+91'), isNull, reason: 'too short');
      expect(toE164('1234567890123456', '+91'), isNull, reason: 'too long');
      expect(toE164('+1', '+91'), isNull, reason: 'too short with prefix');
    });
  });

  group('AuthProviderId', () {
    test('matches the ids Firebase reports', () {
      expect(AuthProviderId.password, 'password');
      expect(AuthProviderId.google, 'google.com');
      expect(AuthProviderId.phone, 'phone');
    });

    test('still recognises the retired email-code provider', () {
      // Existing documents carry this; the sign-in screen uses it to offer a
      // password reset, since those accounts have a derived password the user
      // has never seen.
      expect(AuthProviderId.legacyEmailLink, 'emailLink');
    });
  });

  group('the removed email-OTP flow stays removed', () {
    // Source-level guards. The bypass below authenticated any account in
    // release builds, so it is worth failing the suite if it reappears.
    test('no universal test code is accepted anywhere in lib/', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (source.contains("== '123456'") ||
            source.contains('== "123456"')) {
          offenders.add(entity.path);
        }
      }
      expect(offenders, isEmpty);
    });

    test('no password is derived from the email address', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (source.contains('HealthOS_OTP_Secret') ||
            source.contains('_deriveOtpPassword')) {
          offenders.add(entity.path);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the fake mailer and in-memory OTP store are gone', () {
      expect(
        File('lib/src/features/auth/data/real_email_service.dart').existsSync(),
        isFalse,
      );
      expect(
        File('lib/src/features/auth/data/otp_service.dart').existsSync(),
        isFalse,
      );
    });

    test('no OTP code is ever rendered to the screen', () {
      final login = File(
        'lib/src/features/auth/presentation/login_screen.dart',
      ).readAsStringSync();
      expect(login, isNot(contains('Dev OTP')));
      expect(login, isNot(contains('Dev Test OTP')));
      expect(login, isNot(contains('_autoFillTestCode')));
    });
  });

  group('AuthRepository phone sign-in', () {
    late MockFirebaseAuth auth;
    late AuthRepository repository;

    setUp(() {
      auth = MockFirebaseAuth();
      repository = AuthRepository(auth, GoogleSignIn());
    });

    test('exposes a phone auth service', () {
      expect(repository.phoneAuth, isA<PhoneAuthService>());
    });

    test('sendPasswordReset normalises the address', () async {
      // The recovery path for legacy accounts; must not fail on casing or
      // stray whitespace typed into the field.
      await expectLater(
        repository.sendPasswordReset('  User@Example.COM '),
        completes,
      );
    });

    // signOut() is not covered here: it calls through to the google_sign_in
    // plugin, which needs a platform binding this unit test does not have.
  });

  group('PhoneAuthService', () {
    test('exposes the 60 second code timeout Firebase uses', () {
      expect(PhoneAuthService.codeTimeout, const Duration(seconds: 60));
    });

    test('builds a credential from a verification id and code', () {
      final service = PhoneAuthService(MockFirebaseAuth());
      final credential = service.credentialFor(
        verificationId: 'verification-123',
        smsCode: '654321',
      );
      expect(credential.smsCode, '654321');
      expect(credential.verificationId, 'verification-123');
    });

    test('linking without a signed-in user fails clearly', () {
      final service = PhoneAuthService(MockFirebaseAuth());
      final credential = service.credentialFor(
        verificationId: 'v',
        smsCode: '123456',
      );
      expect(
        () => service.linkToCurrentUser(credential),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Sign in before adding a phone number'),
          ),
        ),
      );
    });
  });
}
