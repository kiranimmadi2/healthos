import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  String? _verificationId;

  String? get currentUserId => _firebaseAuth.currentUser?.uid;
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  Stream<User?> get onAuthStateChange => _firebaseAuth.authStateChanges();

  Future<void> signInWithPhone(String phone) async {
    await _handleAuth(() async {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(_mapAuthError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    });
  }

  Future<void> signInWithEmailOtp(String email) async {
    await _handleAuth(() {
      return _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://healthos.page.link',
          handleCodeInApp: true,
          iOSBundleId: 'io.healthos.patient',
          androidPackageName: 'com.health.healthos',
          androidInstallApp: true,
        ),
      );
    });
  }

  Future<void> verifyOtp({
    String? phone,
    String? email,
    required String token,
    String? verificationId,
  }) async {
    await _handleAuth(() async {
      if (phone != null) {
        final vid = verificationId ?? _verificationId;
        if (vid == null) throw Exception('No verification ID available. Please request OTP again.');
        final credential = PhoneAuthProvider.credential(
          verificationId: vid,
          smsCode: token,
        );
        await _firebaseAuth.signInWithCredential(credential);
      } else if (email != null) {
        await _firebaseAuth.signInWithEmailLink(
          email: email,
          emailLink: token,
        );
      }
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _handleAuth(() {
      return _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _handleAuth(() {
      return _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> signInWithGoogle({String? redirectTo}) async {
    debugPrint('[AuthService] signInWithGoogle — redirectTo: $redirectTo');
    await _handleAuth(() async {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    });
  }

  Future<void> resetPassword(String email) async {
    await _handleAuth(() {
      return _firebaseAuth.sendPasswordResetEmail(email: email);
    });
  }

  /// Wraps auth calls with user-friendly error messages.
  Future<T> _handleAuth<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] FirebaseAuthException: ${e.message} (code: ${e.code})');
      throw Exception(_mapAuthError(e));
    } on SocketException catch (_) {
      throw Exception(
          'Unable to connect to the server. Please check your internet connection.');
    } on TimeoutException catch (_) {
      throw Exception(
          'Connection timed out. Please check your internet and try again.');
    } on http.ClientException catch (_) {
      throw Exception(
          'Unable to reach the server. Please check your internet connection and try again.');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('failed to fetch') ||
          msg.contains('clientexception') ||
          msg.contains('socketexception') ||
          msg.contains('connection refused') ||
          msg.contains('network')) {
        throw Exception(
            'Unable to connect to the server. Please check your internet connection.');
      }
      rethrow;
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    final msg = e.message?.toLowerCase() ?? '';
    final code = e.code.toLowerCase();

    if (code == 'invalid-verification-code' || msg.contains('invalid code')) {
      return 'Invalid OTP code. Please check and try again.';
    }
    if (code == 'session-expired' || msg.contains('expired')) {
      return 'OTP has expired. Please request a new one.';
    }
    if (code == 'too-many-requests') {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (code == 'user-not-found' || code == 'wrong-password' || msg.contains('invalid login')) {
      return 'Invalid email or password. Please try again.';
    }
    if (code == 'email-already-in-use') {
      return 'This email is already registered. Please sign in instead.';
    }
    if (code == 'weak-password') {
      return 'Password is too weak. Please use a stronger password.';
    }
    if (code == 'invalid-email') {
      return 'Invalid email address. Please check and try again.';
    }
    if (code == 'operation-not-allowed') {
      return 'This sign-in method is not enabled. Please try another method.';
    }

    return e.message ?? 'Authentication failed. Please try again.';
  }
}
