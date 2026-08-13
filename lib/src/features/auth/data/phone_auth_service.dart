import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// SMS one-time-code sign-in, backed by Firebase Phone Auth.
///
/// Replaces a hand-rolled "email OTP" that was decorative: codes lived in an
/// in-memory map on a single client, the mailer never actually sent anything,
/// the literal code `123456` was accepted for any address in release builds,
/// and the resulting Firebase password was derived from `email.hashCode` — so
/// anyone who knew a user's email could compute their password.
///
/// Here the code is generated, delivered and verified by Firebase. Nothing
/// about it is guessable from the client, and there is no bypass: development
/// convenience comes from Firebase's own test phone numbers, which are scoped
/// to specific numbers in the console and inert in production.
///
/// Web and mobile take different paths. `verifyPhoneNumber` is not supported on
/// web, where `signInWithPhoneNumber` returns a [ConfirmationResult] and the
/// SDK renders an invisible reCAPTCHA itself.
class PhoneAuthService {
  PhoneAuthService(this._auth);

  final FirebaseAuth _auth;

  /// How long Firebase will accept the code before a new one is needed.
  static const codeTimeout = Duration(seconds: 60);

  /// Starts verification on Android/iOS.
  ///
  /// [onAutoVerified] fires on Android when the code is auto-retrieved or the
  /// number is instantly verified; the caller should sign in without waiting
  /// for the user to type anything.
  ///
  /// Pass [forceResendingToken] from a previous [onCodeSent] when resending —
  /// without it Firebase may treat the request as a duplicate and not resend.
  Future<void> startVerification({
    required String e164PhoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(FirebaseAuthException error) onFailed,
    int? forceResendingToken,
  }) {
    return _auth.verifyPhoneNumber(
      phoneNumber: e164PhoneNumber,
      timeout: codeTimeout,
      forceResendingToken: forceResendingToken,
      verificationCompleted: onAutoVerified,
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Starts verification on web, where the SDK owns the reCAPTCHA challenge.
  Future<ConfirmationResult> startVerificationOnWeb(String e164PhoneNumber) {
    return _auth.signInWithPhoneNumber(e164PhoneNumber);
  }

  /// Exchanges a typed code for a credential.
  PhoneAuthCredential credentialFor({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  Future<UserCredential> signIn(PhoneAuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  /// Attaches a phone number to the account that is already signed in, so an
  /// existing email or Google user keeps one identity instead of gaining a
  /// second account.
  Future<UserCredential> linkToCurrentUser(PhoneAuthCredential credential) {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Sign in before adding a phone number.',
      );
    }
    return user.linkWithCredential(credential);
  }

  /// True when the platform needs the [ConfirmationResult] flow.
  static bool get usesWebFlow => kIsWeb;
}

/// Normalises user input to the E.164 form Firebase requires.
///
/// Firebase rejects anything else with `invalid-phone-number`, and the most
/// common causes are a local leading zero and separator characters.
///
/// [dialCode] is the selected country prefix, e.g. `+91`.
String? toE164(String input, String dialCode) {
  final digitsAndPlus = input.replaceAll(RegExp(r'[^\d+]'), '');
  if (digitsAndPlus.isEmpty) return null;

  // Already fully qualified.
  if (digitsAndPlus.startsWith('+')) {
    final digits = digitsAndPlus.substring(1);
    return digits.length >= 8 && digits.length <= 15 ? '+$digits' : null;
  }

  // Strip a national trunk prefix before prepending the country code.
  final national = digitsAndPlus.replaceFirst(RegExp(r'^0+'), '');
  if (national.isEmpty) return null;

  final combined = '${dialCode.replaceAll(RegExp(r'[^\d]'), '')}$national';
  return combined.length >= 8 && combined.length <= 15 ? '+$combined' : null;
}
