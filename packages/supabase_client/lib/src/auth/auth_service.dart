import 'dart:async';

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
    await _auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return await _auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(email);
  }
}
