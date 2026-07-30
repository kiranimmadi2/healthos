import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/auth_repository.dart';
import '../data/otp_service.dart';
import 'user_providers.dart';

const _googleServerClientId =
    '367688272614-k93vidbjs384pune6f3pvp091oua9vrl.apps.googleusercontent.com';

final otpServiceProvider = Provider<OtpService>((ref) {
  return OtpService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    GoogleSignIn(serverClientId: kIsWeb ? null : _googleServerClientId),
    otpService: ref.watch(otpServiceProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
