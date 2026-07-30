import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthos/src/app/theme/theme.dart';
import 'package:healthos/src/features/auth/application/auth_providers.dart';
import 'package:healthos/src/features/auth/data/auth_repository.dart';
import 'package:healthos/src/features/auth/data/otp_service.dart';
import 'package:healthos/src/features/auth/presentation/login_screen.dart';

class TestAuthRepository implements AuthRepository {
  final Map<String, String> _activeOtps = {};
  final OtpService _testOtpService = OtpService();

  @override
  User? get currentUser => null;

  @override
  OtpService get otpService => _testOtpService;

  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) async => [];

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<String> sendEmailOtp(String email) async {
    _activeOtps[email] = '123456';
    return '123456';
  }

  @override
  Future<UserCredential?> verifyEmailOtp(String email, String otpCode) async {
    if (otpCode == '123456') {
      return null;
    }
    throw FirebaseAuthException(
      code: 'invalid-otp',
      message: 'Incorrect OTP code.',
    );
  }

  @override
  Future<UserCredential?> signInWithGoogle() async => null;

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('LoginScreen renders Password and Email OTP toggle tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(TestAuthRepository()),
          ],
          child: const LoginScreen(),
        ),
      ),
    );

    // Verify main components are rendered
    expect(find.text('Welcome to HealthOS'), findsOneWidget);
    expect(find.text('Password'), findsWidgets);
    expect(find.text('Email OTP'), findsOneWidget);

    // Verify default tab is Password mode
    expect(find.text('Email Address'), findsOneWidget);
  });

  testWidgets('Switching to Email OTP tab updates UI to OTP entry step',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(TestAuthRepository()),
          ],
          child: const LoginScreen(),
        ),
      ),
    );

    // Tap on Email OTP tab
    await tester.tap(find.text('Email OTP'));
    await tester.pump();

    // Verify OTP UI elements
    expect(find.text('Email Address for OTP'), findsOneWidget);
    expect(find.text('Send Verification OTP'), findsOneWidget);
    expect(
      find.textContaining('We will send a 6-digit OTP code'),
      findsOneWidget,
    );
  });

  testWidgets('Sending OTP progresses to 6-digit PIN verification step',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(TestAuthRepository()),
          ],
          child: const LoginScreen(),
        ),
      ),
    );

    // Navigate to OTP tab
    await tester.tap(find.text('Email OTP'));
    await tester.pump();

    // Enter email in OTP email field
    final otpEmailFinder =
        find.widgetWithText(TextFormField, 'Email Address for OTP');
    expect(otpEmailFinder, findsOneWidget);

    await tester.enterText(otpEmailFinder, 'patient@healthos.com');
    await tester.pump();

    // Tap Send Verification OTP
    await tester.tap(find.text('Send Verification OTP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify 6-digit code entry step appears
    expect(find.text('Enter 6-Digit OTP Code:'), findsOneWidget);
    expect(find.text('Verify & Sign In'), findsOneWidget);
    expect(find.text('patient@healthos.com'), findsOneWidget);
  });
}
