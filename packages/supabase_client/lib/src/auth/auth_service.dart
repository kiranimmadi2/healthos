import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';

class AuthService {
  SupabaseClient get _client => SupabaseClientInitializer.client;
  GoTrueClient get _auth => _client.auth;

  String? get currentUserId => _auth.currentUser?.id;
  User? get currentUser => _auth.currentUser;
  Session? get currentSession => _auth.currentSession;
  bool get isAuthenticated => _auth.currentUser != null;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Future<void> signInWithPhone(String phone) async {
    await _handleAuth(() => _auth.signInWithOtp(phone: phone));
  }

  Future<void> signInWithEmailOtp(String email) async {
    await _handleAuth(() => _auth.signInWithOtp(email: email));
  }

  Future<AuthResponse> verifyOtp({
    String? phone,
    String? email,
    required String token,
  }) async {
    return await _handleAuth(() {
      if (email != null) {
        return _auth.verifyOTP(
          email: email,
          token: token,
          type: OtpType.email,
        );
      }
      return _auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _handleAuth(() => _auth.signInWithPassword(
          email: email,
          password: password,
        ));
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _handleAuth(() => _auth.signUp(
          email: email,
          password: password,
        ));
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> signInWithGoogle({String? redirectTo}) async {
    await _handleAuth(() => _auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: redirectTo,
        ));
  }

  Future<void> resetPassword(String email) async {
    await _handleAuth(() => _auth.resetPasswordForEmail(email));
  }

  /// Wraps auth calls with user-friendly error messages.
  Future<T> _handleAuth<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (e) {
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

  String _mapAuthError(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid') && msg.contains('otp')) {
      return 'Invalid OTP code. Please check and try again.';
    }
    if (msg.contains('expired') && msg.contains('otp')) {
      return 'OTP has expired. Please request a new one.';
    }
    if (msg.contains('rate') || msg.contains('limit') || msg.contains('too many')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please confirm your email address first.';
    }
    if (msg.contains('user not found')) {
      return 'No account found with these credentials.';
    }
    if (msg.contains('signup') && msg.contains('disabled')) {
      return 'New registrations are currently disabled.';
    }

    return e.message;
  }
}

